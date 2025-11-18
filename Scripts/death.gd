extends State
class_name death

@onready var ogre: CharacterBody3D

func enter(_msg := {}) -> void:
	if ogre == null:
		ogre = get_parent().get_parent()
		
	$"../../AnimationPlayer".play("death")
	$"../../AnimationPlayer".connect("animation_finished", Callable(self, "_on_animation_finished"))
	print("dead")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		ogre.queue_free()
