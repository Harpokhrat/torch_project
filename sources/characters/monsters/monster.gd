extends Character
class_name Monster

export(NodePath) var navigation_path
export(NodePath) var path_follow_path

onready var pivot: = $Pivot
onready var sight: = $Sight

var step_effect_prototype: = preload("res://sources/effects/step_effect.tscn")
var motion: MonsterMotionData
var player: Player
var path_follow: PathFollow2D


func _ready() -> void:
	var navigation: Navigation2D = get_node(navigation_path)
	if navigation == null:
		raise()
	
	if path_follow_path != "":
		path_follow = get_node(path_follow_path)
	
	motion = MonsterMotionData.new()
	var motion_states = state_machine.get_children()
	for node in motion_states:
		motion_states.append_array(node.get_children())
		if node is MonsterState:
			node.monster = self
			node.motion = motion
			node.navigation = navigation
	
	state_machine.start()


func _process(_delta: float) -> void:
	animation_tree.set("parameters/Idle/blend_position", motion.facing_direction)
	animation_tree.set("parameters/Walk/blend_position", motion.facing_direction)
	
	pivot.rotation = motion.facing_direction.angle()


func _physics_process(_delta: float) -> void:
	if player != null:
		sight.cast_to = 1.1 * (player.global_position - global_position)
	else:
		sight.cast_to = Vector2.ZERO


func is_target_visible(target: Node2D) -> bool:
	var collider : Node2D = sight.get_collider()
	var parent_test: bool = (collider != null and collider == target)
	
	return parent_test


func step(pos: Vector2) -> void:
	var step_effect: Node2D = step_effect_prototype.instance()
	_globals.add_effect(step_effect)
	
	step_effect.global_position = global_position + pos


func _on_WatchArea_area_entered(hurtbox: HurtBox) -> void:
	if hurtbox:
		player = hurtbox.owner


func _on_WatchArea_area_exited(_area: Area2D) -> void:
	player = null


func _on_LightArea_light(value) -> void:
	motion.is_lighted_up = value
