extends Area2D


export(int) var damage: int = 1


func _on_HitBox_area_entered(hurtBox: Area2D):
	hurtBox.emit_signal("hit", damage)
