extends State
class_name CameraState

var camera: Camera2D
var player: Player
var motion: CameraMotionData
var position_speed: = 10.0
var zoom_speed: = 5.0

var actual_position: = Vector2.ZERO


func enter(msg:= {}) -> void:
	.enter(msg)
	
	if msg.has("zoom"):
		motion.zoom = msg["zoom"]


func state_process(delta: float) -> void:
	motion.actual_position = lerp(motion.actual_position, motion.position, delta * position_speed)
	var pixel_position: = motion.actual_position.round()
	var subpixel_position: = pixel_position - motion.actual_position
#	if _globals.viewport_container:
#		_globals.viewport_container.material.set_shader_param("camera_offset", subpixel_position)
	camera.global_position = pixel_position
	
	camera.zoom = lerp(camera.zoom, motion.zoom, delta * zoom_speed)


func shake_it() -> void:
	transition_to("Shake")
