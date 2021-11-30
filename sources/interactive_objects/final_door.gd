extends InteractiveObject


func interact(_player: Node2D) -> void:
	_globals.emit_signal("game_over")
