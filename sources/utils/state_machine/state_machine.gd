extends Node2D
class_name StateMachine

signal transitioned(state_path, msg)

export(NodePath) var initial_state: = NodePath()

onready var state: State = get_node(initial_state) setget set_state

var previous_state: State = null
var previous_msg: Dictionary = {}
var current_msg: Dictionary = {}
var is_started: = false
var is_active: = false setget _set_is_active
var state_name: = ""


func _init() -> void:
	add_to_group("StateMachine")


func _ready() -> void:
	self.is_active = false


func start() -> void:
	is_started = true
	self.is_active = true
	
	state.enter()
	emit_signal("transitioned", initial_state, {})


func _unhandled_input(event: InputEvent) -> void:
	state.state_unhandled_input(event)


func _process(delta: float) -> void:
	state.state_process(delta)


func _physics_process(delta: float) -> void:
	state.state_physics_process(delta)


func transition_to(target_state_path: String, msg: = {}):
	var target_state: State = null
	if target_state_path == "Previous":
		if previous_state == null:
			push_warning("No previous state at this point")
			return
		target_state = previous_state
		for key in previous_msg.keys():
			if not msg.has(key):
				msg[key] = previous_msg[key]
	else:
		if not has_node(target_state_path):
			push_warning("State not found: " + target_state_path)
			return
		target_state = get_node(target_state_path)
	
	previous_msg = current_msg
	current_msg = msg
	previous_state = state
	
	state.exit()
	self.state = target_state
	state.enter(msg)
	
	emit_signal("transitioned", state_name, msg)


func set_state(value: State) -> void:
	state = value
	state_name = state.name


func _set_is_active(value: bool) -> void:
	if not is_started and value:
		return
	
	is_active = value
	
	set_process(value)
	set_physics_process(value)
	set_process_unhandled_input(value)
	
	state.is_active = value
