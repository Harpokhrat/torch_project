extends Node

# warning-ignore:unused_signal
signal game_over
signal effect_to_add(effect)
signal node_in_level_to_add(node)
# warning-ignore:unused_signal
signal dialog(dialog, flags)

var viewport_container: ViewportContainer = null
var viewport: Viewport = viewport
var respawn_position: = Vector2(0, 0)
var first_monster_lit_up: = false
var first_painting_lit_up: = false


func add_effect(effect: Node2D) -> void:
	emit_signal("effect_to_add", effect)


func add_node_to_level(node: Node2D) -> void:
	emit_signal("node_in_level_to_add", node)
