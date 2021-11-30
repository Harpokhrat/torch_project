extends InteractiveObject

onready var sprite: = $Sprite
onready var open_audio: = $OpenAudio
onready var closed_audio: = $ClosedAudio

var closed: = true


func interact(_player: Node2D) -> void:
	if closed:
		closed = false
		sprite.region_rect = Rect2(8, 3, 14, 37)
		sprite.offset = Vector2(0, 0)
		open_audio.play()
	else:
		closed = true
		sprite.region_rect = Rect2(28, 3, 28, 37)
		sprite.offset = Vector2(7, 0)
		closed_audio.play()
