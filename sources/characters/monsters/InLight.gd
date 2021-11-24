extends MonsterState


func enter(msg:= {}) -> void:
	.enter(msg)
	
	target_position = Vector2.ZERO


func get_move_direction() -> Vector2:
	return Vector2.ZERO


func get_facing_direction() -> Vector2:
	return Vector2.ZERO


func state_physics_process(delta: float) -> void:
	if not (monster.player == null or not monster.is_target_visible(monster.player)):
		target_position = monster.player.global_position
	
	.state_physics_process(delta)


func light_on(value: bool) -> void:
	if value:
		push_error("Should not light on when in special state")
	else:
		if target_position == Vector2.ZERO:
			transition_to("Stroll")
		else:
			transition_to("Wonder", {"position": target_position})
