extends Node

@export var back_button : Button

var bus_index = AudioServer.get_bus_index("Master")

var settings_container : CenterContainer = CenterContainer.new()
var settings_menu_panel : NinePatchRect = NinePatchRect.new()
var margin_container : MarginContainer = MarginContainer.new()
var button_v_box_container : VBoxContainer = VBoxContainer.new()
var vsync_button : CheckButton = CheckButton.new()
var reset_progress_button : Button = Button.new()
var reset_all_shelves_button : Button = Button.new()
var reset_all_upgrades_button : Button = Button.new()
var give_all_shelves_button : Button = Button.new()
var give_all_upgrades_button : Button = Button.new()
var give_1k_points_button : Button = Button.new()

func _ready() -> void:
	set_up_settings_menu()
	back_button.button_down.connect(go_back)

func set_up_settings_menu() -> void:
	add_child(settings_container)
	settings_container.add_child(settings_menu_panel)
	settings_menu_panel.add_child(margin_container)
	margin_container.add_child(button_v_box_container)
	button_v_box_container.add_child(vsync_button)
	button_v_box_container.add_child(reset_progress_button)
	button_v_box_container.add_child(reset_all_shelves_button)
	button_v_box_container.add_child(reset_all_upgrades_button)
	button_v_box_container.add_child(give_all_shelves_button)
	button_v_box_container.add_child(give_all_upgrades_button)
	button_v_box_container.add_child(give_1k_points_button)
	
	settings_container.use_top_left = true
	settings_menu_panel.texture = load("res://assets/textures/debug/debug_border.png")
	settings_menu_panel.custom_minimum_size = Vector2(250, 300)
	settings_menu_panel.set_patch_margin(SIDE_BOTTOM, 20)
	settings_menu_panel.set_patch_margin(SIDE_TOP, 20)
	settings_menu_panel.set_patch_margin(SIDE_LEFT, 20)
	settings_menu_panel.set_patch_margin(SIDE_RIGHT, 20)
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	margin_container.add_theme_constant_override("margin_bottom", 10)
	margin_container.add_theme_constant_override("margin_top", 10)
	margin_container.add_theme_constant_override("margin_left", 10)
	margin_container.add_theme_constant_override("margin_right", 10)
	vsync_button.text = "V-Sync"
	vsync_button.button_up.connect(vsync_switch.bind(vsync_button))
	reset_progress_button.text = "Reset ALL Progress"
	reset_progress_button.button_up.connect(reset_progress)
	reset_all_shelves_button.text = "Reset ALL Shelf Progress"
	reset_all_shelves_button.button_up.connect(reset_all_shelves)
	reset_all_upgrades_button.text = "Reset ALL Upgrade Progress"
	reset_all_upgrades_button.button_up.connect(reset_all_upgrades)
	give_all_shelves_button.text = "Give ALL Shelves to Player"
	give_all_shelves_button.button_up.connect(give_all_shelves)
	give_all_upgrades_button.text = "Give ALL Upgrades to Player"
	give_all_upgrades_button.button_up.connect(give_all_upgrades)
	give_1k_points_button.text = "Give 1.000 Points to Player"
	give_1k_points_button.button_up.connect(give_1k_points)
	
	settings_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	margin_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	button_v_box_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	
	if DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED:
		vsync_button.button_pressed = true
	
func vsync_switch(vsync_button : CheckButton) -> void:
	if vsync_button.button_pressed == true:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
		print_debug("VSYNC ENABLED")
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		print_debug("VSYNC DISABLED")


func reset_progress() -> void:
	#Resets Shelves.
	for item in ResourceTable.SHELVES.keys():
		ResourceTable.SHELVES.get(item).has_shelf = false
	GameManager.selected_shelf = "dusty_shelf"
	#Resets Upgrades
	for upgrade in ResourceTable.UPGRADES.keys():
		for item in ResourceTable.UPGRADES.get(upgrade):
			item.has_upgrade = false
	GameManager.update_upgrades()
	GameManager.player_points = 0
func reset_all_shelves() -> void:
	#Resets all Shelves.
	for item in ResourceTable.SHELVES.keys():
		ResourceTable.SHELVES.get(item).has_shelf = true
	GameManager.selected_shelf = "dusty_shelf"
func reset_all_upgrades() -> void:
	#Gives all Upgrades.
	for upgrade in ResourceTable.UPGRADES.keys():
		for item in ResourceTable.UPGRADES.get(upgrade):
			item.has_upgrade = false
	GameManager.update_upgrades()
func give_all_shelves() -> void:
	#Gives all Shelves.
	for item in ResourceTable.SHELVES.keys():
		ResourceTable.SHELVES.get(item).has_shelf = true
	GameManager.selected_shelf = "super_shelf"
func give_all_upgrades() -> void:
	#Gives all Upgrades.
	for upgrade in ResourceTable.UPGRADES.keys():
		for item in ResourceTable.UPGRADES.get(upgrade):
			item.has_upgrade = true
	GameManager.update_upgrades()
func give_1k_points() -> void:
	GameManager.player_points += 1000

func go_back() -> void:
	SceneManager.change_scene("res://scenes/levels/main_menu.tscn")
