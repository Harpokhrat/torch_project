extends CameraState

var target_position: = Vector2.ZERO
var postion_speed: = 50
var window_margin: = 0.01


func enter(msg:= {}) -> void:
	.enter(msg)
	
	if msg.has("position"):
		motion.position = msg["position"]


func state_process(delta: float) -> void:
	.state_process(delta)
	
	var window_size: = get_viewport_rect().size
	var window_offset: Vector2 = (0.5 - window_margin) * window_size * camera.zoom
	if player.global_position.x < camera.global_position.x - window_offset.x or \
			player.global_position.x > camera.global_position.x + window_offset.x or \
			player.global_position.y < camera.global_position.y - window_offset.y or \
			player.global_position.y > camera.global_position.y + window_offset.y:
		
		transition_to("Follow")


func shake_it() -> void:
	transition_to("Shake")
