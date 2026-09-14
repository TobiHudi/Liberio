extends Node

var shop_panel_container : PanelContainer = PanelContainer.new()
var shop_margin_container : MarginContainer = MarginContainer.new()
var shop_center_container : CenterContainer = CenterContainer.new()
var shop_grid_container : GridContainer = GridContainer.new()
func _ready() -> void:
	set_up_shelves()

func set_up_shelves() -> void:
	add_child(shop_panel_container)
	shop_panel_container.add_child(shop_margin_container)
	shop_margin_container.add_child(shop_center_container)
	shop_center_container.add_child(shop_grid_container)
	
	#Shop Layout Parameters.
	shop_panel_container.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	shop_center_container.use_top_left = true
	shop_grid_container.add_theme_constant_override("h_separation", 10)
	shop_grid_container.add_theme_constant_override("v_separation", 10)
	shop_grid_container.columns = 3
	
	for shelf in ResourceTable.SHELVES.keys():
		var panel_container : PanelContainer = PanelContainer.new()
		var margin_container : MarginContainer = MarginContainer.new()
		var v_box_container : VBoxContainer = VBoxContainer.new()
		var item_label : Label = Label.new()
		var item_texture_rect : TextureRect = TextureRect.new()
		var price_label : Label = Label.new()
		var item_button : Button = Button.new()
		
		shop_grid_container.add_child(panel_container)
		panel_container.add_child(margin_container)
		margin_container.add_child(v_box_container)
		v_box_container.add_child(item_label)
		v_box_container.add_child(item_texture_rect)
		v_box_container.add_child(price_label)
		v_box_container.add_child(item_button)
		
		#Item Layout Parameters.
		margin_container.add_theme_constant_override("margin_left", 10)
		margin_container.add_theme_constant_override("margin_right", 10)
		margin_container.add_theme_constant_override("margin_top", 10)
		margin_container.add_theme_constant_override("margin_bottom", 10)
		item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_label.text = shelf.capitalize()
		item_texture_rect.texture = ResourceTable.SHELVES[shelf].texture
		item_texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		item_texture_rect.custom_minimum_size = Vector2(64, 64)
		price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		price_label.text = "Price: " + str(ResourceTable.SHELVES[shelf].cost) + " Points"
		item_button.text = "Buy"
		
		item_button.button_down.connect(on_button_press)

func on_button_press() -> void:
	pass
