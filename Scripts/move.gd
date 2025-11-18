extends State
class_name Move

@onready var ogre: CharacterBody3D
@onready var nav_agent: NavigationAgent3D = $"../../NavigationAgent3D"

func enter(_msg := {}) -> void:
	if ogre == null:
		ogre = get_parent().get_parent()
		
	if ogre.movement_points.size() == 0:
		state_machine.transition_to("Idle")
	
	$"../../AnimationPlayer".play("walk")
	print("Move")
	select_next_target()
	index = 0
	nav_agent.set_target_position(ogre.movement_points[0].global_position)
	nav_agent.connect("path_changed", Callable(self, "_on_path_changed"))

func _on_path_changed():
	pass

func update(_delta: float) -> void:
	if ogre.health <= 0:
		state_machine.transition_to("Death")
	
	if nav_agent.is_target_reached():
		if index == ogre.movement_points.size() - 1:
			state_machine.transition_to("Attack")
		else:
			select_next_target()
	
	orient()

var index = 0
func select_next_target():
	if ogre.movement_points.size() == 0:
		return
	
	index = (index + 1) % ogre.movement_points.size()
	var next_target = ogre.movement_points[index]
	nav_agent.set_target_position(next_target.global_position)
	print("Moving to next target at index: ", index)

func orient():
	var velocity = ogre.get_velocity()
	ogre.look_at(ogre.global_position + velocity.normalized(), Vector3.UP)
