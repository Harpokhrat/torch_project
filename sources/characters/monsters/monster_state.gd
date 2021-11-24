extends CharacterState
class_name MonsterState

export(float) var acceleration: = 750.0
export(float) var friction: = 750.0
export(float) var max_speed: = 55.0
export(float) var rotation_speed: = 2.5
export(float) var health_regen: = 0.1
export(float) var soft_collision_strength: = 100

# TODO: Not using Monster class because of cyclic dependency
var monster
var motion: MonsterMotionData
var navigation: Navigation2D
var target_position: = Vector2.ZERO
var navigation_path: PoolVector2Array = []
var navigation_index: = 0
var chasing_range: = 7.0


func state_physics_process(delta: float) -> void:
	.state_physics_process(delta)
	
	var new_facing_direction: = get_facing_direction()
	if new_facing_direction:
		motion.facing_direction = new_facing_direction
	
	var was_moving: = motion.velocity.length() != 0.0
	
	motion.move_direction = get_move_direction()
	motion.velocity = calculate_velocity(motion.velocity, motion.move_direction, delta)
	motion.velocity += monster.get_soft_collision_vector() * soft_collision_strength * delta
	motion.velocity = monster.move_and_slide(motion.velocity)
	
	if was_moving and motion.velocity.length() == 0.0:
		monster.play_animation("Idle")
	elif not was_moving and motion.velocity.length() != 0.0:
		monster.play_animation("Walk")
	
	var distance: float = (monster.global_transform.origin - target_position).length()
	if distance <= chasing_range:
		navigation_path = []
		navigation_index = 0


func calculate_velocity(current_velocity: Vector2, direction: Vector2, delta: float) -> Vector2:
	var new_velocity: = Vector2.ZERO
	if direction:
		new_velocity = current_velocity.move_toward(direction * max_speed, delta * acceleration)
	else:
		new_velocity = current_velocity.move_toward(Vector2.ZERO, delta * friction)
	
	return new_velocity


func get_move_direction() -> Vector2:
	return compute_move_direction()


func compute_move_direction() -> Vector2:
	if navigation_index >= navigation_path.size():
		return Vector2.ZERO
	
	var vector: Vector2 = navigation_path[navigation_index] - monster.global_transform.origin
	var distance: float = vector.length()
	while(distance <= chasing_range):
		navigation_index += 1
		if navigation_index >= navigation_path.size():
			break
		vector = navigation_path[navigation_index] - monster.global_transform.origin
		distance = vector.length()
	
	if navigation_index >= navigation_path.size():
		navigation_index = navigation_path.size() - 1
	
	var dir: Vector2 = navigation_path[navigation_index] - monster.global_transform.origin
	dir /= chasing_range
	if dir.length() > 1.0:
		dir = dir.normalized()
	
	return dir


func get_facing_direction() -> Vector2:
	return compute_facing_direction()


func compute_facing_direction() -> Vector2:
	return motion.move_direction


func _update_path() -> void:
	if navigation != null:
		target_position = navigation.get_closest_point(target_position)
		navigation_path = navigation.get_simple_path(monster.global_transform.origin, target_position)
		navigation_index = 0
	else:
		navigation_path = [target_position]
		navigation_index = 0


func light_on(value: bool) -> void:
	if value:
		transition_to("InLight")
	else:
		push_warning("Should not light off when not in special state")
