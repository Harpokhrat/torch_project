extends "res://sources/objects/living/thunder_window_pool.gd"

onready var orig_min_time: = min_time
onready var orig_max_time: = max_time


func _on_PassageHole_went_through() -> void:
	min_time = 3
	max_time = 5
	_randomize_thunder()


func _on_PassageHole_went_through_out() -> void:
	min_time = orig_min_time
	max_time = orig_max_time

