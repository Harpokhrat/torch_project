extends Control


func _process(_delta: float) -> void:
	if Input.is_action_pressed("ui_accept") or Input.is_action_pressed("ui_cancel"):
		load_menu()


func load_menu() -> void:
	var _a: = get_tree().change_scene("res://sources/scenes/main_menu.tscn")
