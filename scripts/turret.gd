extends StaticBody2D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 1.33
@export var is_active: bool = false
@export var max_shots: int = 3
@export var reload_time: float = 3.0

@onready var timer: Timer = $Timer
@onready var muzzle: Marker2D = $Muzzle

var shots_fired: int = 0
var is_reloading: bool = false
var reload_elapsed: float = 0.0

func _ready() -> void:
	set_active(is_active)

func _process(delta: float) -> void:
	if is_reloading:
		reload_elapsed += delta
		queue_redraw()
		if reload_elapsed >= reload_time:
			is_reloading = false
			shots_fired = 0
			queue_redraw()
			if is_active:
				timer.wait_time = fire_rate
				timer.start()

func set_active(active: bool) -> void:
	is_active = active
	if not is_node_ready():
		return

	if is_active:
		modulate = Color(1, 1, 1, 1)
		if not is_reloading:
			timer.wait_time = fire_rate
			timer.start()
	else:
		modulate = Color(0.5, 0.5, 0.5, 0.5)
		timer.stop()
		is_reloading = false
		shots_fired = 0
		reload_elapsed = 0.0
		queue_redraw()

func _on_timer_timeout() -> void:
	if is_active:
		fire()

func fire() -> void:
	if not projectile_scene: return
	var player = get_tree().get_first_node_in_group("player")
	if not player: return
	var proj = projectile_scene.instantiate()
	proj.global_position = muzzle.global_position
	var direction = (player.global_position - muzzle.global_position).normalized()
	proj.velocity = direction * proj.speed
	proj.rotation = direction.angle()
	proj.shooter = self
	get_parent().add_child(proj)

	shots_fired += 1
	if shots_fired >= max_shots:
		timer.stop()
		is_reloading = true
		reload_elapsed = 0.0

func _draw() -> void:
	if not is_reloading:
		return
	var radius: float = 20.0
	var width: float = 3.0
	var bg_color := Color(1, 1, 1, 0.2)
	var fill_color := Color(1, 1, 1, 0.6)
	var center := Vector2.ZERO
	# Background circle
	draw_arc(center, radius, 0, TAU, 32, bg_color, width)
	# Progress arc
	var progress: float = clampf(reload_elapsed / reload_time, 0.0, 1.0)
	if progress > 0.0:
		draw_arc(center, radius, -PI / 2, -PI / 2 + progress * TAU, 32, fill_color, width)

func take_damage(_amount: int) -> void:
	print("Turret destroyed!")
	queue_free()
