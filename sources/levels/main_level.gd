extends Node2D



func _on_Area2D_area_entered(area):
	get_tree().change_scene("res://sources/menus/main_menu.tscn")


func _on_Player_character_died(body):
	get_tree().change_scene("res://sources/menus/main_menu.tscn")
