extends Node2D

onready var hitbox_collision: = $HitBox/CollisionShape2D
onready var animation_player: = $AnimationPlayer


func _on_LightArea_light(value) -> void:
	if value:
		hitbox_collision.set_deferred("disabled", value)
		animation_player.play("lit")
	else:
		animation_player.play("unlit")
	if not _globals.first_painting_lit_up:
		_globals.first_painting_lit_up = true
		_globals.emit_signal("dialog", "Better light up these weird paintings before passing in front of them!", {"center": ""})


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "unlit":
		hitbox_collision.disabled = false
