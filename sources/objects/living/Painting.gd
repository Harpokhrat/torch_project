extends Node2D

onready var hitbox_collision: = $HitBox/CollisionShape2D


func _on_LightArea_light(value) -> void:
	hitbox_collision.set_deferred("disabled", value)
	if not _globals.first_painting_lit_up:
		_globals.first_painting_lit_up = true
		_globals.emit_signal("dialog", "Better light up these weird paintings before passing in front of them!", {"center": ""})
