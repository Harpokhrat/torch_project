extends CameraState

var player_previous_position: = Vector2.ZERO
var offset_vector: = Vector2.ZERO
var offset_acceleration: = 75.0
var offset_friction: = 150.0
var offset_range: = 30.0
var offset_speed_limit: = 0.1


func enter(msg:= {}) -> void:
	.enter(msg)
	
	motion.zoom = Vector2.ONE
	player_previous_position = player.global_position


func state_process(delta: float) -> void:
	offset_vector = motion.mouse_position.normalized() * offset_range
	
	motion.position = player.global_position + offset_vector
	
	player_previous_position = player.global_position
	
	.state_process(delta)
