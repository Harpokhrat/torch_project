extends PlayerState


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	player.play_animation("Idle")


func state_physics_process(delta: float) -> void:
	.state_physics_process(delta)
	
	if motion.velocity.length() > 0.0:
		transition_to("Walk")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		var overlapping_areas : Array = player.plug_detection_area.get_overlapping_areas()
		if overlapping_areas.size() > 0:
			player.rope.plug(overlapping_areas[0].global_position)
