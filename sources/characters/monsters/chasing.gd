extends MonsterState

onready var timer: = $Timer


func enter(msg:= {}) -> void:
	.enter(msg)
	
	var _a = timer.connect("timeout", self, "_update_path")
	
	if not monster.player:
		transition_to("Stroll")
	
	target_position = monster.player.global_position
	_update_path()
	
	timer.start()


func exit() -> void:
	timer.disconnect("timeout", self, "_update_path")


func state_physics_process(delta: float) -> void:
	if monster.player == null or not monster.is_target_visible(monster.player):
		transition_to("Wonder", {"position": target_position})
		return
	
	target_position = monster.player.global_position
	
	.state_physics_process(delta)
	
	if !motion.is_lighted_up:
		monster.step(Vector2.ZERO)
