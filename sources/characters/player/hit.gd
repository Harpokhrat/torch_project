extends PlayerState


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	player.play_animation("Idle")
	
	player.emit_signal("player_hit")


func _new_facing_direction() -> Vector2:
	return Vector2.ZERO
