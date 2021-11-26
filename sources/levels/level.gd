extends Node2D

onready var navigation: = $Navigation2D
onready var ysort: = $Navigation2D/YSort
onready var respawn_timer: = $RespawnTimer

var monsters_initial_position: = {}


func _ready() -> void:
	var _a: = _globals.connect("effect_to_add", self, "add_effect")
	var _b: = _globals.connect("node_in_level_to_add", self, "add_node_to_level")
	
	Music.play("Ambiant")
	
	for monster in get_tree().get_nodes_in_group("Monsters"):
		monsters_initial_position[monster] = monster.global_position


func add_effect(effect: Node2D):
	navigation.add_child(effect)


func add_node_to_level(node: Node2D):
	ysort.add_child(node)


func _on_Player_player_hit() -> void:
	respawn_timer.start()


func _on_RespawnTimer_timeout() -> void:
	for monster in monsters_initial_position.keys():
		monster.global_position = monsters_initial_position[monster]
		monster.state_machine.transition_to("Stroll")
