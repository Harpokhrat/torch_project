extends StaticBody2D

export(float) var unit_offset
onready var path: PathFollow2D = get_parent()


func _process(_delta: float) -> void:
	path.unit_offset = unit_offset
