extends Area2D

@export var is_active: bool = false
@export var damage: int = 1

func set_active(active: bool) -> void:
	is_active = active
	if is_active:
		modulate = Color(1, 1, 1, 1) # Normal color
	else:
		modulate = Color(0.5, 0.5, 0.5, 0.5) # Deactivated look

func _on_body_entered(body: Node2D) -> void:
	if is_active and body.has_method("take_damage"):
		body.take_damage(damage)
