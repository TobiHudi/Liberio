extends Node

@export var retry_menu_button : Button
@export var main_menu_button : Button
@export_dir var retry_menu_path : String
@export_dir var main_menu_path : String

func _ready() -> void:
	retry_menu_button.button_down.connect(retry_button)
	main_menu_button.button_down.connect(main_menu)
	
func retry_button() -> void:
	SceneManager.change_scene(retry_menu_path)
	GameManager.selected_item = ""
func main_menu() -> void:
	SceneManager.change_scene(main_menu_path)
	GameManager.selected_item = ""
