extends Area2D

@export var next_level_path: String = ""

var _door_open_texture: Texture2D = preload("res://resources/door/door_open.png")
var _is_opening: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _is_opening:
		return
	if body.is_in_group("player") and body.state == body.PlayerState.BODY:
		_is_opening = true
		_open_door_sequence(body)

func _open_door_sequence(player: CharacterBody2D) -> void:
	# Wait for the player to land if they're in the air
	while not player.is_on_floor():
		await get_tree().process_frame
	player.velocity = Vector2.ZERO
	player.set_physics_process(false)
	$Sprite2D.texture = _door_open_texture
	await get_tree().create_timer(0.8).timeout
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.complete_level(next_level_path)
