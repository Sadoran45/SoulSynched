extends Camera2D

func _ready() -> void:
	# Wait a frame so the level tree is fully ready
	await get_tree().process_frame
	_apply_limits()

func _apply_limits() -> void:
	var limits_node = get_tree().current_scene.find_child("camera_limits", true, false)
	if not limits_node:
		return

	var markers = limits_node.get_children()
	if markers.size() < 2:
		return

	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)

	for marker in markers:
		var pos = marker.global_position
		min_pos.x = min(min_pos.x, pos.x)
		min_pos.y = min(min_pos.y, pos.y)
		max_pos.x = max(max_pos.x, pos.x)
		max_pos.y = max(max_pos.y, pos.y)

	limit_left = int(min_pos.x)
	limit_top = int(min_pos.y)
	limit_right = int(max_pos.x)
	limit_bottom = int(max_pos.y)
