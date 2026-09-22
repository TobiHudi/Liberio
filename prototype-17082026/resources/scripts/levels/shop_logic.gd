extends Node

@export var back_button : Button
@export_dir var main_menu_scene : String

var shop_container : Container = Container.new()
var shop_margin_container : MarginContainer = MarginContainer.new()
var shop_center_container : CenterContainer = CenterContainer.new()
var shelf_grid_container : GridContainer = GridContainer.new()
var upgrades_grid_container : GridContainer = GridContainer.new()

enum CurrentTab { shelves, upgrades }
enum AnimationState { button_press_animation, success_animation, failure_animation }

signal update_selected_shelf

func _ready() -> void:
	back_button.button_down.connect(go_back_to_main_menu)
	set_up_tabs_menu()
	set_up_shop()
	set_up_shelves_menu()
	set_up_upgrades_menu()

func set_up_tabs_menu() -> void:
	var tab_container : Container = Container.new()
	var tab_center_container : CenterContainer = CenterContainer.new()
	var tab_h_box_container : HBoxContainer = HBoxContainer.new()
	var shelf_button : Button = Button.new()
	var upgrades_button : Button = Button.new()
	
	add_child(tab_container)
	tab_container.add_child(tab_center_container)
	tab_center_container.add_child(tab_h_box_container)
	tab_h_box_container.add_child(shelf_button)
	tab_h_box_container.add_child(upgrades_button)
	
	tab_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	tab_container.set_position(Vector2(tab_container.position.x, tab_container.position.y - 130))
	tab_center_container.use_top_left = true
	shelf_button.custom_minimum_size = Vector2(100, 50)
	shelf_button.text = "Shelves"
	shelf_button.pivot_offset_ratio = Vector2(0.5, 0.5)
	upgrades_button.custom_minimum_size = Vector2(100, 50)
	upgrades_button.text = "Upgrades"
	upgrades_button.pivot_offset_ratio = Vector2(0.5, 0.5)
	
	shelf_button.button_up.connect(shelf_menu.bind(tab_container, shelf_button, upgrades_button))
	upgrades_button.button_up.connect(upgrades_menu.bind(tab_container, upgrades_button, shelf_button))
	
	upgrades_grid_container.visible = false
	shelf_button.disabled = true

func set_up_shop() -> void:
	add_child(shop_container)
	shop_container.add_child(shop_margin_container)
	shop_margin_container.add_child(shop_center_container)
	shop_center_container.add_child(shelf_grid_container)
	shop_center_container.add_child(upgrades_grid_container)
	
	#Shop Layout Parameters.
	shop_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	shop_container.set_position(Vector2(shop_container.position.x, shop_container.position.y + 90))
	shop_center_container.use_top_left = true
	shelf_grid_container.add_theme_constant_override("h_separation", 10)
	shelf_grid_container.add_theme_constant_override("v_separation", 10)
	shelf_grid_container.columns = 3
	upgrades_grid_container.add_theme_constant_override("h_separation", 10)
	upgrades_grid_container.add_theme_constant_override("v_separation", 10)
	upgrades_grid_container.columns = 3

