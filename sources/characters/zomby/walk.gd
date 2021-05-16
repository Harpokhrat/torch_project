extends State


func enter_state() -> void:
	.enter_state()
	character.play_animation("Walk")


func logic(delta: float) -> void:
	var movement_vector: Vector2 = character.target_position - character.global_position
	if not character.can_move() or movement_vector.length() < character.target_range:
		character.velocity = character.velocity.move_toward(Vector2.ZERO, character.friction * delta)
		next_state = "Idle"
	else:
		character.velocity = character.velocity.move_toward(character.max_speed * movement_vector.normalized(), character.acceleration * delta)
	
	character.move()
