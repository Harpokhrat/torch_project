extends KinematicBody2D
class_name Character

onready var state_machine: = $StateMachine
onready var animation_tree: = $AnimationTree
onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
onready var sprite: = $Sprite


func _ready() -> void:
	animation_tree.active = true


func play_animation(animation_name: String) -> void:
	animation_state.travel(animation_name)
