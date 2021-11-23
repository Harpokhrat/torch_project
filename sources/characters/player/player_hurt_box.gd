extends HurtBox

var stress_areas: = []


func _process(_delta: float) -> void:
	var stress_level: = 0.0
	for area in stress_areas:
		var distance: float = (area.global_position - global_position).length()
		var norm_distance: float = distance / area.stress_range
		var range_factor: = 1.0 - pow(norm_distance, 5.0)
		stress_level += range_factor * area.stress_value
	
	if _globals.viewport_container:
		_globals.viewport_container.material.set_shader_param("stress_amount", stress_level)


func add_stress_area(stress_area: StressArea):
	if stress_area and not stress_areas.has(stress_area):
		stress_areas.append(stress_area)


func remove_stress_area(stress_area: StressArea):
	if stress_area and stress_areas.has(stress_area):
		stress_areas.erase(stress_area)
