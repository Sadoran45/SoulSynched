extends Area2D

@export var next_level_path: String = ""

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and body.state == body.PlayerState.BODY:
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			game_manager.complete_level(next_level_path)
