extends Area2D
class_name DialogArea

export(String) var dialog: = ""
export(Array, String) var flags: = ["center"]
export(bool) var one_shoot: = false


func _on_DialogArea_body_entered(player: Player) -> void:
	if player:
		_globals.emit_signal("dialog", dialog, flags)
		if one_shoot:
			queue_free()
