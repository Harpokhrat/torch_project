extends LinkButton

onready var sound_click: = $ClickMenu

func _on_DiscordLink_pressed() -> void:
	sound_click.play()
	var _a: = OS.shell_open("https://discord.gg/PUdRGyvPAb")
	
