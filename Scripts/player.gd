extends CharacterBody3D

@export var move_speed := 5.0
@export var jump_force := 9.0
@export var mouse_sensitivity := 0.01

@onready var cam_pivot: Node3D = %CameraPivot
@onready var tower_menu: Control = $"../TowerCanvas/TowerMenu"
@export var tower_point: MeshInstance3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_tower_spot: Area3D = null
var menu_open := false

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Connect signals from the UI
	tower_menu.connect("request_close_menu", _on_menu_closed)
	tower_menu.connect("tower_selected", _on_tower_selected)

func _physics_process(delta):
	# Disable gameplay movement while menu open
	if menu_open:
		return

	handle_movement(delta)
	move_and_slide()

	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Press E to interact
	if Input.is_action_just_pressed("interact"):
		if current_tower_spot and not menu_open:
			open_tower_menu()

func _unhandled_input(event):
	# Disable camera look while menu open
	if menu_open:
		return

	if event is InputEventMouseMotion:
		handle_mouse_look(event)

func handle_mouse_look(event: InputEventMouseMotion):
	var mx := event.relative.x * mouse_sensitivity
	var my := event.relative.y * mouse_sensitivity

	rotate_y(-mx)
	cam_pivot.rotate_x(-my)
	cam_pivot.rotation_degrees.x = clamp(cam_pivot.rotation_degrees.x, -89, 89)

func handle_movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_force

	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	var forward := -transform.basis.z
	var right := transform.basis.x
	var move_dir := forward * input_vector.y + right * input_vector.x

	if move_dir.length() > 0:
		move_dir = move_dir.normalized() * move_speed
		velocity.x = move_dir.x
		velocity.z = move_dir.z
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

# --- Menu Control ---

func open_tower_menu():
	menu_open = true
	tower_menu.open_menu()

	# Unlock mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	print("Opened tower menu")

func _on_menu_closed():
	menu_open = false

	# Re-lock mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("Closed tower menu")

func _on_tower_selected(tower_scene_path: String):
	print("Tower selection received:", tower_scene_path)

	if not current_tower_spot:
		print("Error: No current tower spot!")
		return

	# Find the placeholder in the TowerPoints group inside the current spot
	var placeholder: MeshInstance3D = null
	for node in get_tree().get_nodes_in_group("TowerPoints"):
		if node.get_parent() == current_tower_spot:
			placeholder = node
			break

	if not placeholder:
		print("Error: No tower placeholder found in current spot")
		return

	print("Replacing tower placeholder:", placeholder.name)

	# Load the selected tower
	var tower_scene: PackedScene = load(tower_scene_path)
	if not tower_scene:
		print("Error: failed to load tower scene:", tower_scene_path)
		return

	var spawn_transform: Transform3D = placeholder.transform

	# Remove placeholder
	placeholder.queue_free()
	print("Placeholder removed")

	# Instantiate tower
	var tower_instance: Node3D = tower_scene.instantiate() as Node3D
	tower_instance.transform = spawn_transform

	# Add to the current spot
	current_tower_spot.add_child(tower_instance)
	print("Tower placed:", tower_instance.name)

	# Close menu and re-lock mouse
	tower_menu.close_menu()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	menu_open = false


# --- Tower Spot Registration ---
func register_tower_spot(spot):
	current_tower_spot = spot

func unregister_tower_spot(spot):
	if current_tower_spot == spot:
		current_tower_spot = null
