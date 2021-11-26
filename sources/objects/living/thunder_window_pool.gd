extends Node2D

onready var timer: Timer = $Timer
onready var thunder: = $Thunder

var audio_resource_array: Array = [
	"res://resources/sfx/Thunder/Thunder1.ogg","res://resources/sfx/Thunder/Thunder2.ogg",
	"res://resources/sfx/Thunder/Thunder3.ogg","res://resources/sfx/Thunder/Thunder4.ogg",
	"res://resources/sfx/Thunder/Thunder5.ogg","res://resources/sfx/Thunder/Thunder6.ogg"
]
var window_list: Array = []



func _ready() -> void:
	for child in get_children():
		if child is Window:
			window_list.append(child)
	
	timer.start(rand_range(7, 21))


func _randomize_thunder() -> void:
	var pitch_scale = rand_range(0.9, 1.5)
	var volume = rand_range(-6, 0)
	
	audio_resource_array.shuffle()
	var audio_stream = load(audio_resource_array[0])
	
	thunder.pitch_scale = pitch_scale
	thunder.volume_db = volume
	thunder.stream = audio_stream
	
	for window in window_list:
		window.play_thunder()
		thunder.play()
	
	timer.start(rand_range(7, 21))


func _on_Timer_timeout() -> void:
	_randomize_thunder()
