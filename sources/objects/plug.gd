extends Area2D
class_name Plug

export(float) var visibility_range: = 150.0

onready var particles: = $Particles2D
onready var collision: = $CollisionShape2D

var player: Player


func _ready() -> void:
	player = get_tree().get_nodes_in_group("Player")[0]


func _process(_delta: float) -> void:
	var distance: = (player.global_position - global_position).length()
	var norm_distance: = clamp(distance / visibility_range, 0.0, 1.0)
	
	var factor: = 1.0 - pow(norm_distance, 5.0)
	
	particles.modulate.a = factor


func power(value: bool) -> void:
	particles.emitting = value
	collision.disabled = not value


func plugged(value: bool) -> void:
	particles.emitting = not value
