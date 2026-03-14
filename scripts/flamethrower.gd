extends StaticBody2D

@export var is_active: bool = false
@export var cycle_time: float = 2.0
@export var active_time: float = 1.0

@onready var fire_area: Area2D = $FireArea
@onready var timer: Timer = $Timer
@onready var fire_sprite: Sprite2D = $FireArea/FireSprite

var is_firing: bool = false

func _ready() -> void:
	set_active(is_active)

func set_active(active: bool) -> void:
	is_active = active
	if not is_node_ready():
		return
		
	if is_active:
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
	fire_sprite.visible = true

func stop_firing() -> void:
	is_firing = false
	fire_area.monitoring = false
	fire_sprite.visible = false

func _on_fire_area_body_entered(body: Node2D) -> void:
	if is_active and is_firing and body.has_method("take_damage"):
		body.take_damage(1)
