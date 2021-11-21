tool
extends Camera2D

export(NodePath) var player_path
export(NodePath) var top_left_path
export(NodePath) var bottom_right_path

onready var state_machine: = $StateMachine

var game_size: = Vector2(480.0, 270.0)
onready var window_scale: float = (OS.window_size / game_size).x

var player: Player


func _ready() -> void:
	# To avoid movement from a parent
	set_as_toplevel(true)
	
	if top_left_path:
		var top_left: Position2D = get_node(top_left_path)
		if top_left != null:
			limit_left = int(top_left.global_position.x)
			limit_top = int(top_left.global_position.y)
	
	if bottom_right_path:
		var bottom_right: Position2D = get_node(bottom_right_path)
		if bottom_right != null:
			limit_right = int(bottom_right.global_position.x)
			limit_bottom = int(bottom_right.global_position.y)
	
	player = get_node(player_path)
	
	var motion: = CameraMotionData.new()
	var nodes: = state_machine.get_children()
	for node in nodes:
		nodes.append_array(node.get_children())
		if node is CameraState:
			node.camera = self
			node.player = player
			node.motion = motion
	
	state_machine.start()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if _globals.viewport:
			var screen_mouse_position: Vector2 = _globals.viewport.get_mouse_position() / window_scale
			var center_mouse_position: = screen_mouse_position - (game_size / 2.0)
			var local_mouse_position: = center_mouse_position + global_position - player.global_position
			player.motion.target_direction = local_mouse_position
		else:
			player.motion.target_direction = get_local_mouse_position()


func _get_configuration_warning() -> String:
	return "Missing player path" if not player_path else ""


func _on_FocusArea_area_entered(area: CameraFocus) -> void:
	if area:
		state_machine.transition_to("Focus", {"position": area.global_position, "zoom": area.zoom})
