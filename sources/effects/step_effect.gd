extends Node2D

onready var particles: = $Particles2D
onready var audio: = $AudioStreamPlayer2D
onready var timer: = $Timer

var particle_chance: float
var sound_chance: float


func _ready() -> void:
	var p: = randf()
	if p <= particle_chance:
		particles.emitting = true
	
	var s: = randf()
	if s <= sound_chance:
		audio.play()
	
	timer.start()


func setup(p_chance: float = 0.1, s_chance: float = 0.2) -> void:
	particle_chance = p_chance
	sound_chance = s_chance


func _on_Timer_timeout() -> void:
	queue_free()


func _on_AudioStreamPlayer2D_finished() -> void:
	audio.stop()
