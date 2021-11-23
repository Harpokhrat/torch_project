extends Node2D

onready var navigation: = $Navigation2D
onready var ysort: = $Navigation2D/YSort


func _ready() -> void:
	var _a: = _globals.connect("effect_to_add", self, "add_effect")
	var _b: = _globals.connect("node_in_level_to_add", self, "add_node_to_level")
	
	Music.play("Ambiant")


func add_effect(effect: Node2D):
	navigation.add_child(effect)


func add_node_to_level(node: Node2D):
	ysort.add_child(node)
