extends State
class_name Idle

@onready var ogre: CharacterBody3D = $"../.."

func enter(_msg := {}) -> void:
	$"../../AnimationPlayer".play("idle")
	print("Idle")
	if ogre.movement_points.size() > 0:
		state_machine.transition_to("Move")
