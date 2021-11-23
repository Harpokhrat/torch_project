extends Node2D

class PhysicsLayer:
	var bit: int
	var number: int
	
	func _init(n: int) -> void:
		bit = n
		number = 1 << n - 1

# Bodies
var world: = PhysicsLayer.new(1)
var characters: = PhysicsLayer.new(2)
var rope_collider: = PhysicsLayer.new(3)

# Areas
var player: = PhysicsLayer.new(9)
var monsters: = PhysicsLayer.new(10)
var plugs: = PhysicsLayer.new(11)
var interactive_objects: = PhysicsLayer.new(12)

var rope_length_limit: = PhysicsLayer.new(16)

# Other utils areas
var camera_focus: = PhysicsLayer.new(17)


func _ready() -> void:
	assert(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(world.bit)) == "World")
	assert(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(characters.bit)) == "Characters")
	assert(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(rope_collider.bit)) == "RopeCollider")
	
	assert(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(player.bit)) == "Player")
	assert(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(monsters.bit)) == "Monsters")
	assert(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(plugs.bit)) == "Plugs")
	assert(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(interactive_objects.bit)) == "InteractiveObjects")
	
	assert(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(rope_length_limit.bit)) == "RopeLengthLimit")
	
	assert(ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(camera_focus.bit)) == "CameraFocus")


func add_physics_layer(layers: int, other_layer: PhysicsLayer) -> int:
	return layers | other_layer.number


func remove_physics_layer(layers: int, other_layer: PhysicsLayer) -> int:
	return layers & ~other_layer.number


func object_has_physics_layer(obj, layer: PhysicsLayer) -> bool:
	return (obj.collision_layer & layer.number) != 0
