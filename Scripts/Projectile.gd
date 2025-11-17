extends Area3D

@export var speed: float = 5.0
@export var lifetime: float = 5.0
@export var damage: int = 1

var direction: Vector3 = Vector3.ZERO
var mesh_offset := Vector3(0, 0, deg_to_rad(90))
@onready var mesh: Node3D = $Ballista_arrow

func _ready():
	# Start lifetime timer
	if lifetime > 0.0:
		call_deferred("_start_lifetime_timer")

func _start_lifetime_timer():
	await get_tree().create_timer(lifetime).timeout
	if is_instance_valid(self):
		queue_free()

func set_direction(dir: Vector3) -> void:
	direction = dir.normalized()

func set_damage(dmg: int) -> void:
	damage = dmg

func _physics_process(delta: float) -> void:
	if direction != Vector3.ZERO:
		global_position += direction * speed * delta

		# Rotate mesh if it exists
		if mesh != null:
			mesh.look_at(global_position + direction, Vector3.UP)
			mesh.rotate_z(mesh_offset.z)

func _on_body_entered(body: Node) -> void:
	# Apply damage only if the body has a health property
	if "health" in body:
		body.health -= damage
		print("Damage Taken")
	
	# Always free projectile on hit
	queue_free()
