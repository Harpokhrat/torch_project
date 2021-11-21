extends Area2D
class_name LightArea

signal light(value)


func light_on() -> void:
	emit_signal("light", true)


func light_off() -> void:
	emit_signal("light", false)
