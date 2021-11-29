extends LinkButton


func _on_DiscordLink_pressed() -> void:
	var _a: = OS.shell_open("https://discord.gg/PUdRGyvPAb")
