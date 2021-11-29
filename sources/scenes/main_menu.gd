extends Control

onready var sound_click: = $ClickMenu


func _on_Play_pressed() -> void:
	sound_click.play()
	var _a: = get_tree().change_scene("res://sources/scenes/controls.tscn")
