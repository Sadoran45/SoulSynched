extends Node

var _color_rect: ColorRect
var _anim_player: AnimationPlayer
var _next_scene_path: String = ""

func _ready() -> void:
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 10
	add_child(canvas_layer)

	_color_rect = ColorRect.new()
	_color_rect.color = Color.BLACK
	_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_color_rect.modulate.a = 0.0
	canvas_layer.add_child(_color_rect)

	_anim_player = AnimationPlayer.new()
	canvas_layer.add_child(_anim_player)

	var anim_lib = AnimationLibrary.new()

	# fade_out: alpha 0 → 1
	var fade_out = Animation.new()
	fade_out.length = 0.3
	var track_out = fade_out.add_track(Animation.TYPE_VALUE)
	fade_out.track_set_path(track_out, ^".:modulate:a")
	fade_out.track_insert_key(track_out, 0.0, 0.0)
	fade_out.track_insert_key(track_out, 0.3, 1.0)
	fade_out.value_track_set_update_mode(track_out, Animation.UPDATE_CONTINUOUS)
	anim_lib.add_animation("fade_out", fade_out)

	# fade_in: alpha 1 → 0
	var fade_in = Animation.new()
	fade_in.length = 0.3
	var track_in = fade_in.add_track(Animation.TYPE_VALUE)
	fade_in.track_set_path(track_in, ^".:modulate:a")
	fade_in.track_insert_key(track_in, 0.0, 1.0)
	fade_in.track_insert_key(track_in, 0.3, 0.0)
	fade_in.value_track_set_update_mode(track_in, Animation.UPDATE_CONTINUOUS)
	anim_lib.add_animation("fade_in", fade_in)

	_anim_player.add_animation_library("", anim_lib)
	_anim_player.root_node = _anim_player.get_path_to(_color_rect)
	_anim_player.animation_finished.connect(_on_animation_finished)

func go_to(path: String) -> void:
	_next_scene_path = path
	_color_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	_anim_player.play("fade_out")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		get_tree().change_scene_to_file(_next_scene_path)
		_anim_player.play("fade_in")
	elif anim_name == "fade_in":
		_color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
