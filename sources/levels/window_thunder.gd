extends Node2D

onready var timer: Timer = $Timer

var audio_resource_array: Array = [
	"res://ressources/sfx/zapsplat_nature_thunder_crack_designed_001_31228.mp3",
	"res://ressources/sfx/zapsplat_nature_thunder_crack_designed_002_31229.mp3",
	"res://ressources/sfx/zapsplat_nature_thunder_crack_designed_003_31230.mp3",
]
var window_list: Array = []
var thunder_done = 0



func _ready() -> void:
	for child in get_children():
		if child is Window:
			window_list.append(child)
			
			child.connect("thunder_done", self, "thunder_is_done")
	
	_randomize_thunder()


func _process(_delta: float) -> void:
	if thunder_done >= len(window_list):
		thunder_done = 0
		_randomize_thunder()


func _randomize_thunder() -> void:
	var pitch_scale = rand_range(0.1, 2.0)
	var volume = rand_range(-20, -10)
	
	audio_resource_array.shuffle()
	var audio_stream = load(audio_resource_array[0])
	
	for window in window_list:
		window.thunder.pitch_scale = pitch_scale
		window.thunder.volume_db = volume
		window.thunder.stream = audio_stream
	
	timer.start(rand_range(1, 5))


func _on_Timer_timeout() -> void:
	for window in window_list:
		window.play_thunder()


func thunder_is_done() -> void:
	thunder_done += 1
