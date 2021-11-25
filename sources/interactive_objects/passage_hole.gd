extends InteractiveObject

onready var pos: = $Position2D


func interact(player: Player) -> void:
	player.global_position = pos.global_position
