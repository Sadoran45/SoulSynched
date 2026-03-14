extends StaticBody2D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 2.0
@export var is_active: bool = false

@onready var timer: Timer = $Timer
@onready var muzzle: Marker2D = $Muzzle

func _ready() -> void:
	set_active(is_active)

func set_active(active: bool) -> void:
	is_active = active
	if not is_node_ready():
		return
	
	if is_active:
		modulate = Color(1, 1, 1, 1)
		timer.wait_time = fire_rate
		timer.start()
	else:
		modulate = Color(0.5, 0.5, 0.5, 0.5)
		timer.stop()

func _on_timer_timeout() -> void:
	if is_active:
		fire()

func fire() -> void:
	if not projectile_scene: return
	var proj = projectile_scene.instantiate()
	proj.global_position = muzzle.global_position
	# Turrets shoot away from their rotation
	proj.velocity = Vector2.RIGHT.rotated(rotation) * proj.speed
	proj.shooter = self # Turret is the shooter
	get_parent().add_child(proj)

func take_damage(_amount: int) -> void:
	# Turrets die in 1 hit from fireball
	print("Turret destroyed!")
	queue_free()
