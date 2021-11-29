extends Character
class_name Player

# warning-ignore:unused_signal
signal player_hit

onready var lamp: = $Lamp
onready var rope: = $VerletRope
onready var lamp_flare: = $Lamp/LampFlare
onready var unplug_timer: = $UnplugTimer
onready var plug_detection_area: = $PlugDetectionArea
onready var interaction_detection_area: = $InteractionDetectionArea
onready var button_press: = $ButtonPress

var motion: PlayerMotionData
var unplug_direction: = Vector2.ZERO
var is_colliding_with_rope_length_limit: = false


func _init() -> void:
	add_to_group("Player")


func _ready() -> void:
	motion = PlayerMotionData.new()
	
	var nodes: = state_machine.get_children()
	for node in nodes:
		nodes.append_array(node.get_children())
		if node is PlayerState:
			node.player = self
			node.motion = motion
	
	rope.set_player_hurtbox($RopeCollider)
	rope.player_radius = $CollisionShape2D.shape.radius
	rope.player_collision = $CollisionShape2D
	
	lamp.power(false)
	
	state_machine.start()


func _process(_delta: float) -> void:
	animation_tree.set("parameters/Idle/blend_position", motion.facing_direction)
	animation_tree.set("parameters/Walk/blend_position", motion.facing_direction)
	
	var rotation_angle: = motion.facing_direction.angle()
	lamp_flare.rotation = rotation_angle
	lamp_flare.offset = Vector2(0, -13).rotated(-rotation_angle)
	
	var overlapping_plugs : Array = plug_detection_area.get_overlapping_areas()
	var overlapping_interactive_areas: Array = interaction_detection_area.get_overlapping_areas()
	
	if overlapping_plugs.size() != 0 or overlapping_interactive_areas.size() != 0:
		button_press.visible = true
	else:
		button_press.visible = false


func check_collision_with_rope_length_limit() -> void:
	var slide_count = get_slide_count()
	for i in slide_count:
		var collision := get_slide_collision(i)
		var collider := collision.collider
		if PhysicsLayers.object_has_physics_layer(collider, PhysicsLayers.rope_length_limit):
			unplug_direction = motion.move_direction
			collide_with_rope_length_limit()
			return
	if is_colliding_with_rope_length_limit:
		is_colliding_with_rope_length_limit = false
	else:
		if !unplug_timer.is_stopped() and motion.move_direction.dot(unplug_direction) <= 0.95:
			unplug_timer.stop()


func unplug() -> void:
	rope.unplug()
	unplug_timer.stop()


func _on_VerletRope_plugged(boolean: bool) -> void:
	lamp.power(boolean)


func collide_with_rope_length_limit() -> void:
	if unplug_timer.is_stopped():
		unplug_timer.start()


func _on_VerletRope_length_limit_reached(direction: Vector2) -> void:
	unplug_direction = direction
	collide_with_rope_length_limit()
	is_colliding_with_rope_length_limit = true
