extends Node3D

@onready var pause_label = $CanvasLayer2/PauseLabel

var global_time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pause_label.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_time += delta
	RenderingServer.global_shader_parameter_set("global_time", global_time)
	if pause_label.visible:
		pause_label.visible = false


func _input(_event):
	if Input.is_action_just_pressed("pause_game"):
		pause_game()


func _notification(what):
	if what == MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT:
		pause_game()

func pause_game():
	pause_label.visible = true
	get_tree().paused = true
