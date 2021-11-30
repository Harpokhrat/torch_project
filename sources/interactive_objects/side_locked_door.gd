extends InteractiveObject

onready var animation_player: = $AnimationPlayer
onready var audio_player: = $DoorLocked


func interact(_player: Node2D) -> void:
	animation_player.play("locked")
	audio_player.play()
