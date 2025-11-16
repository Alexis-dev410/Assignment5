extends State
class_name death

@onready var ogre: CharacterBody3D = $"../.."

func enter(_msg := {}) -> void:
	$"../../AnimationPlayer".play("death")
	$"../../AnimationPlayer".connect("animation_finished", Callable(self, "_on_animation_finished"))

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "death":
		ogre.queue_free()
