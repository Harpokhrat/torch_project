extends Monster




func _on_PassageHole2_went_through() -> void:
	motion.facing_direction = (get_tree().get_nodes_in_group("Player")[0].global_position - global_position).normalized()
	motion.move_direction = motion.facing_direction
