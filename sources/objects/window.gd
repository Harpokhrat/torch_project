extends StaticBody2D

class_name Window

onready var thunder: AudioStreamPlayer2D = $Thunder
onready var animationPlayer: AnimationPlayer = $AnimationPlayer

signal thunder_done


func play_thunder() -> void:
	animationPlayer.play("Thunder")


func thunder_is_done() -> void:
	emit_signal("thunder_done")
