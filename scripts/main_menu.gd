extends Control

@onready var title_label: Label = %TitleLabel
@onready var how_to_play_panel: PanelContainer = %HowToPlayPanel
@onready var play_button: Button = %PlayButton

var _time: float = 0.0

func _ready() -> void:
	how_to_play_panel.visible = false
	play_button.grab_focus()

func _process(delta: float) -> void:
	_time += delta
	title_label.modulate.a = 0.85 + 0.15 * sin(_time * 2.0)

func _on_play_pressed() -> void:
	SceneManager.go_to("res://scenes/level1.tscn")

func _on_how_to_play_pressed() -> void:
	how_to_play_panel.visible = true

func _on_close_pressed() -> void:
	how_to_play_panel.visible = false

func _on_quit_pressed() -> void:
	get_tree().quit()
