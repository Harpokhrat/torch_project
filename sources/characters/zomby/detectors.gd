extends Node2D

var detected_position: Vector2 = Vector2.ZERO
var detected: bool = false


func _process(_delta: float) -> void:
	var detected_objects = []
	for child in get_children():
		if child.is_colliding():
			var object = child.get_collider()
			if object.is_in_group("GoodGuys"):
				detected_objects.append(object)
	
	if len(detected_objects) > 0:
		detected_objects.shuffle()
		detected_position = detected_objects[0].global_position
		detected = true
	else:
		detected = false
