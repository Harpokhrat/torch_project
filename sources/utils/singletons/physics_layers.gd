extends Node2D

class PhysicsLayer:
	var bit: int
	var number: int
	
	func _init(n: int) -> void:
		bit = n
		number = 1 << n - 1

# Other utils areas
var rope_length_limit: = PhysicsLayer.new(16)


func _ready() -> void:
	assert(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(rope_length_limit.bit)) == "RopeLengthLimit")


func add_physics_layer(layers: int, other_layer: PhysicsLayer) -> int:
	return layers | other_layer.number


func remove_physics_layer(layers: int, other_layer: PhysicsLayer) -> int:
	return layers & ~other_layer.number


func object_has_physics_layer(obj, layer: PhysicsLayer) -> bool:
	return (obj.collision_layer & layer.number) != 0
