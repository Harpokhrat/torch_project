extends State

onready var timer: Timer = $Timer


func enter_state() -> void:
	.enter_state()
	character.play_animation("Idle")
	
	timer.start(rand_range(0.5, 1.5))


func logic(delta: float) -> void:
	var movement_vector: Vector2 = character.target_position - character.global_position
	if not character.can_move() or movement_vector.length() < character.target_range:
		character.velocity = character.velocity.move_toward(Vector2.ZERO, character.friction * delta)
	else:
		character.velocity = character.velocity.move_toward(character.max_speed * movement_vector.normalized(), character.acceleration * delta)
		next_state = "Walk"


func _on_Timer_timeout():
	var choose = randi() % 100
	if choose < 50:
		character.turn(polar2cartesian(1, rand_range(0, 359)))
	else:
		character.new_wandering_position()


func exit_state() -> void:
	.exit_state()
	
	if not timer.is_stopped():
		timer.stop()
