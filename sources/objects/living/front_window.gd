extends Window

onready var other_animation_player: = $Light2D2/AnimationPlayer


func play_thunder() -> void:
	.play_thunder()
	other_animation_player.play("window_thunder")
