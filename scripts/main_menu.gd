extends Control

@onready var play_button: TextureButton = $Play
@onready var credits_button: TextureButton = $Credits
@onready var leave_button: TextureButton = $Leave

var _time: float = 0.0

func _ready() -> void:
	play_button.grab_focus()

func _process(delta: float) -> void:
	_time += delta

func _on_play_pressed() -> void:
	SceneManager.go_to("res://scenes/level1.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_credits_pressed() -> void:
	SceneManager.go_to("res://scenes/credits.tscn")
	pass # Replace with function body.


func _on_leave_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.
