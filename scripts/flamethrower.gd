extends StaticBody2D

@export var is_active: bool = false
@export var cycle_time: float = 5.0
@export var active_time: float = 3.0
@export var flame_range: float = 150.0
@export var start_on: bool = false
@export var start_delay: float = 0.0

@onready var fire_area: Area2D = $FireArea
@onready var timer: Timer = $Timer
@onready var particles: GPUParticles2D = $FireArea/FlameParticles
@onready var fire_collision: CollisionShape2D = $FireArea/CollisionShape2D

var is_firing: bool = false

func _ready() -> void:
	_setup_particles()
	_setup_fire_collision()
	set_active(is_active)

func _setup_particles() -> void:
	var mat := ParticleProcessMaterial.new()
	mat.direction = Vector3(1, 0, 0)
	mat.spread = 15.0
	mat.initial_velocity_min = 250.0
	mat.initial_velocity_max = 300.0
	mat.gravity = Vector3.ZERO
	mat.scale_min = 0.8
	mat.scale_max = 1.2

	# Color ramp: orange → red → fade out
	var gradient := Gradient.new()
	gradient.set_color(0, Color(1.0, 0.6, 0.0, 1.0))
	gradient.add_point(0.5, Color(1.0, 0.2, 0.0, 0.8))
	gradient.set_color(gradient.get_point_count() - 1, Color(0.8, 0.0, 0.0, 0.0))
	var grad_tex := GradientTexture1D.new()
	grad_tex.gradient = gradient
	mat.color_ramp = grad_tex

	# Scale curve: shrink over lifetime
	var scale_curve := CurveTexture.new()
	var curve := Curve.new()
	curve.add_point(Vector2(0.0, 1.0))
	curve.add_point(Vector2(1.0, 0.3))
	scale_curve.curve = curve
	mat.scale_curve = scale_curve

	particles.process_material = mat
	particles.amount = 30
	particles.lifetime = flame_range / 275.0
	particles.emitting = false

	# GPUParticles2D uses texture, not draw passes
	var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)
	particles.texture = ImageTexture.create_from_image(img)

func _setup_fire_collision() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(flame_range, 30.0)
	fire_collision.shape = shape
	fire_collision.position = Vector2(flame_range / 2.0, 0.0)

func set_active(active: bool) -> void:
	is_active = active
	if not is_node_ready():
		return

	if is_active:
		if start_on:
			start_firing()
			timer.wait_time = active_time
			timer.start()
		elif start_delay > 0.0:
			timer.wait_time = start_delay
			timer.start()
		else:
			timer.start()
		modulate = Color(1, 1, 1, 1)
	else:
		timer.stop()
		stop_firing()
		modulate = Color(0.5, 0.5, 0.5, 0.5)

func _on_timer_timeout() -> void:
	if is_firing:
		stop_firing()
		timer.wait_time = cycle_time - active_time
	else:
		start_firing()
		timer.wait_time = active_time
	timer.start()

func start_firing() -> void:
	is_firing = true
	fire_area.monitoring = true
	particles.emitting = true

func stop_firing() -> void:
	is_firing = false
	fire_area.monitoring = false
	particles.emitting = false

func _on_fire_area_body_entered(body: Node2D) -> void:
	if is_active and is_firing and body.has_method("take_damage"):
		body.take_damage(1)
