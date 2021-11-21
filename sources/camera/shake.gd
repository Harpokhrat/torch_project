extends CameraState

onready var timer: = $Timer

var default_duration: = 0.5
var amplitude: = 6.0
var damp_easing: = 1.0


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	var duration: = default_duration
	if msg.has("duration"):
		duration = msg["duration"]
	
	timer.start(duration)


func state_process(delta: float) -> void:
	.state_process(delta)
	
	var damping: = ease(timer.time_left/timer.wait_time, damp_easing)
	camera.offset = Vector2(
			rand_range(amplitude, -amplitude) * damping,
			rand_range(amplitude, -amplitude) * damping
		)


func _on_Timer_timeout() -> void:
	transition_to("Previous")


func shake_it() -> void:
	return
