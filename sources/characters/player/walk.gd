extends PlayerState


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	player.play_animation("Walk")


func state_physics_process(delta: float) -> void:
	.state_physics_process(delta)
	
	if motion.velocity.length() == 0.0:
		transition_to("Idle")
