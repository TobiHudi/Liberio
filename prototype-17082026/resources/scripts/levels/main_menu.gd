extends Node

@export var start_button : Button
@export_dir var game_dir : String
@export var shop_button : Button
@export_dir var shop_dir : String
@export var settings_button : Button
@export_dir var settings_dir : String

func _ready() -> void:
	start_button.button_down.connect(start_game)
	shop_button.button_down.connect(shop_scene)
	settings_button.button_down.connect(settings_scene)
	
func start_game() -> void:
	start_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	SceneManager.change_scene(game_dir)

func shop_scene() -> void:
	shop_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	SceneManager.change_scene(shop_dir)

func settings_scene() -> void:
	settings_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	SceneManager.change_scene(settings_dir)
