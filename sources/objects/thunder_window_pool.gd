extends Node2D

onready var timer: Timer = $Timer
onready var thunder: = $Thunder2

var audio_resource_array: Array = [
	"res://resources/sfx/Thunder/Thunder1.ogg","res://resources/sfx/Thunder/Thunder2.ogg",
	"res://resources/sfx/Thunder/Thunder3.ogg","res://resources/sfx/Thunder/Thunder4.ogg",
	"res://resources/sfx/Thunder/Thunder5.ogg","res://resources/sfx/Thunder/Thunder6.ogg"
]
var window_list: Array = []
var thunder_done = 0



func _ready() -> void:
	for child in get_children():
		if child is Window:
			window_list.append(child)
			
			var _a = child.connect("thunder_done", self, "thunder_is_done")
	
	_randomize_thunder()


func _process(_delta: float) -> void:
	if thunder_done >= len(window_list):
		_randomize_thunder()


func _randomize_thunder() -> void:
	thunder_done = 0
	
	var pitch_scale = rand_range(0.9, 1.5)
	var volume = rand_range(-6, 0)
	
	audio_resource_array.shuffle()
	var audio_stream = load(audio_resource_array[0])
	
	thunder.pitch_scale = pitch_scale
	thunder.volume_db = volume
	thunder.stream = audio_stream
	
	timer.start(1)
#	timer.start(rand_range(3, 12))


func _on_Timer_timeout() -> void:
	for window in window_list:
		window.play_thunder()
		thunder.play()


func thunder_is_done() -> void:
	thunder_done += 1
