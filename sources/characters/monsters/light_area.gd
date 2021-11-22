extends Area2D
class_name LightArea

signal light(value)

onready var timer: = $Timer


func light_on() -> void:
	emit_signal("light", true)
	timer.stop()


func light_off() -> void:
	timer.start()


func _on_Timer_timeout() -> void:
	emit_signal("light", false)
