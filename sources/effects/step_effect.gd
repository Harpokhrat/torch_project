extends Node2D

export(float) var particle_chance: = 0.1
export(float) var sound_chance: = 0.2

onready var particles: = $Particles2D
onready var audio: = $AudioStreamPlayer2D
onready var timer: = $Timer


func _ready() -> void:
	var p: = randf()
	if p <= particle_chance:
		particles.emitting = true
	
	var s: = randf()
	if s <= sound_chance:
		audio.play()
	
	timer.start()


func _on_Timer_timeout() -> void:
	queue_free()


func _on_AudioStreamPlayer2D_finished() -> void:
	audio.stop()
