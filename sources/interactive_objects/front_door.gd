extends InteractiveObject

onready var sprite: = $Sprite
onready var collision: = $CollisionShape2D
onready var light_collision: = $LightCollider/CollisionShape2D
onready var occluder: = $LightOccluder2D

var closed: = true


func interact(_player: Node2D) -> void:
	if closed:
		closed = false
		sprite.frame = 0
		collision.disabled = true
		light_collision.disabled = true
		occluder.light_mask = 0
	else:
		closed = true
		sprite.frame = 1
		collision.disabled = false
		light_collision.disabled = false
		occluder.light_mask = 1
