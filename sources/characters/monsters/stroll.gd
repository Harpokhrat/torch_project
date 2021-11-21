extends MonsterState

export(float) var stroll_distance: = 100.0

onready var timer: = $Timer


func enter(msg:= {}) -> void:
	.enter(msg)
	
	var _a: = timer.connect("timeout", self, "stroll")
	timer.start()


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
	var rand_vector: = Vector2(rand_x, rand_y)
	if rand_vector.length() > stroll_distance:
		rand_vector = rand_vector.normalized() * stroll_distance
	
	target_position = monster.global_position + rand_vector
	
	_update_path()
	
	timer.start()
