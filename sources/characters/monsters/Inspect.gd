extends MonsterState

onready var timer: = $Timer
var rot_count: = 0
var clockwise: = 0.0


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	monster.play_animation("Idle")
	
	clockwise = sign(randf() - 0.5)
	rot_count = 0
	timer.start()


func exit() -> void:
	.exit()
	timer.stop()


func state_physics_process(delta: float) -> void:
	if monster.player != null and monster.is_target_visible(monster.player):
		transition_to("Chasing")
		return
	
	.state_physics_process(delta)


func _on_Timer_timeout() -> void:
	rot_count += 1
	if (rot_count <= 3):
		motion.facing_direction = motion.facing_direction.rotated(PI/2 * clockwise)
	else:
		transition_to("Stroll")


func _on_LightArea_light(value) -> void:
	timer.paused = value
