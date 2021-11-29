extends InteractiveObject

onready var pos: = $Position2D
onready var sound_interaction: = $AudioInteract


func interact(player: Node2D) -> void:
	player.global_position = pos.global_position
	player.unplug()
	sound_interaction.play()
