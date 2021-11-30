extends Control

onready var sound_click: = $ClickMenu


func _on_Play_pressed() -> void:
	sound_click.play()
	var _a: = get_tree().change_scene("res://sources/scenes/controls.tscn")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		sound_click.play()
		var _a: = get_tree().change_scene("res://sources/scenes/controls.tscn")
