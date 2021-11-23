
extends Line2D
class_name VerletRope

signal plugged(boolean)

enum { LOOSE, TIGHT, LASSO, CHECK_LONE_KINEMATIC, LONE_KINEMATIC, LAST_FIXED }

var verlet_pos_constraints := preload("res://sources/characters/player/rope/VerletPosConstraints.gdns").new()

onready var area := $Area
onready var last_particle := $LastParticle
onready var length_limit := $LengthLimit
onready var length_limit_collision := $LengthLimit/CollisionPolygon2D

# references: 
# https://docs.unrealengine.com/4.26/en-US/Basics/Components/Rendering/CableComponent/
# https://owlree.blog/posts/simulating-a-rope.html
# https://qroph.github.io/2018/07/30/smooth-paths-using-catmull-rom-splines.html
# https://toqoz.fyi/game-rope.html

export(bool) var debug := false setget set_debug
export(float) var rope_length: float = 5.0
export(float) var max_length: float = 1500 setget set_max_length
export(float) var player_radius: float = 100.0
 
export(int, 3, 500) var simulation_particles: int = 9 
export(int) var iterations: int = 2 setget set_iterations # low value = more sag, high value = less sag
export(int, 0, 120) var preprocess_iterations: int = 5
export(int, 10, 60) var simulation_rate: int = 60
export(float, 0.01, 1.5) var stiffness = 0.9 # low value = elastic, high value = taut rope
export(float) var impulse_factor := 10.0  setget set_impulse_factor# force dealt by the rope on bodies
export(float) var goal_radius := 10.0

export(bool) var simulate: bool = true
export(bool) var draw: bool = true
export(int) var nb_particles_sharing_area : int = 10

var throw_direction : Vector3
onready var orig_color := default_color
var loose := true


func set_max_length(value: float) -> void:
	max_length = value
	if not is_inside_tree():
		yield(self, "ready")
	length_limit_collision.radius = max_length


func set_debug(value: bool) -> void:
	if not OS.is_debug_build():
		debug = false
	else:
		debug = value


func set_iterations(value) -> void:
	iterations = value
	verlet_pos_constraints.iterations = iterations


func set_impulse_factor(value: float) -> void:
	impulse_factor = value
	verlet_pos_constraints.impulse_factor = impulse_factor


func get_segment_length() -> float:
	return rope_length / (simulation_particles - 1)


func set_player_hurtbox(player_hurtbox: CollisionObject2D) -> void:
	last_particle.player_hurtbox = player_hurtbox
	verlet_pos_constraints.set_player_body(player_hurtbox)


func _create_rope() -> void:
	var pos_curr = PoolVector2Array([])
	pos_curr.resize(simulation_particles)
	var pos_prev = PoolVector2Array([])
	pos_prev.resize(simulation_particles)
	var areas = []
	
	for i in range(simulation_particles):
		if i % nb_particles_sharing_area == 0:
			areas.append(area.duplicate())
			add_child(areas[-1])
			areas[-1].set_as_toplevel(true)
		else:
# warning-ignore:integer_division
			areas.append(areas[i / nb_particles_sharing_area * nb_particles_sharing_area])
	verlet_pos_constraints.areas = areas
	area.queue_free()

	# past this point all those arrays are consumed and should not be used	
	verlet_pos_constraints.set_arrays(pos_curr, pos_prev)
	verlet_pos_constraints.set_initial_positions(global_transform.origin)
	
	verlet_pos_constraints.max_length = max_length
	verlet_pos_constraints.segment_length = get_segment_length()
	verlet_pos_constraints.stiffness = stiffness
	verlet_pos_constraints.iterations = iterations
	verlet_pos_constraints.simulation_particles = simulation_particles
	verlet_pos_constraints.goal_radius = goal_radius
	verlet_pos_constraints.nb_particles_sharing_area = nb_particles_sharing_area
	verlet_pos_constraints.set_last_particle_pointer(last_particle.area)
	
	verlet_pos_constraints.connect("hit", self, "_on_verlet_pos_constraints_hit")
	
	for _iter in range(preprocess_iterations):
		verlet_pos_constraints.verlet_process(1.0 / 60.0)
		# commenting this shaves quite a bit more startup time
		verlet_pos_constraints.apply_constraints()


func _on_verlet_pos_constraints_hit(_body: CollisionObject2D) -> void:
	end()
	emit_signal("hit")


