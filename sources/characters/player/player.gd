extends Character
class_name Player

# warning-ignore:unused_signal
signal player_hit

onready var lamp: = $Lamp
onready var rope: = $VerletRope
onready var lamp_flare: = $Lamp/LampFlare
onready var unplug_timer: = $UnplugTimer
onready var plug_detection_area: = $PlugDetectionArea

var motion: PlayerMotionData
var unplug_direction: = Vector2.ZERO


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
	
	rope.last_particle.player_hurtbox = self
	rope.player_radius = $CollisionShape2D.shape.radius
	
	lamp.power(false)
	
	state_machine.start()


func _process(_delta: float) -> void:
	animation_tree.set("parameters/Idle/blend_position", motion.facing_direction)
	animation_tree.set("parameters/Walk/blend_position", motion.facing_direction)
	
	lamp_flare.rotation = motion.facing_direction.angle()


func check_collision_with_rope_length_limit() -> void:
	var slide_count = get_slide_count()
	for i in slide_count:
		var collision := get_slide_collision(i)
		var collider := collision.collider
		if PhysicsLayers.object_has_physics_layer(collider, PhysicsLayers.rope_length_limit):
			unplug_direction = motion.move_direction
			if unplug_timer.is_stopped():
				unplug_timer.start()
			return
	if !unplug_timer.is_stopped() and motion.move_direction.dot(unplug_direction) <= 0.95:
		unplug_timer.stop()


func _on_VerletRope_plugged(boolean: bool) -> void:
	lamp.power(boolean)
