extends Node

@export var base_max_hp := 5
var base_hp := 5
var kills := 0

@onready var lose_menu := $"../TowerCanvas/LoseMenu"
@onready var kills_label := $"../TowerCanvas/LoseMenu/KillsLabel"
@onready var church_hp_label := $"../TowerCanvas/ChurchHpLabel"

func _ready():
	base_hp = base_max_hp
	lose_menu.visible = false
	update_kills_label()
	update_church_hp_label()

func ogre_reached_church():
	base_hp -= 1
	print("Church HP:", base_hp)

	update_church_hp_label()

	if base_hp <= 0:
		trigger_game_over()

func register_kill():
	kills += 1
	update_kills_label()

func update_kills_label():
	if kills_label:
		kills_label.text = "Kills: %d" % kills

func update_church_hp_label():
	if church_hp_label:
		church_hp_label.text = "Church HP: %d" % base_hp

func trigger_game_over():
	lose_menu.visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
