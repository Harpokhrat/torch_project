extends Node

class_name StateMachine

export(String) var initial_state = "Idle"

var state_map: Dictionary = {}
var current_state: State = null
var previous_state: State = null


func _ready() -> void:
	yield(get_parent(), "ready")
	
	for child in get_children():
		state_map[child.name] = child
		child.character = get_parent()
	
	change_state(initial_state)


func _physics_process(delta: float) -> void:
	if current_state != null:
		current_state.logic(delta)
		
		var next_state: String = current_state.get_transition()
		if next_state in state_map:
			change_state(next_state)
		elif next_state == "previous":
			remove_state()


func change_state(new_state: String) -> void:
	if current_state != null:
		current_state.exit_state()
	previous_state = current_state
	
	current_state = state_map[new_state]
	current_state.enter_state()


func remove_state() -> void:
	if current_state != null:
		current_state.exit_state()
	
	if previous_state != null:
		previous_state.enter_state()
	
	current_state = previous_state
	previous_state = null


func _on_HurtBox_hit(damage: int) -> void:
	current_state._on_HurtBox_hit(damage)
