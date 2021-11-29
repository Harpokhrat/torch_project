extends MonsterState

export(float) var stroll_distance: = 50.0

onready var timer: = $Timer

var initial_position: = Vector2.ZERO


func _ready() -> void:
	initial_position = global_position


func enter(msg:= {}) -> void:
	.enter(msg)
	
	if monster.path_follow:
		stroll()
	else:
		var _a: = timer.connect("timeout", self, "stroll")
		timer.start(rand_range(3, 10))


func exit() -> void:
	.exit()
	
	if not monster.path_follow:
		timer.disconnect("timeout", self, "stroll")


func state_physics_process(delta: float) -> void:
	var was_moving: = motion.velocity.length() != 0.0
	
	.state_physics_process(delta)
	
	if was_moving and motion.velocity.length() == 0.0:
		monster.play_animation("Idle")
	elif not was_moving and motion.velocity.length() != 0.0:
		monster.play_animation("Walk")
	
	if monster.player != null and monster.is_target_visible(monster.player):
		transition_to("Chasing")
		return


func state_process(delta: float) -> void:
	if monster.path_follow:
		if (monster.path_follow.global_position - monster.global_position).length() <= chasing_range:
			monster.path_follow.unit_offset += 0.1 * delta
			if monster.path_follow.unit_offset > 1.0:
				monster.path_follow.unit_offset = 0.0
		
			stroll()


func stroll() -> void:
	if monster.path_follow:
		target_position = monster.path_follow.global_position
	else:
		var rand_x: = rand_range(-stroll_distance, stroll_distance)
		var rand_y: = rand_range(-stroll_distance, stroll_distance)
		var rand_vector: Vector2 = Vector2(rand_x, rand_y) + monster.global_position
		if (rand_vector - initial_position).length() > stroll_distance:
			rand_vector = initial_position + (rand_vector - initial_position).normalized() * stroll_distance
		
		target_position = rand_vector
		
		timer.start(rand_range(3, 10))
	
	_update_path()
