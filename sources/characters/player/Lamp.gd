extends Light2D


func _on_LampDetection_area_entered(light_area: LightArea) -> void:
	if light_area:
		light_area.light_on()


func _on_LampDetection_area_exited(light_area: LightArea) -> void:
	if light_area:
		light_area.light_off()
