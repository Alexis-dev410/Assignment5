extends CharacterBody3D

@export var move_speed := 5.0
@export var jump_force := 9.0
@export var mouse_sensitivity := 0.01

@onready var cam_pivot: Node3D = $CameraPivot
@onready var tower_place_menu: Control = $"../TowerCanvas/TowerPlace"
@onready var tower_menu: Control = $"../TowerCanvas/TowerMenu"

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_tower_spot: Area3D = null
var menu_open := false
var mount_cooldown := false



func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Tower place menu signals
	tower_place_menu.connect("request_close_menu", _on_menu_closed)
	tower_place_menu.connect("tower_selected", _on_tower_selected)

	# Tower menu signals
	tower_menu.connect("request_close_menu", _on_menu_closed)
	tower_menu.connect("destroy_tower", _on_destroy_tower)
	tower_menu.connect("mount_tower", Callable(self, "_on_mount_tower_pressed"))


# -------------------------------------------------
# PHYSICS / INPUT
# -------------------------------------------------

func _physics_process(delta):
	if menu_open or mounted_tower != null:
		return

	handle_movement(delta)
	move_and_slide()

	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if Input.is_action_just_pressed("interact"):
		if current_tower_spot and not menu_open and not mount_cooldown:

			handle_interact()

	# Disable movement while mounted but allow camera
	if not menu_open and mounted_tower == null:
		handle_movement(delta)
		move_and_slide()
	else:
		velocity = Vector3.ZERO  # stop movement when mounted


func _unhandled_input(event):
	if menu_open:
		return

	if event is InputEventMouseMotion:
		handle_mouse_look(event)

	# Allow dismount with E
	if mounted_tower != null and Input.is_action_just_pressed("interact"):
		print("Dismounting from tower")
		mounted_tower = null



# -------------------------------------------------
# CAMERA
# -------------------------------------------------

func handle_mouse_look(event: InputEventMouseMotion):
	var mx := event.relative.x * mouse_sensitivity
	var my := event.relative.y * mouse_sensitivity

	rotate_y(-mx)
	cam_pivot.rotate_x(-my)
	cam_pivot.rotation_degrees.x = clamp(cam_pivot.rotation_degrees.x, -89, 89)


# -------------------------------------------------
# MOVEMENT
# -------------------------------------------------

func handle_movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_force

	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

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


# -------------------------------------------------
# INTERACTION
# -------------------------------------------------

func handle_interact():
	var obj := get_spot_object()

	if obj == null:
		print("ERROR: Spot has no placeable object!")
		return

	# Empty placeholder → open place menu
	if obj.name.begins_with("TowerPoint") or obj.is_in_group("TowerPoint"):
		open_tower_place_menu()
		return

	# Existing tower → open tower menu
	if obj.is_in_group("Tower"):
		open_existing_tower_menu()
		return


# -------------------------------------------------
# MENU CONTROL
# -------------------------------------------------

func open_tower_place_menu():
	menu_open = true
	tower_place_menu.open_menu()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func open_existing_tower_menu():
	menu_open = true
	tower_menu.open_menu()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_menu_closed():
	menu_open = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# -------------------------------------------------
# TOWER PLACEMENT
# -------------------------------------------------

func _on_tower_selected(tower_name: String):
	place_tower(tower_name)
	tower_place_menu.close_menu()

	mounted_tower = get_spot_object() if get_spot_object() and get_spot_object().is_in_group("Tower") else null


func place_tower(tower_name: String):
	if current_tower_spot == null:
		return

	var placeholder := get_spot_object()

	if placeholder == null or not (placeholder.is_in_group("TowerPoint") or placeholder.name.begins_with("TowerPoint")):
		print("ERROR: No valid TowerPoint found during placement")
		return

	var tower_scene := load(tower_name)
	if tower_scene == null:
		print("ERROR: Could not load tower:", tower_name)
		return

	var new_tower: Node3D = tower_scene.instantiate()
	new_tower.add_to_group("Tower")

	var old_transform := placeholder.global_transform

	placeholder.queue_free()
	current_tower_spot.add_child(new_tower)
	new_tower.global_transform = old_transform


