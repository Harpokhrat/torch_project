extends Node2D


func _ready() -> void:
	_globals.viewport_container = $ViewportContainer
	_globals.viewport = $ViewportContainer/Viewport