func set_up_shelves_menu() -> void:
	for shelf in ResourceTable.SHELVES.keys():
		
		var item_panel_container : PanelContainer = PanelContainer.new()
		var item_margin_container : MarginContainer = MarginContainer.new()
		var item_v_box_container : VBoxContainer = VBoxContainer.new()
		var item_label : Label = Label.new()
		var item_texture_rect : TextureRect = TextureRect.new()
		var price_label : Label = Label.new()
		var item_button : Button = Button.new()
		
		shelf_grid_container.add_child(item_panel_container)
		item_panel_container.add_child(item_margin_container)
		item_margin_container.add_child(item_v_box_container)
		item_v_box_container.add_child(item_label)
		item_v_box_container.add_child(item_texture_rect)
		item_v_box_container.add_child(price_label)
		item_v_box_container.add_child(item_button)
		
		#Item Layout Parameters.
		item_panel_container.custom_minimum_size = Vector2(250, 150)
		item_panel_container.pivot_offset_ratio = Vector2(0.5, 0.5)
		item_margin_container.add_theme_constant_override("margin_left", 10)
		item_margin_container.add_theme_constant_override("margin_right", 10)
		item_margin_container.add_theme_constant_override("margin_top", 10)
		item_margin_container.add_theme_constant_override("margin_bottom", 10)
		item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_label.text = shelf.capitalize()
		item_texture_rect.texture = ResourceTable.SHELVES[shelf].texture
		item_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_texture_rect.custom_minimum_size = Vector2(64, 64)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		price_label.text = "Price: " + str(get_current_shelf(shelf).cost) + " Points"
		item_button.pivot_offset_ratio = Vector2(0.5, 0.5)
		if get_current_shelf(shelf).has_shelf:
			item_button.text = "SELECT"
		else:
			item_button.text = "Buy"
		
		
		item_button.button_up.connect(on_shelf_button_press.bind(item_panel_container, item_button, shelf))

func set_up_upgrades_menu() -> void:
	for upgrade in ResourceTable.UPGRADES.keys():
		var item_panel_container : PanelContainer = PanelContainer.new()
		var item_margin_container : MarginContainer = MarginContainer.new()
		var item_v_box_container : VBoxContainer = VBoxContainer.new()
		var item_label : Label = Label.new()
		var item_texture_rect : TextureRect = TextureRect.new()
		var price_label : Label = Label.new()
		var item_button : Button = Button.new()
		var upgrade_icon = load("res://assets/textures/icons/upgrade_icon.png")
		var upgrade_list = ResourceTable.UPGRADES.get(upgrade)
		var upgrade_level : int = 0
		var max_upgrade_level : int = upgrade_list.size()
				
		upgrades_grid_container.add_child(item_panel_container)
		item_panel_container.add_child(item_margin_container)
		item_margin_container.add_child(item_v_box_container)
		item_v_box_container.add_child(item_label)
		item_v_box_container.add_child(item_texture_rect)
		item_v_box_container.add_child(price_label)
		item_v_box_container.add_child(item_button)
		
		#Item Layout Parameters.
		item_panel_container.custom_minimum_size = Vector2(250, 150)
		item_panel_container.pivot_offset_ratio = Vector2(0.5, 0.5)
		item_margin_container.add_theme_constant_override("margin_left", 10)
		item_margin_container.add_theme_constant_override("margin_right", 10)
		item_margin_container.add_theme_constant_override("margin_top", 10)
		item_margin_container.add_theme_constant_override("margin_bottom", 10)
		item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_label.text = upgrade.capitalize()
		item_texture_rect.texture = upgrade_icon
		item_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_texture_rect.custom_minimum_size = Vector2(64, 64)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_button.text = "Buy"
		item_button.pivot_offset_ratio = Vector2(0.5, 0.5)
		
		item_button.button_up.connect(on_upgrade_button_press.bind(upgrade, item_panel_container, item_button, price_label))
		
		#Checks current Upgrades.
		for is_upgrade_true in ResourceTable.UPGRADES.get(upgrade):
			if is_upgrade_true.has_upgrade == true:
				upgrade_level += 1
		if upgrade_level != max_upgrade_level:
			price_label.text = "Price: " + str(get_upgrade(upgrade, upgrade_level).cost) + " Points"
		else: 
			price_label.text = "Sold Out!"
			item_button.disabled = true

#Functions bound to Buttons.
func shelf_menu(tab_container, shelf_button, upgrades_button) -> void:
	tween_animation(AnimationState.button_press_animation, tab_container, shelf_button)
	shelf_button.disabled = true
	upgrades_button.disabled = false
	shelf_grid_container.visible = true
	upgrades_grid_container.visible = false
