extends Node2D

onready var dialog_box: = $DialogBox
onready var dialog_label: = $DialogBox/DialogLabel
onready var letter_timer: = $DialogBox/LetterTimer
onready var dialog_timer: = $DialogBox/DialogTimer

var dialog: = ""
var flags: = {}
var current_text = ""


func _ready() -> void:
	_globals.viewport_container = $ViewportContainer
	_globals.viewport = $ViewportContainer/Viewport
	
	_globals.connect("dialog", self, "new_dialog")


func new_dialog(d: String, f: Dictionary) -> void:
	letter_timer.stop()
	dialog_timer.stop()
	
	dialog = d
	flags = f
	
	dialog_box.visible = true
	dialog_label.bbcode_text = ""
	current_text = ""
	
	letter_timer.start()


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


func _on_DialogTimer_timeout() -> void:
	dialog_box.visible = false
	dialog_label.bbcode_text = ""
	current_text = ""
