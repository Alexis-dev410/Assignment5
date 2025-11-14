extends CharacterBody3D

@export var move_speed := 5.0
@export var jump_force := 9.0
@export var mouse_sensitivity := 0.01

@onready var cam_pivot: Node3D = $CameraPivot

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta):
	handle_movement(delta)
	move_and_slide()

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		handle_mouse_look(event)

func handle_mouse_look(event: InputEventMouseMotion):
	var mx := event.relative.x * mouse_sensitivity
	var my := event.relative.y * mouse_sensitivity

	rotate_y(-mx)                     # yaw
	cam_pivot.rotate_x(-my)           # pitch

	cam_pivot.rotation_degrees.x = clamp(
		cam_pivot.rotation_degrees.x,
		-89, 89
	)

func handle_movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("ui_select"):
			velocity.y = jump_force

	# Get WASD input
	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	print("input:", input_vector)

	# Convert to movement relative to player rotation
	var forward := -transform.basis.z
	var right := transform.basis.x
	var move_dir := (forward * input_vector.y + right * input_vector.x)

	if move_dir.length() > 0:
		move_dir = move_dir.normalized() * move_speed
		velocity.x = move_dir.x
		velocity.z = move_dir.z
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
