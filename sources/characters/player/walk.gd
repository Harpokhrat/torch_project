extends State


func enter_state() -> void:
	.enter_state()
	character.play_animation("Walk")


func logic(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector == Vector2.ZERO:
		next_state = "Idle"
	
	character.velocity = character.velocity.move_toward(character.max_speed * input_vector, character.acceleration * delta)
	character.move()


func _on_HurtBox_hit(damage: int) -> void:
	character.health -= damage
