extends CharacterBody3D

@export var movement_points: Array[Node3D]
@export var health: int = 10
@export var movement_speed: float = 15.0
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	actor_setup.call_deferred()
	nav_agent.set_navigation_map(get_viewport().get_world_3d().get_navigation_map())

func actor_setup():
	await get_tree().physics_frame

func set_movement_target(movement_target: Vector3):
	nav_agent.set_target_position(movement_target)

func _physics_process(delta: float) -> void:
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = nav_agent.get_next_path_position()
	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	var vel = velocity
	move_and_slide()
