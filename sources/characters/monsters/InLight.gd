extends MonsterState


func enter(msg:= {}) -> void:
	.enter(msg)
	
	monster.hitbox_collision.set_deferred("disabled", true)
	
	target_position = Vector2.ZERO
	
	monster.play_animation("Die")


func exit() -> void:
	monster.hitbox_collision.set_deferred("disabled", false)


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
		monster.play_animation("Die")
	else:
		monster.play_animation("Rebirth")


func rebirth_ok():
	if target_position == Vector2.ZERO:
		transition_to("Stroll")
	else:
		transition_to("Wonder", {"position": target_position})
