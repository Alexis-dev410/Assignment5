extends Area3D

var player_inside := false

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_inside = true
		body.register_tower_spot(self)
		print("Player entered tower spot")

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_inside = false
		body.unregister_tower_spot(self)
		print("Player left tower spot")
