extends Node2D

onready var hitbox_collision: = $HitBox/CollisionShape2D


func _on_LightArea_light(value) -> void:
	hitbox_collision.disabled = value
