extends Node

onready var ambiant_music: = $AmbiantMusic
onready var menu_music: = $MenuMusic


func play(name: String) -> void:
	if name == "Ambiant":
		menu_music.stop()
		if not ambiant_music.playing:
			ambiant_music.play()
	elif name == "Menu":
		ambiant_music.stop()
		if not menu_music.playing:
			menu_music.play()
