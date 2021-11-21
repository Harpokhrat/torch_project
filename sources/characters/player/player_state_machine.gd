extends StateMachine
class_name PlayerStateMachine


func _on_HurtBox_hit(hitbox) -> void:
	state.hit(hitbox)
