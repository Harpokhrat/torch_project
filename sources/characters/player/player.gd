extends Character

onready var lamp: Light2D = $Lamp
onready var animationPlayer = $AnimationPlayer


func _process(_delta: float) -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var mouse_direction: Vector2 = (mouse_position - global_position).normalized()
	
	animationTree.set("parameters/Idle/blend_position", mouse_direction)
	animationTree.set("parameters/Walk/blend_position", mouse_direction)

	var mouse_polar: Vector2 = cartesian2polar(mouse_direction.x, mouse_direction.y)
	lamp.rotation = mouse_polar[1]


func _on_LampDetection_area_entered(area):
	area.emit_signal("detected", self)


func _on_LampDetection_area_exited(area):
	area.emit_signal("undetected", self)


func set_health(new_health: int) -> void:
	if new_health < health:
		animationPlayer.play("Hit")
		
	.set_health(new_health)
	
