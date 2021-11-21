extends CameraState

var player_previous_position: = Vector2.ZERO
var offset_vector: = Vector2.ZERO
var offset_acceleration: = 75.0
var offset_friction: = 150.0
var offset_range: = 200.0
var offset_speed_limit: = 400.0


func enter(msg:= {}) -> void:
	.enter(msg)
	
	motion.zoom = Vector2.ONE
	player_previous_position = player.global_position


func state_process(delta: float) -> void:
	var player_velocity: Vector2 = player.global_position - player_previous_position
	if player_velocity.length() >= offset_speed_limit * delta:
		var offset: = player_velocity.normalized() * offset_range
		offset_vector = offset_vector.move_toward(offset, delta * offset_acceleration)
	else:
		offset_vector = offset_vector.move_toward(Vector2.ZERO, delta * offset_friction)
	
	motion.position = player.global_position + offset_vector
	
	player_previous_position = player.global_position
	
	.state_process(delta)
