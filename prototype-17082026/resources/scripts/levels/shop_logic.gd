extends Node

@export var back_button : Button
@export_dir var main_menu_scene : String

var shop_container : Container = Container.new()
var shop_margin_container : MarginContainer = MarginContainer.new()
var shop_center_container : CenterContainer = CenterContainer.new()
var shop_grid_container : GridContainer = GridContainer.new()

enum CurrentTab { shelves, upgrades }
enum AnimationState { button_press_animation, success_animation, failure_animation }
func _ready() -> void:
	back_button.button_down.connect(go_back_to_main_menu)
	set_up_tabs_menu()
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
	
	shelf_button.button_up.connect(shelf_menu.bind(tab_container, shelf_button))
	upgrades_button.button_up.connect(upgrades_menu.bind(tab_container, upgrades_button))
	
func set_up_shelves_menu() -> void:
	add_child(shop_container)
	shop_container.add_child(shop_margin_container)
	shop_margin_container.add_child(shop_center_container)
	shop_center_container.add_child(shop_grid_container)
	
	#Shop Layout Parameters.
	shop_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	shop_container.set_position(Vector2(shop_container.position.x, shop_container.position.y + 90))
	shop_center_container.use_top_left = true
	shop_grid_container.add_theme_constant_override("h_separation", 10)
	shop_grid_container.add_theme_constant_override("v_separation", 10)
	shop_grid_container.columns = 3
	
	for shelf in ResourceTable.SHELVES.keys():
		var item_container_container : PanelContainer = PanelContainer.new()
		var item_margin_container : MarginContainer = MarginContainer.new()
		var item_v_box_container : VBoxContainer = VBoxContainer.new()
		var item_label : Label = Label.new()
		var item_texture_rect : TextureRect = TextureRect.new()
		var price_label : Label = Label.new()
		var item_button : Button = Button.new()
		
		shop_grid_container.add_child(item_container_container)
		item_container_container.add_child(item_margin_container)
		item_margin_container.add_child(item_v_box_container)
		item_v_box_container.add_child(item_label)
		item_v_box_container.add_child(item_texture_rect)
		item_v_box_container.add_child(price_label)
		item_v_box_container.add_child(item_button)
		
		#Item Layout Parameters.
		item_container_container.pivot_offset_ratio = Vector2(0.5, 0.5)
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
		item_button.text = "Buy"
		item_button.pivot_offset_ratio = Vector2(0.5, 0.5)
		
		item_button.button_up.connect(on_shelf_button_press.bind(item_container_container, item_button, shelf))

func set_up_upgrades_menu() -> void:
	pass

func shelf_menu(tab_container, shelf_button) -> void:
	tween_animation(AnimationState.button_press_animation, tab_container, shelf_button)
func upgrades_menu(tab_container, upgrades_button) -> void:
	tween_animation(AnimationState.button_press_animation, tab_container, upgrades_button)

func on_shelf_button_press(item_container : PanelContainer, item_button : Button, shelf : String) -> void:
	tween_animation(AnimationState.button_press_animation, item_container, item_button)
	
	if get_current_points() >= get_current_shelf(shelf).cost:
		GameManager.current_points -= get_current_shelf(shelf).cost
		print(get_current_points())
		tween_animation(AnimationState.success_animation, item_container, item_button)
		await get_tree().create_timer(0.1).timeout
		item_button.text = "SOLD OUT"
		item_button.disabled = true
	else:
		tween_animation(AnimationState.failure_animation, item_container, item_button)

func tween_animation(animation_state : AnimationState, item_container : Container, item_button : Button) -> void:
	item_button.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var tween : Tween = create_tween()
	match animation_state:
		AnimationState.button_press_animation:
			tween.tween_property(item_button, "scale", Vector2(0.3, 0.3), 0.1).set_trans(Tween.TRANS_EXPO)
			tween.tween_property(item_button, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_EXPO)
			print_debug("Button Pressed.")
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
func get_current_points() -> int: return GameManager.current_points
