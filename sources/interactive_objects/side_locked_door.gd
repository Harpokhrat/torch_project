extends InteractiveObject

onready var animation_player: = $AnimationPlayer


func interact(_player: Node2D) -> void:
	animation_player.play("locked")
