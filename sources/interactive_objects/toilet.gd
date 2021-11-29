extends InteractiveObject

onready var sprite: = $Sprite
onready var open_audio: = $OpenAudio
onready var closed_audio: = $ClosedAudio

var closed: = true


func interact(_player: Node2D) -> void:
	if closed:
		closed = false
		sprite.frame = 0
		open_audio.play()
	else:
		closed = true
		sprite.frame = 1
		closed_audio.play()
