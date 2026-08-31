extends Node

@export var start_button : Button
@export_dir var game_dir : String

func _ready() -> void:
	start_button.button_down.connect(start_game)
	
func start_game() -> void:
	SceneManager.change_scene(game_dir)