# -------------------------------------------------
# TOWER DESTRUCTION
# -------------------------------------------------

func _on_destroy_tower():
	if current_tower_spot == null:
		return

	var tower := get_spot_object()
	if tower == null or not tower.is_in_group("Tower"):
		print("ERROR: No tower to destroy!")
		return

	var old_transform := tower.global_transform
	tower.queue_free()
	mounted_tower = null # <- clear reference

	var tower_point_scene := load("res://Scenes/TowerPoint.tscn")
	var new_point: Node3D = tower_point_scene.instantiate()
	new_point.name = "TowerPoint"
	new_point.add_to_group("TowerPoint")
	current_tower_spot.add_child(new_point)
	new_point.global_transform = old_transform

	tower_menu.close_menu()

# ------------------------------
# MOUNT / DISMOUNT
# ------------------------------

@export var mount_offset: Vector3 = Vector3(0, 0.8, -1.5)
var mounted_tower: Node3D = null
var is_mounted := false

func _on_mount_tower_pressed() -> void:
	print("MountTower button pressed")
	toggle_mount()

func _on_interact_pressed() -> void:
	if is_mounted:
		print("Dismounting via interact")
		toggle_mount()

func toggle_mount() -> void:
	if not is_mounted:
		mount_player()
	else:
		dismount_player()

func mount_player() -> void:
	var tower := get_spot_object()
	if tower == null or not tower.is_in_group("Tower"):
		print("No valid tower to mount!")
		return

	mounted_tower = tower
	is_mounted = true
	menu_open = false
	tower_menu.close_menu()

	var t := mounted_tower.global_transform
	global_transform.origin = \
		t.origin - t.basis.z * abs(mount_offset.z) + Vector3(0, mount_offset.y, 0)

	global_transform.basis = t.basis
	velocity = Vector3.ZERO

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	print("Mounted tower:", mounted_tower.name)

func dismount_player() -> void:
	print("\n=== FORCED DISMOUNT CHECK ===")
	print("Before dismount -> mounted_tower:", mounted_tower)
	print("Before dismount -> is_mounted:", is_mounted)

	# --- FIX: if is_mounted is true, ALWAYS dismount, even if tower is null ---
	if is_mounted:
		print("Force-dismounting player...")

		# Push player a bit forward so tower spot re-triggers correctly
		global_transform.origin += global_transform.basis.z * 1.5

		mounted_tower = null
		is_mounted = false

		start_mount_cooldown()

		print("After forced dismount -> mounted_tower:", mounted_tower)
		print("After forced dismount -> is_mounted:", is_mounted)
		return

	# If we reach this, player wasn't mounted
	print("Dismount failed: no tower mounted (and is_mounted == false)")

 # Cooldown so the menu doesn't open when dismounting
func start_mount_cooldown(duration := 0.4) -> void:
	mount_cooldown = true
	await get_tree().create_timer(duration).timeout
	mount_cooldown = false
	print("Cooldown finished")


# -------------------------------------------------
# SPOT OBJECT DETECTION
# -------------------------------------------------

func get_spot_object() -> Node3D:
	if current_tower_spot == null:
		return null

	for child in current_tower_spot.get_children():
		if child.is_in_group("Tower"):
			return child

		if child.is_in_group("TowerPoint") or child.name.begins_with("TowerPoint"):
			return child

	return null


# -------------------------------------------------
# SPOT MANAGEMENT
# -------------------------------------------------

func register_tower_spot(spot):
	if is_mounted:
		return
	current_tower_spot = spot

func unregister_tower_spot(spot):
	if is_mounted:
		return
	if current_tower_spot == spot:
		current_tower_spot = null

# -------------------------------------------------
# MOUNT STATE
# -------------------------------------------------
func set_mount_state(tower: Node3D) -> void:
	mounted_tower = tower
	is_mounted = tower != null
	print("Mount state updated -> mounted_tower:", mounted_tower, " is_mounted:", is_mounted)
