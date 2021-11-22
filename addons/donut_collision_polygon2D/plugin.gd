tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("DonutCollisionPolygon2D", "CollisionPolygon2D", preload("donut_collision_polygon2D.gd"), preload("donut_collision_polygon2D.svg"))

func _exit_tree():
	remove_custom_type("DonutCollisionPolygon2D")
