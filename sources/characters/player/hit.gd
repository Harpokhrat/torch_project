extends PlayerState

onready var animation_player: = $AnimationPlayer


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	player.play_animation("Idle")
	player.emit_signal("player_hit")
	
	animation_player.play("die")


func calculate_velocity(_current_velocity: Vector2, _direction: Vector2, _delta: float) -> Vector2:
	return Vector2.ZERO


func _new_facing_direction() -> Vector2:
	return Vector2.ZERO


func reset_position() -> void:
	player.global_position = _globals.respawn_position


func respawn() -> void:
	transition_to("Idle")
