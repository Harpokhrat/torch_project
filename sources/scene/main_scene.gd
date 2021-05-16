extends Node2D


func _on_Player_character_died(body):
	get_tree().change_scene("res://sources/levels/main_menu.tscn")
