extends InteractiveObject

onready var sprite: = $Sprite
onready var collision: = $CollisionShape2D
onready var occluder: = $LightOccluder2D

var closed: = true


func interact() -> void:
	if closed:
		closed = false
		sprite.frame = 1
		collision.disabled = true
		occluder.light_mask = 0
	else:
		closed = true
		sprite.frame = 0
		collision.disabled = false
		occluder.light_mask = 1
