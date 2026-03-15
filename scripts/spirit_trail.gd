extends Area2D

enum TrailType { DOUBLE_JUMP, SHIELD, FIREBALL }
@export var type: TrailType = TrailType.DOUBLE_JUMP

@onready var sprite: Sprite2D = $Sprite2D

var _jump_icon: Texture2D = preload("res://resources/icons/jump_icon.png")
var _shield_icon: Texture2D = preload("res://resources/icons/guard_icon.png")
var _fireball_icon: Texture2D = preload("res://resources/icons/fireball_icon.png")

var is_rotating: bool = false
var rotation_indicator: Line2D
var _bob_time: float = 0.0
var _bob_amplitude: float = 6.0
var _bob_speed: float = 2.0

func _ready() -> void:
	match type:
		TrailType.DOUBLE_JUMP: sprite.texture = _jump_icon
		TrailType.SHIELD: sprite.texture = _shield_icon
		TrailType.FIREBALL: sprite.texture = _fireball_icon
	sprite.modulate = Color(1, 1, 1, 1)

func _process(_delta: float) -> void:
	_bob_time += _delta
	sprite.offset.y = sin(_bob_time * _bob_speed) * _bob_amplitude

	if is_rotating:
		var mouse_pos = get_global_mouse_position()
		var direction = mouse_pos - global_position
		if direction.length() > 5.0:
			rotation = direction.angle()

func start_rotating() -> void:
	is_rotating = true
	rotation_indicator = Line2D.new()
	rotation_indicator.points = PackedVector2Array([Vector2.ZERO, Vector2(60, 0)])
	rotation_indicator.width = 3.0
	match type:
		TrailType.DOUBLE_JUMP: rotation_indicator.default_color = Color(0.2, 1.0, 0.2)
		TrailType.SHIELD: rotation_indicator.default_color = Color(1.0, 1.0, 0.2)
		TrailType.FIREBALL: rotation_indicator.default_color = Color(1.0, 0.2, 0.2)
	add_child(rotation_indicator)

func confirm_rotation() -> void:
	is_rotating = false
	if rotation_indicator:
		rotation_indicator.queue_free()
		rotation_indicator = null

func _on_body_entered(body: Node2D) -> void:
	# Only collect if it's the player AND they are fully in Body mode
	if body.is_in_group("player"):
		if body.get("state") == 1: # PlayerState.BODY
			if not body.get("spawn_protection"):
				var skill_name = ""
				match type:
					TrailType.DOUBLE_JUMP: skill_name = "double_jump"
					TrailType.SHIELD: skill_name = "shield"
					TrailType.FIREBALL: skill_name = "fireball"

				var trail_direction = Vector2.RIGHT.rotated(rotation)
				body.activate_skill(skill_name, trail_direction)
				queue_free()
