extends CharacterBody2D

@export var speed: float = 100.0
@export var damage: int = 1
@export var is_active: bool = false
@export var detection_radius: float = 300.0
@export var slow_radius: float = 80.0
@export var min_speed_factor: float = 0.05

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var player: Node2D = null
var is_dying: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	set_active(is_active)
	sprite.animation_finished.connect(_on_animation_finished)

func set_active(active: bool) -> void:
	is_active = active
	if not is_node_ready():
		return
	if is_active:
		modulate = Color(1, 1, 1, 1)
	else:
		modulate = Color(0.5, 0.5, 0.5, 0.5)
		velocity = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not is_active or is_dying:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	_find_player()

	if player:
		var distance: float = global_position.distance_to(player.global_position)
		if distance <= detection_radius:
			var chase_dir: float = sign(player.global_position.x - global_position.x)
			var speed_factor: float = clamp(distance / slow_radius, min_speed_factor, 1.0)
			velocity.x = chase_dir * speed * speed_factor
		else:
			velocity.x = move_toward(velocity.x, 0.0, speed * delta * 5.0)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed * delta * 5.0)

	if velocity.x != 0:
		sprite.flip_h = velocity.x < 0
	if not sprite.is_playing() or sprite.animation != "walk":
		sprite.play("walk")

	move_and_slide()

func _find_player() -> void:
	if player and is_instance_valid(player):
		return
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_active and not is_dying and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

func take_damage(_amount: int) -> void:
	if is_dying:
		return
	is_dying = true
	velocity = Vector2.ZERO
	$Hitbox/CollisionShape2D.set_deferred("disabled", true)
	$CollisionShape2D.set_deferred("disabled", true)
	sprite.play("death")
	print("Monster killed!")

func _on_animation_finished() -> void:
	if sprite.animation == "death":
		sprite.stop()
		sprite.frame = sprite.sprite_frames.get_frame_count("death") - 1
