extends StaticBody2D

@export var is_active: bool = false
@export var cycle_time: float = 5.0
@export var active_time: float = 3.0
@export var flame_range: float = 150.0
@export var start_on: bool = false
@export var start_delay: float = 0.0

@onready var fire_area: Area2D = $FireArea
@onready var timer: Timer = $Timer
@onready var flame_sprite: AnimatedSprite2D = $FireArea/FlameSprite
@onready var fire_collision: CollisionShape2D = $FireArea/CollisionShape2D

var is_firing: bool = false

func _ready() -> void:
	_setup_flame_sprite()
	_setup_fire_collision()
	set_active(is_active)

func _setup_flame_sprite() -> void:
	# 1000 is the width of the flame atlas texture
	var scale_x = flame_range / 1000.0
	flame_sprite.scale = Vector2(scale_x, 0.45)
	flame_sprite.position = Vector2(flame_range / 2.0, 0.0)
	flame_sprite.visible = false
	flame_sprite.stop()

func _setup_fire_collision() -> void:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(flame_range, 90.0)
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
	flame_sprite.visible = true
	flame_sprite.play("fire")

func stop_firing() -> void:
	is_firing = false
	fire_area.monitoring = false
	flame_sprite.stop()
	flame_sprite.visible = false

func _on_fire_area_body_entered(body: Node2D) -> void:
	if is_active and is_firing and body.has_method("take_damage"):
		body.take_damage(1)
