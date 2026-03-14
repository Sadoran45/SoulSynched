extends CharacterBody2D

@export var speed: float = 100.0
@export var damage: int = 1
@export var is_active: bool = false

var direction: int = 1
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite: Sprite2D = $Sprite2D
@onready var ray_cast: RayCast2D = $RayCast2D # To detect edges

func _ready() -> void:
	set_active(is_active)

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
	if not is_active:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_wall() or not ray_cast.is_colliding():
		direction *= -1
		ray_cast.position.x *= -1
		ray_cast.target_position.x *= -1 # Ensure raycast stays ahead

	velocity.x = direction * speed
	move_and_slide()

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_active and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)

func take_damage(_amount: int) -> void:
	# Monsters die in 1 hit from fireball
	print("Monster killed!")
	queue_free()
