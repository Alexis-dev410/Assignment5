extends State
class_name Attack

@onready var ogre: CharacterBody3D = $"../.."

func enter(_msg := {}) -> void:
	$"../../AnimationPlayer".play("attack")
	$"../../AnimationPlayer".connect("animation_finished", Callable(self, "_on_animation_finished"))
	print("attack")

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "attack":
		ogre.queue_free()
