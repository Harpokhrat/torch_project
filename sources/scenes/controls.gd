extends Control


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		load_game()


func load_game() -> void:
	var _a: = get_tree().change_scene("res://sources/scenes/school.tscn")


func _on_Timer_timeout() -> void:
	load_game()
