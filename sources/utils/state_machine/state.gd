extends Node2D
class_name State

# TODO: No typing to avoid cyclic dependency (change it when it is corrected)
onready var _state_machine = _get_state_machine(self)

var is_active: = true setget set_is_active


func state_unhandled_input(_event: InputEvent) -> void:
	return


func state_process(_delta: float) -> void:
	return


func state_physics_process(_delta: float) -> void:
	return


func enter(_msg:= {}) -> void:
	return


func exit() -> void:
	return


func transition_to(state_path: String, msg: Dictionary = {}) -> void:
	_state_machine.transition_to(state_path, msg)


func set_is_active(value: bool) -> void:
	is_active = value
	set_block_signals(not value)


func _get_state_machine(node: Node) -> Node:
	if node != null and not node.is_in_group("StateMachine"):
		return _get_state_machine(node.get_parent())
	return node
