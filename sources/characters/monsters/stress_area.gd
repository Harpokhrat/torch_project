extends Area2D
class_name StressArea

export(float) var stress_value: = 1.0

onready var stress_range: float = $CollisionShape2D.shape.radius


func _on_StressArea_area_entered(hurtbox: HurtBox) -> void:
	if hurtbox:
		hurtbox.add_stress_area(self)


func _on_StressArea_area_exited(hurtbox: HurtBox) -> void:
	if hurtbox:
		hurtbox.remove_stress_area(self)
