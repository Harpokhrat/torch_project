extends Node2D

onready var dialog_box: = $DialogBox
onready var dialog_label: = $DialogBox/DialogLabel
onready var letter_timer: = $DialogBox/LetterTimer
onready var dialog_timer: = $DialogBox/DialogTimer
onready var sound_textappear: = $TextAppear
onready var pause_screen: = $CanvasLayer/PauseScreen

var dialog: = ""
var flags: = {}
var current_text = ""


func _ready() -> void:
	_globals.viewport_container = $ViewportContainer
	_globals.viewport = $ViewportContainer/Viewport
	
	var _a: = _globals.connect("game_over", self, "_on_game_over")
	var _b: = _globals.connect("dialog", self, "new_dialog")


func _on_game_over() -> void:
	get_tree().change_scene("res://sources/scenes/final.tscn")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = not get_tree().paused
		pause_screen.visible = get_tree().paused


func new_dialog(d: String, f: Dictionary) -> void:
	letter_timer.stop()
	dialog_timer.stop()
	
	dialog = d
	flags = f
	
	dialog_box.visible = true
	dialog_label.bbcode_text = ""
	current_text = ""
	
	letter_timer.start()
	sound_textappear.play()


func _on_LetterTimer_timeout() -> void:
	if dialog.length() != 0:
		current_text += dialog[0]
		dialog.erase(0, 1)
		letter_timer.start()
		
		var final_text: = ""
		for flag in flags.keys():
			if flags[flag].length() == 0:
				final_text += "[" + flag + "]"
			else:
				final_text += "[" + flag + " " + flags[flag] + "]"
		
		final_text += current_text
		
		var invert_flags: Array = flags.keys()
		invert_flags.invert()
		for flag in invert_flags:
			final_text += "[/" + flag + "]"
		
		dialog_label.bbcode_text = final_text
	else:
		dialog_timer.start()
		sound_textappear.stop()


func _on_DialogTimer_timeout() -> void:
	dialog_box.visible = false
	dialog_label.bbcode_text = ""
	current_text = ""
