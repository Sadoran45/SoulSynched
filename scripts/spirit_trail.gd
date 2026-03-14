extends Area2D

enum TrailType { DOUBLE_JUMP, SHIELD, FIREBALL }
@export var type: TrailType = TrailType.DOUBLE_JUMP

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	match type:
		TrailType.DOUBLE_JUMP: sprite.modulate = Color(0.2, 1.0, 0.2)
		TrailType.SHIELD: sprite.modulate = Color(1.0, 1.0, 0.2)
		TrailType.FIREBALL: sprite.modulate = Color(1.0, 0.2, 0.2)

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
				
				body.activate_skill(skill_name)
				queue_free()
