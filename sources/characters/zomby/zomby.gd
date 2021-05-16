extends Character

onready var detector: Area2D = $Detector
onready var targetRay: RayCast2D = $TargetRay
onready var hitBox: Area2D = $HitBox

export(int) var max_wander_value: int = 200
export(int) var wander_range: int = 50
export(int) var target_range: int = 5

var inital_position: Vector2 = Vector2.ZERO
var target_position: Vector2 = Vector2.ZERO
var detected: Array = []


func _ready() -> void:
	._ready()
	inital_position = global_position
	target_position = global_position


func _process(_delta: float) -> void:
	if velocity != Vector2.ZERO:
		var direction: Vector2 = velocity.normalized()
		turn(direction)
	
	var overlapping_areas = detector.get_overlapping_areas()
	if len(overlapping_areas) > 0:
		target_position = overlapping_areas[0].global_position
	
	targetRay.cast_to = target_position - global_position
	if targetRay.is_colliding():
		target_position = targetRay.get_collision_point()
		var polar_target = cartesian2polar(target_position.x, target_position.y)
		polar_target[0] -= min(polar_target[0] / 10, 10)
		target_position = polar2cartesian(polar_target.x, polar_target.y)


func can_move() -> bool:
	return len(detected) == 0


func new_wandering_position() -> void:
	var offset_vector: Vector2 = Vector2(rand_range(-wander_range, wander_range), rand_range(-wander_range, wander_range))
	target_position = inital_position + offset_vector


func turn(direction: Vector2) -> void:
	animationTree.set("parameters/Idle/blend_position", direction)
	animationTree.set("parameters/Walk/blend_position", direction)
	
	var polar_direction = cartesian2polar(direction[0], direction[1])
	detector.rotation = polar_direction[1]
	hitBox.rotation = polar_direction[1]


func _on_HurtBox_detected(body):
	if body is Character:
		detected.append(body)


func _on_HurtBox_undetected(body):
	var index = 0
	for other_body in detected:
		if body == other_body:
			break
		index += 1
	
	if index < len(detected):
		detected.remove(index)
