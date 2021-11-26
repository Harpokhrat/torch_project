extends Area2D



func _on_Area2D_body_entered(body: Node) -> void:
	_globals.respawn_position = global_position
