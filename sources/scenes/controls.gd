extends Control


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("ui_cancel"):
		load_game()


func load_game() -> void:
	var _a: = get_tree().change_scene("res://sources/scenes/school.tscn")


func _on_Timer_timeout() -> void:
	load_game()
