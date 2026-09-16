extends Node

@export var start_button : Button
@export_dir var game_dir : String
@export var shop_button : Button
@export_dir var shop_dir : String

func _ready() -> void:
	start_button.button_down.connect(start_game)
	shop_button.button_down.connect(shop_scene)
	
func start_game() -> void:
	start_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	SceneManager.change_scene(game_dir)

func shop_scene() -> void:
	shop_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	SceneManager.change_scene(shop_dir)
