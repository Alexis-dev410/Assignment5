extends Panel

signal request_close_menu
signal destroy_tower
signal mount_tower

func _ready() -> void:
	visible = false

func open_menu():
	visible = true

func close_menu():
	visible = false
	emit_signal("request_close_menu")

func _on_cancel_button_pressed() -> void:
	close_menu()

func _on_destroy_tower_pressed() -> void:
	print("DestroyTower button pressed")
	emit_signal("destroy_tower")

func _on_mount_tower_pressed() -> void:
	print("MountTower button pressed (UI)")
	emit_signal("mount_tower")
