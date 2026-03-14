extends Node

@export var player_node: CharacterBody2D
@export var spirit_trail_scene: PackedScene

enum GamePhase { SPIRIT_PHASE, BODY_PHASE }
var current_phase = GamePhase.SPIRIT_PHASE

var trails_placed := { 0: false, 1: false, 2: false } # DOUBLE_JUMP, SHIELD, FIREBALL

var trail_actions := {
	"place_double_jump": 0,
	"place_shield": 1,
	"place_fireball": 2,
}

func _ready() -> void:
	add_to_group("game_manager")
	if not player_node.is_node_ready():
		await player_node.ready
	player_node.player_died.connect(restart_level)
	start_spirit_phase()

func restart_level() -> void:
	get_tree().call_deferred("reload_current_scene")

func _input(event: InputEvent) -> void:
	if current_phase == GamePhase.SPIRIT_PHASE:
		for action in trail_actions:
			if event.is_action_pressed(action):
				var trail_type: int = trail_actions[action]
				if not trails_placed[trail_type]:
					place_trail(trail_type)
				break

func start_spirit_phase() -> void:
	current_phase = GamePhase.SPIRIT_PHASE
	player_node.set_state(0) # SPIRIT
	update_label("Spirit Phase: Place Trails (1=Jump 2=Shield 3=Fire)")
	get_tree().call_group("traps", "set_active", false)
	get_tree().call_group("enemies", "set_active", false)

func place_trail(trail_type: int) -> void:
	var trail = spirit_trail_scene.instantiate()
	trail.global_position = player_node.global_position
	trail.type = trail_type
	add_child(trail)
	trails_placed[trail_type] = true

	if trails_placed.values().all(func(v): return v):
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

func complete_level(next_level_path: String) -> void:
	if next_level_path != "" and ResourceLoader.exists(next_level_path):
		get_tree().change_scene_to_file(next_level_path)
	else:
		update_label("You Win!")
		player_node.set_physics_process(false)

func update_label(txt: String) -> void:
	var label = get_node_or_null("../CanvasLayer/Label")
	if label:
		label.text = txt
