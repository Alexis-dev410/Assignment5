extends Area3D

var player_inside := false
var contained_object: Node3D = null

func _ready():
	connect("body_entered", _on_body_entered)
	connect("body_exited", _on_body_exited)


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.register_tower_spot(self)
		print("Player entered tower spot")


func _on_body_exited(body):
	if body.is_in_group("player"):
		body.unregister_tower_spot(self)
		print("Player left tower spot")
