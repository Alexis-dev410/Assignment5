extends Node3D

@export var ogre: PackedScene
@export var spawn_interval: float = 5.0
@export var spawn_chance: float = 1.0

@onready var spawn_timer := $SpawnTimer

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	print("RNG check to spawn")
	if randf() <= spawn_chance:
		spawn_ogre()

func spawn_ogre():
	print("Spawning ogre")
	var ogre_instance = ogre.instantiate()
	
	var model = ogre_instance.get_node("blockbench_export")
	model.scale *= 2.5
	ogre_instance.get_node("CollisionShape3D").scale *= 2.5
	ogre_instance.global_transform.origin = global_transform.origin + Vector3(0, -1, 0)
	
	get_tree().current_scene.add_child(ogre_instance)
	
	print("Assigning movement points")
	var movement_points: Array[Node3D] = [
		get_node("../Region1/Target"),
		get_node("../Region1/Target2"),
		get_node("../Region1/Target3")
	]
	ogre_instance.movement_points = movement_points.duplicate(true)
	
	
	var sm = ogre_instance.get_node("StateMach")
	sm.state.enter({"ogre": ogre_instance})