func upgrades_menu(tab_container, upgrades_button, shelf_button) -> void:
	tween_animation(AnimationState.button_press_animation, tab_container, upgrades_button)
	upgrades_button.disabled = true
	shelf_button.disabled = false
	upgrades_grid_container.visible = true
	shelf_grid_container.visible = false
func on_shelf_button_press(item_container : PanelContainer, item_button : Button, shelf : String) -> void:
	tween_animation(AnimationState.button_press_animation, item_container, item_button)
	
	if get_current_points() >= get_current_shelf(shelf).cost && get_current_shelf(shelf).has_shelf == false:
		get_current_shelf(shelf).has_shelf = true
		GameManager.player_points -= get_current_shelf(shelf).cost
		tween_animation(AnimationState.success_animation, item_container, item_button)
		await get_tree().create_timer(0.1).timeout
		GameManager.selected_shelf = shelf
		print(GameManager.selected_shelf)
		item_button.text = "SELECT"
	elif get_current_shelf(shelf).has_shelf:
		GameManager.selected_shelf = shelf
	else:
		tween_animation(AnimationState.failure_animation, item_container, item_button)
func on_upgrade_button_press(upgrade, item_panel_container, item_button, price_label) -> void:
	tween_animation(AnimationState.button_press_animation, item_panel_container, item_button)
	var upgrade_list = ResourceTable.UPGRADES.get(upgrade)
	var max_level : int = upgrade_list.size() - 1
	var current_level : int = 0	# -1 because the 1. Level is on Array[0]
	
	for item in upgrade_list:
		if item.has_upgrade == true:
			current_level += 1
	if current_level <= max_level:
		if get_current_points() >= get_upgrade(upgrade, current_level).cost:
			print(str(current_level) + " = " + str(max_level))
			get_upgrade(upgrade, current_level).has_upgrade = true
			GameManager.player_points -= get_upgrade(upgrade, current_level).cost
			print(ResourceTable.UPGRADES.get(upgrade))
			if current_level != max_level:
				price_label.text = "Price: " + str(get_upgrade(upgrade, current_level + 1).cost) + " Points"
			else:
				price_label.text = "Sold Out!"
				item_button.disabled = true
			EventBus.update_upgrades.emit()
		else: tween_animation(AnimationState.failure_animation, item_panel_container, item_button)

func tween_animation(animation_state : AnimationState, item_container : Container, item_button : Button) -> void:
	item_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween : Tween = create_tween()
	match animation_state:
		AnimationState.button_press_animation:
			tween.tween_property(item_button, "scale", Vector2(0.3, 0.3), 0.1).set_trans(Tween.TRANS_EXPO)
			tween.tween_property(item_button, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_EXPO)
		AnimationState.success_animation:
			tween.tween_property(item_container, "scale", Vector2(1.1, 1.1), 0.1).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(item_container, "modulate", Color(2, 2, 2, 1), 0.1)
			tween.tween_property(item_container, "modulate", Color(1, 1, 1, 1), 0.1)
			tween.tween_property(item_container, "scale", Vector2.ONE, 0.1).set_ease(Tween.EASE_IN_OUT)
		AnimationState.failure_animation:
			tween.tween_property(item_container, "modulate", Color(1, 0, 0, 1), 0.1).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(item_container, "modulate", Color(1, 1, 1, 1), 0.1).set_ease(Tween.EASE_IN_OUT)
			tween.set_loops(4)
			
	await tween.finished
	item_button.mouse_filter = Control.MOUSE_FILTER_STOP
	#item_container.modulate = Color(1, 1, 1, 1)
	#item_container.scale = Vector2.ONE

func go_back_to_main_menu() -> void: SceneManager.change_scene(main_menu_scene)
func get_current_shelf(shelf : String) -> Dictionary: return ResourceTable.SHELVES[shelf]
func get_upgrade(upgrade_name : String, upgrade_level : int) -> Dictionary:
	var upgrade_list : Array = ResourceTable.UPGRADES.get(upgrade_name, [])
	return upgrade_list[upgrade_level]
func get_current_points() -> int: return GameManager.player_points
