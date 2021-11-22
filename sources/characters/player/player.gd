extends Character
class_name Player

# warning-ignore:unused_signal
signal player_hit

onready var lamp: = $Lamp
onready var rope: = $VerletRope
onready var lamp_flare: = $Lamp/LampFlare

var motion: PlayerMotionData


func _ready() -> void:
	motion = PlayerMotionData.new()
	
	var nodes: = state_machine.get_children()
	for node in nodes:
		nodes.append_array(node.get_children())
		if node is PlayerState:
			node.player = self
			node.motion = motion
	
	rope.last_particle.player_hurtbox = self
	
	state_machine.start()


func _process(_delta: float) -> void:
	animation_tree.set("parameters/Idle/blend_position", motion.facing_direction)
	animation_tree.set("parameters/Walk/blend_position", motion.facing_direction)
	
	lamp_flare.rotation = motion.facing_direction.angle()
