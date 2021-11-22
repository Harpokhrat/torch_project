extends Area2D
class_name Plug

onready var particles: = $Particles2D
onready var collision: = $CollisionShape2D


func power(value: bool) -> void:
	particles.emitting = value
	collision.disabled = not value


func plugged(value: bool) -> void:
	particles.emitting = not value
