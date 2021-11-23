extends Node2D

onready var lamp_flare: = $LampFlare
onready var detection: = $LampFlare/LampDetection/CollisionPolygon2D

var detected_areas: Dictionary = {}


func power(value: bool) -> void:
	lamp_flare.enabled = value
	detection.disabled = not value


func _process(_delta: float) -> void:
	for light_area in detected_areas.keys():
		detected_areas[light_area].cast_to = (light_area.global_position - global_position) * 1.1
		var collider: Node2D = detected_areas[light_area].get_collider()
		if collider == light_area:
			light_area.light_on()
		else:
			light_area.light_off()


func _on_LampDetection_area_entered(light_area: LightArea) -> void:
	if light_area:
		detected_areas[light_area] = RayCast2D.new()
		detected_areas[light_area].collision_mask = PhysicsLayers.add_physics_layer(PhysicsLayers.light_collider.number, PhysicsLayers.monsters_hitbox)
		detected_areas[light_area].enabled = true
		detected_areas[light_area].collide_with_areas = true
		add_child(detected_areas[light_area])
		detected_areas[light_area].cast_to = (light_area.global_position - global_position) * 1.1


func _on_LampDetection_area_exited(light_area: LightArea) -> void:
	if light_area:
		light_area.light_off()
		
		if detected_areas.has(light_area):
			detected_areas[light_area].queue_free()
			var _a: = detected_areas.erase(light_area)
