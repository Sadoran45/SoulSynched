extends Area2D

@export var speed: float = 400.0
@export var damage: int = 1
@export var max_range: float = 750.0
var velocity: Vector2 = Vector2.ZERO
var shooter: Node = null
var distance_traveled: float = 0.0

func _physics_process(delta: float) -> void:
	var movement := velocity * delta
	global_position += movement
	distance_traveled += movement.length()
	if distance_traveled >= max_range:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body == shooter:
		return
		
	# If the shooter was a player, don't hit other players
	if shooter and shooter.is_in_group("player") and body.is_in_group("player"):
		return
		
	if body.has_method("take_damage"):
		body.take_damage(damage)
		queue_free()
	elif body is StaticBody2D:
		queue_free()
