extends Node2D

onready var lamp_flare: = $LampFlare
onready var detection: = $LampFlare/LampDetection/CollisionPolygon2D

var detected_areas: Dictionary = {}


func power(value: bool) -> void:
	lamp_flare.enabled = value
	detection.disabled = not value


func _process(_delta: float) -> void:
	for light_area in detected_areas.keys():
		var collider: Node2D = detected_areas[light_area].get_collider()
		if collider == light_area:
			light_area.light_on()
		else:
			light_area.light_off()
		detected_areas[light_area].cast_to = (light_area.global_position - global_position) * 1.1


func _on_LampDetection_area_entered(light_area: LightArea) -> void:
	if light_area:
		for a in detected_areas.values():
			a.add_exception(light_area)
		var new_raycast: = RayCast2D.new()
		for a in detected_areas.keys():
			new_raycast.add_exception(a)
		new_raycast.collision_mask = PhysicsLayers.add_physics_layer(PhysicsLayers.light_collider.number, PhysicsLayers.monsters_hitbox)
		new_raycast.enabled = true
		new_raycast.collide_with_areas = true
		add_child(new_raycast)
		new_raycast.cast_to = (light_area.global_position - global_position) * 1.1
		detected_areas[light_area] = new_raycast


func _on_LampDetection_area_exited(light_area: LightArea) -> void:
	if light_area:
		light_area.light_off()
		
		if detected_areas.has(light_area):
			detected_areas[light_area].queue_free()
			var _a: = detected_areas.erase(light_area)
