extends KinematicBody2D

class_name Character

onready var animationTree:AnimationTree = $AnimationTree

export(int) var health: int = 1 setget set_health
export(int) var max_health: int = 1
export(int) var max_speed: int = 75
export(int) var acceleration: int = 750
export(int) var friction: int = 500

var animationState: AnimationNodeStateMachinePlayback = null
var velocity: Vector2 = Vector2.ZERO
var noticed_character_list: Array = []

signal character_died(body)


func _ready() -> void:
	animationTree.active = true
	animationState = animationTree.get("parameters/playback")
	
	health = max_health


func play_animation(animation_name: String) -> void:
	animationState.travel(animation_name)


func move() -> void:
	velocity = move_and_slide(velocity)


func set_health(new_health: int) -> void:
	health = min(max_health, max(0, new_health))
	
	if health == 0:
		emit_signal("character_died", self)