func throw(vec: Vector2, clockwise: float, spin_speed: float, impulse_speed: float) -> void:
	loose = true
	last_particle.initialize()
	if clockwise == 0:
		impulse_speed *= 2
	call_deferred("activate_areas", true)
	verlet_pos_constraints.set_initial_positions(global_transform.origin)
	draw = true
	simulate = true
	verlet_pos_constraints.begin_simulation(vec, clockwise, spin_speed, impulse_speed)
	show()


func plug(at: Vector2) -> void:
	loose = false
	last_particle.initialize()
	call_deferred("activate_areas", true)
	verlet_pos_constraints.set_initial_positions(global_transform.origin)
	draw = true
	simulate = true
	verlet_pos_constraints.begin_simulation(Vector2.ONE * 1000, 0, 1, 1)
	verlet_pos_constraints.fix_last_area(at)
	show()
	emit_signal("plugged", true)


func unplug() -> void:
	end()
	emit_signal("plugged", false)


func end() -> void:
	last_particle.enabled = false
	draw = false
	simulate = false
	call_deferred("activate_areas", false)
	length_limit_collision.set_deferred("disabled", true)
	hide()


func activate_areas(enable: bool):
	last_particle.enabled = enable
	for a in verlet_pos_constraints.areas:
		a.monitorable = enable
		a.monitoring = enable


func _ready() -> void:
	joint_mode = Line2D.LINE_JOINT_BEVEL
	_create_rope()
	verlet_pos_constraints.connect("state_changed", self, "_on_rope_state_changed")
	activate_areas(false)


func _on_rope_state_changed(new_state: int) -> void:
	loose = false
	last_particle.collide_with_player = true
	if new_state == CHECK_LONE_KINEMATIC or new_state == LASSO or new_state == LAST_FIXED:
		last_particle.enabled = false
	elif new_state == TIGHT:
		if verlet_pos_constraints.clockwise == 0:
			emit_signal("hit")


func _physics_process(delta: float) -> void:
	if Engine.editor_hint and (verlet_pos_constraints == null or verlet_pos_constraints.is_empty()):
		_create_rope()
	
	#warning-ignore:integer_division
	if Engine.get_physics_frames() % int(Engine.iterations_per_second / simulation_rate) != 0:
		return

	if simulate:
		# warning-ignore:integer_division
		var last_particle_previous_position : Vector2 = last_particle.global_position
		verlet_pos_constraints.simulate(global_transform.origin, last_particle_previous_position, delta * float(Engine.iterations_per_second / simulation_rate))
		last_particle.move(verlet_pos_constraints.get_last_particle_position())
		
		if verlet_pos_constraints.is_limiting_rope_length():
			var limit_rope_length_center : Vector2 = verlet_pos_constraints.get_limit_rope_length_center()
			length_limit.global_position = limit_rope_length_center
			
			var limit_rope_length_size : float = verlet_pos_constraints.get_limit_rope_length_size()
			
			var player_margin := player_radius + global_position.distance_to(limit_rope_length_center)
			if limit_rope_length_size < player_margin:
				limit_rope_length_size = player_margin
			
			var limit_length_ratio := limit_rope_length_size / max_length
			length_limit.scale = Vector2.ONE * limit_length_ratio
			
			default_color = lerp(orig_color, Color.black, pow(1 - limit_length_ratio, 2))
			
			length_limit_collision.set_deferred("disabled", false)
		else:
			length_limit_collision.set_deferred("disabled", true)


	# drawing
	if draw:
		points = global_transform.xform_inv(verlet_pos_constraints.get_pos_curr())


func _on_VisibilityNotifier_camera_exited(_camera: Camera) -> void:
	#simulate = false
	draw = false

func _on_VisibilityNotifier_camera_entered(_camera: Camera) -> void:
	#simulate = true
	draw = true


func _on_LastParticle_collision(body: CollisionObject2D, collision_point: Vector2) -> void:
	if body.owner is Player:
		verlet_pos_constraints.try_lasso_from_hitting_player()
	else:
		verlet_pos_constraints.check_lasso_with_collision(body, collision_point)
		if body is StaticBody2D or body.owner is StaticBody2D:
			verlet_pos_constraints.fix_last_area(collision_point)


func _on_UnplugTimer_timeout() -> void:
	unplug()
