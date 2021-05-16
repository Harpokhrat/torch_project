extends Node

class_name State

onready var character: Character

var next_state: String = ""


func enter_state() -> void:
	next_state = ""


func logic(_delta: float) -> void:
	pass


func get_transition() -> String:
	return next_state


func exit_state() -> void:
	pass


func _on_HurtBox_hit(damage: int) -> void:
	pass
