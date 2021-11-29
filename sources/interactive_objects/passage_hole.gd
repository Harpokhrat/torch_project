extends InteractiveObject

signal went_through
onready var pos: = $Position2D


func interact(player: Node2D) -> void:
	player.global_position = pos.global_position
	player.unplug()
	emit_signal("went_through")
