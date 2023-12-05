extends Node3D


var hero
var look_at_hero

@export var sensitivity = 5
@export var zoom_sensitivity = 0.1

@onready var spring_arm_3d = $SpringArm3D
@onready var camera_3d = $SpringArm3D/Camera3D


# Called when the node enters the scene tree for the first time.
func _ready():
	hero = get_tree().get_first_node_in_group("playable")
	look_at_hero = hero.get_node("LookAt")

func _input(event):
	if event is InputEventMouseMotion:
		var camera_rotation = rotation.x - event.relative.y / 1000 * sensitivity
		rotation.y -= event.relative.x / 1000 * sensitivity
		camera_rotation = clamp(camera_rotation, -1.5, -0.05)
		rotation.x = camera_rotation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			spring_arm_3d.spring_length = clampf(spring_arm_3d.spring_length - zoom_sensitivity, 1, 6)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			spring_arm_3d.spring_length = clampf(spring_arm_3d.spring_length + zoom_sensitivity, 1, 6)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	global_position = Vector3(hero.global_position.x, hero.global_position.y + 1.8, hero.global_position.z)
	camera_3d.look_at(look_at_hero.global_position)
