extends Node2D


func _on_Launch_pressed():
	get_tree().change_scene("res://sources/scene/main_scene.tscn")


func _on_Exit_pressed():
	get_tree().quit()
