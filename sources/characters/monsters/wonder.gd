extends MonsterState

onready var timer: = $Timer
export(int) var sup_distance := 20


func enter(msg: Dictionary = {}) -> void:
	.enter(msg)
	
	monster.play_animation("Walk")
	
	target_position = msg["position"]
	var direction: = (target_position - global_position).normalized()
	target_position = target_position + direction * sup_distance
	_update_path()

	var _a: = timer.connect("timeout", self, "end_wonder")
	timer.start()


func exit() -> void:
	.exit()
	
	timer.disconnect("timeout", self, "end_wonder")


func state_physics_process(delta: float) -> void:
	if monster.player != null and monster.is_target_visible(monster.player):
		transition_to("Chasing")
		return
	
	if navigation_path.size() == 0:
		transition_to("Inspect")
		return
	
	.state_physics_process(delta)


func end_wonder() -> void:
	transition_to("Inspect")
