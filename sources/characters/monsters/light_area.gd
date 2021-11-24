extends Area2D
class_name LightArea

signal light(value)

onready var timer: = $Timer
var is_light_on: = false


func light_on() -> void:
	timer.stop()
	if not is_light_on:
		emit_signal("light", true)
		is_light_on = true


func light_off() -> void:
	if timer.is_stopped():
		timer.start()


func _on_Timer_timeout() -> void:
	if is_light_on:
		is_light_on = false
		emit_signal("light", false)
