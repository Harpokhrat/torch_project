extends InteractiveObject

onready var sprite: = $Sprite
onready var collision: = $CollisionShape2D
onready var light_collision: = $LightCollider/CollisionShape2D
onready var occluder: = $LightOccluder2D
onready var sound_opendoor: = $OpenDoor
onready var sound_closedoor: = $CloseDoor

var closed: = true


func interact(_player: Node2D) -> void:
	if closed:
		closed = false
		sprite.frame = 1
		collision.disabled = true
		light_collision.disabled = true
		occluder.light_mask = 0
		sound_opendoor.play()
	else:
		closed = true
		sprite.frame = 0
		collision.disabled = false
		light_collision.disabled = false
		occluder.light_mask = 1
		sound_closedoor.play()
