extends MonsterState

export(float) var stroll_distance: = 100.0

onready var timer: = $Timer

var initial_position: = Vector2.ZERO


func _ready() -> void:
	initial_position = global_position


func enter(msg:= {}) -> void:
	.enter(msg)
	
	var _a: = timer.connect("timeout", self, "stroll")
	
	timer.start(rand_range(1, 3))


func exit() -> void:
	.exit()
	
	timer.disconnect("timeout", self, "stroll")


func state_physics_process(delta: float) -> void:
	.state_physics_process(delta)
	
	if monster.player != null and monster.is_target_visible(monster.player):
		transition_to("Chasing")
		return


func stroll() -> void:
	var rand_x: = rand_range(-stroll_distance, stroll_distance)
	var rand_y: = rand_range(-stroll_distance, stroll_distance)
	var rand_vector: Vector2 = Vector2(rand_x, rand_y) + monster.global_position
	if (rand_vector - initial_position).length() > stroll_distance:
		rand_vector =  (rand_vector - initial_position).normalized() * stroll_distance
	
	target_position = rand_vector
	
	timer.start(rand_range(1, 3))
	
	_update_path()
