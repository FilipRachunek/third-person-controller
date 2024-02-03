extends Node


func _input(_event):
	if Input.is_action_just_pressed("pause_game"):
		get_viewport().set_input_as_handled()
		if get_tree().paused:
			get_tree().paused = false
