extends Area2D
class_name HurtBox

signal hit(hitbox)

onready var collision: = $CollisionShape2D


func register_hit(hitbox: Area2D) -> void:
	emit_signal("hit", hitbox)


func disable() -> void:
	collision.set_deferred("disabled", true)


func activate() -> void:
	collision.set_deferred("disabled", false)
