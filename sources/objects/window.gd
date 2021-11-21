extends StaticBody2D
class_name Window

signal thunder_done

onready var animationPlayer: AnimationPlayer = $AnimationPlayer


func play_thunder() -> void:
	animationPlayer.play("thunder")


func thunder_is_done() -> void:
	emit_signal("thunder_done")
