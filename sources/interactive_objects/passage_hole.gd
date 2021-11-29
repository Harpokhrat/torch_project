extends InteractiveObject

onready var pos: = $Position2D


func interact(player: Node2D) -> void:
	player.global_position = pos.global_position
	player.unplug()
