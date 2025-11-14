extends CharacterBody3D

@export var movement_points: Array[Node3D]
@export var movement_speed: float = 2.0
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D

func _ready():
	actor_setup.call_deferred()

func actor_setup():
	await get_tree().physics_frame

func _physics_process(delta: float) -> void:
	if nav_agent.is_navigation_finished():
		return
	
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = nav_agent.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * movement_speed
	var vel = velocity
	move_and_slide()
