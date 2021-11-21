extends Area2D
class_name HitBox

signal hit(hurtbox)


func _on_HitBox_area_entered(hurtbox: HurtBox) -> void:
	if hurtbox:
		hurtbox.register_hit(self)
		emit_signal("hit", hurtbox)
