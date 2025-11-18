extends Node3D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.5  # seconds between shots
@export var projectile_damage: int = 1
var can_shoot: bool = true
