extends CharacterState
class_name PlayerState

export(float) var acceleration: = 750.0
export(float) var friction: = 750.0
export(float) var max_speed: = 50.0
export(float) var rotation_speed: = 5.0

# TODO: typing not present to avoid cyclic dependency
var player
var motion: PlayerMotionData

var _controller_target_speed: = 1000.0


func state_unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left") or event.is_action_pressed("right")\
			or (event.is_action_released("left") and motion.move_direction.x < 0)\
			or (event.is_action_released("right") and motion.move_direction.x > 0):
		motion.move_direction.x = event.get_action_strength("right") - event.get_action_strength("left")
	
	elif event.is_action_pressed("up") or event.is_action_pressed("down")\
			or (event.is_action_released("up") and motion.move_direction.y < 0)\
			or (event.is_action_released("down") and motion.move_direction.y > 0):
		motion.move_direction.y = event.get_action_strength("down") - event.get_action_strength("up")
	
	elif event.is_action_pressed("view_left") or event.is_action_pressed("view_right")\
			or (event.is_action_released("view_left") and motion.target_direction.x < 0)\
			or (event.is_action_released("view_right") and motion.target_direction.x > 0):
		motion.target_direction.x = event.get_action_strength("view_right") - event.get_action_strength("view_left")
	
	elif event.is_action_pressed("view_up") or event.is_action_pressed("view_down")\
			or (event.is_action_released("view_up") and motion.target_direction.y < 0)\
			or (event.is_action_released("view_down") and motion.target_direction.y > 0):
		motion.target_direction.y = event.get_action_strength("view_down") - event.get_action_strength("view_up")
	
	elif event.is_action_pressed("throw"):
		throw()


func state_physics_process(delta: float) -> void:
	.state_physics_process(delta)
	
	var new_facing_direction: = _new_facing_direction()
	if new_facing_direction:
		motion.facing_direction = new_facing_direction
	
	var move_direction: = get_input_direction()
	motion.velocity = calculate_velocity(motion.velocity, move_direction, delta)
	motion.velocity = player.move_and_slide(motion.velocity)
	player.check_collision_with_rope_length_limit()


func calculate_velocity(current_velocity: Vector2, direction: Vector2, delta: float) -> Vector2:
	var new_velocity: = Vector2.ZERO
	if direction:
		new_velocity = current_velocity.move_toward(direction * max_speed, delta * acceleration)
	else:
		new_velocity = current_velocity.move_toward(Vector2.ZERO, delta * friction)
	
	return new_velocity


func get_input_direction() -> Vector2:
	var input_direction: Vector2 = motion.move_direction
	if input_direction.length() > 1.0:
		input_direction = input_direction.normalized()
	
	input_direction = input_direction.rotated(player.global_rotation)
	
	return input_direction


func _new_facing_direction() -> Vector2:
	return motion.target_direction


func hit(hitbox: HitBox) -> void:
	transition_to("Hit", {"hitbox": hitbox})
	
	player.signal_hit()


func throw() -> void:
	transition_to("Throw")
