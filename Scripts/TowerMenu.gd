extends Panel

signal request_close_menu
signal tower_selected(tower_scene_path: String)

func _ready():
	visible = false

func open_menu():
	visible = true

func close_menu():
	visible = false
	emit_signal("request_close_menu")

# --- Button Callbacks ---

func _on_tower_button_1_pressed() -> void:
	print("Tower 1 selected (Ballista)")
	emit_signal("tower_selected", "res://Scenes/Ballista.tscn")

func _on_tower_button_2_pressed() -> void:
	print("Tower 2 selected (Cannon)")
	emit_signal("tower_selected", "res://Scenes/Cannon.tscn")

func _on_cancel_button_pressed() -> void:
	close_menu()
