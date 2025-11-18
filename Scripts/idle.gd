extends State
class_name Idle

@onready var ogre: CharacterBody3D

func enter(_msg := {}) -> void:
	if ogre == null:
		ogre = get_parent().get_parent()
		
	$"../../AnimationPlayer".play("idle")
	print("Idle")
	if ogre.movement_points.size() > 0:
		state_machine.transition_to("Move")

func update(_delta: float) -> void:
	if ogre.health <= 0:
		state_machine.transition_to("Death")
		return
