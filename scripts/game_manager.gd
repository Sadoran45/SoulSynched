extends Node

@export var player_node: CharacterBody2D
@export var spirit_trail_scene: PackedScene

enum GamePhase { SPIRIT_PHASE, BODY_PHASE }
var current_phase = GamePhase.SPIRIT_PHASE

var trail_types_to_place = [0, 1, 2] # DOUBLE_JUMP, SHIELD, FIREBALL
var current_trail_index = 0

func _ready() -> void:
	if not player_node.is_node_ready():
		await player_node.ready
	player_node.player_died.connect(restart_level)
	start_spirit_phase()

func restart_level() -> void:
	get_tree().call_deferred("reload_current_scene")

func _input(event: InputEvent) -> void:
	if current_phase == GamePhase.SPIRIT_PHASE:
		if event.is_action_pressed("ui_accept"):
			place_trail()

func start_spirit_phase() -> void:
	current_phase = GamePhase.SPIRIT_PHASE
	player_node.set_state(0) # SPIRIT
	update_label("Spirit Phase: Place 3 Trails (Space)")
	get_tree().call_group("traps", "set_active", false)
	get_tree().call_group("enemies", "set_active", false)

func place_trail() -> void:
	if current_trail_index < trail_types_to_place.size():
		var trail = spirit_trail_scene.instantiate()
		trail.global_position = player_node.global_position
		trail.type = trail_types_to_place[current_trail_index]
		add_child(trail)
		current_trail_index += 1
		
		if current_trail_index >= trail_types_to_place.size():
			start_body_phase()

func start_body_phase() -> void:
	current_phase = GamePhase.BODY_PHASE
	update_label("Body Phase: Reach the Door!")
	
	# 1. Warp the player
	var start_marker = get_tree().get_first_node_in_group("start_marker")
	if start_marker:
		player_node.global_position = start_marker.global_position
	
	# 2. Wait a frame to ensure the position is updated in physics
	await get_tree().process_frame
	
	# 3. Enable Body mode
	player_node.set_state(1) # BODY
	
	get_tree().call_group("traps", "set_active", true)
	get_tree().call_group("enemies", "set_active", true)

func update_label(txt: String) -> void:
	var label = get_node_or_null("../CanvasLayer/Label")
	if label:
		label.text = txt
