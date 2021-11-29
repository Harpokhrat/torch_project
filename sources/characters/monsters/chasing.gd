extends MonsterState

onready var timer: = $Timer
onready var sound_chasing: = $Chasing

var old_particle_chance: float
var old_sound_chance: float


func enter(msg:= {}) -> void:
	.enter(msg)
	
	monster.play_animation("Walk")
	
	var _a = timer.connect("timeout", self, "_update_path")
	
	if not monster.player:
		transition_to("Stroll")
	
	old_particle_chance = monster.step_particle_chance
	old_sound_chance = monster.step_sound_chance	
	monster.step_particle_chance = 1.0
	monster.step_sound_chance = 1.0
	
	target_position = monster.player.global_position
	_update_path()
	
	timer.start()


func exit() -> void:
	timer.disconnect("timeout", self, "_update_path")
	
	monster.step_particle_chance = old_particle_chance
	monster.step_sound_chance = old_sound_chance


func state_physics_process(delta: float) -> void:
	if monster.player == null or not monster.is_target_visible(monster.player):
		transition_to("Wonder", {"position": target_position})
		return
	
	target_position = monster.player.global_position
	
	.state_physics_process(delta)
