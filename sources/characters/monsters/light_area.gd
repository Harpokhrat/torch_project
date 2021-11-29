extends Area2D
class_name LightArea

signal light(value)

var is_light_on: = false


func light_on() -> void:
	if not is_light_on:
		emit_signal("light", true)
		is_light_on = true


func light_off() -> void:
	if is_light_on:
		is_light_on = false
		emit_signal("light", false)
