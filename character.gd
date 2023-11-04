extends CharacterBody3D


const WALK_SPEED = 2.0
const RUN_SPEED = 6.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var running = false
@onready var animation_tree = $AnimationTree
@onready var camera_look_at = $"../CameraController/LookAt"


func _input(_event):
	running = true if Input.is_action_pressed("move_run") else false
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func _physics_process(delta):
	var speed = RUN_SPEED if running else WALK_SPEED
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		look_at(Vector3(camera_look_at.global_position.x, global_position.y, camera_look_at.global_position.z))
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	animation_tree.set("parameters/conditions/idle", input_dir == Vector2.ZERO)
	animation_tree.set("parameters/conditions/walk", input_dir != Vector2.ZERO and not running)
	animation_tree.set("parameters/conditions/run", input_dir != Vector2.ZERO and running)
	animation_tree.set("parameters/conditions/fall", global_position.y < -0.1)
	animation_tree.set("parameters/conditions/jump", global_position.y >= -0.1 and not is_on_floor())
	move_and_slide()
