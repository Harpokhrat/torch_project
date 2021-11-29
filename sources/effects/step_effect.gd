extends Node2D

onready var particles: = $Particles2D
onready var audio: = $StudentSounds
onready var timer: = $Timer
var audio_resource_array: Array = [ "res://resources/sfx/Students/StudentsLaugh1.ogg",
"res://resources/sfx/Students/StudentsLaugh2.ogg","res://resources/sfx/Footsteps/StudentsFootstepCreaky.ogg"
]

var particle_chance: float
var sound_chance: float


func _ready() -> void:
	var p: = randf()
	if p <= particle_chance:
		particles.emitting = true
	
	var s: = randf()
	if s <= sound_chance:
		audio_resource_array.shuffle()
		var audio_stream = load(audio_resource_array[0])
		audio.stream = audio_stream
		audio.play()
	
	timer.start()


func setup(p_chance: float = 0.1, s_chance: float = 0.1) -> void:
	particle_chance = p_chance
	sound_chance = s_chance


func _on_Timer_timeout() -> void:
	queue_free()


func _on_AudioStreamPlayer2D_finished() -> void:
	audio.stop()
