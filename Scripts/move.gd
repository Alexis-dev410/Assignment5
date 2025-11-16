extends State
class_name Move

@onready var ogre: CharacterBody3D = $"../.."
@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"

func enter(_msg := {}) -> void:
	if ogre.movement_points.size() == 0:
		state_machine.transition_to("Idle")
	
	$"../../AnimationPlayer".play("walk")
	print("Move")
	select_next_target()

func update(_delta: float) -> void:
	if ogre.health <= 0:
		state_machine.transition_to("Death")
	
	if nav_agent.is_target_reached():
		select_next_target()
	
	orient()

var index = 0
func select_next_target():
	if ogre.movement_points.size() == 0:
		return
	
	index += 1
	var next_target = ogre.movement_points[index % ogre.movement_points.size()]
	nav_agent.set_target_position(next_target.global_position)

func orient():
	var velocity = ogre.get_velocity()
	ogre.look_at(ogre.global_position + velocity.normalized(), Vector3.UP)
