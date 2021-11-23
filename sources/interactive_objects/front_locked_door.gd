extends InteractiveObject

onready var animation_player: = $AnimationPlayer


func interact() -> void:
	animation_player.play("interact")
