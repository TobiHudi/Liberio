extends InventoryBase

@export var respawn_time : float
var progress_bar_stylebox : StyleBoxFlat = preload("res://resources/data/progress_bar.tres")
var progress_bar_stylebox_empty : StyleBoxFlat = preload("res://resources/data/empty_stylebox.tres")
var to_spawn : Array[String] = ResourceTable.ITEMS
var center_container : CenterContainer = CenterContainer.new()
func _ready() -> void:
	super._ready()
	set_up_inventory_location()
	set_up_slot()

func set_up_slot() -> void:
	empty_slot_texture = load("res://assets/textures/products/inventory_slot.png")
	fallback_texture =load("res://assets/textures/products/inventory_slot.png")
	can_replace_item_slot = false
	can_place_item_in_slot = false
	for slot in slot_container.get_children():
		if slot is TextureButton:
			var timer : Timer = Timer.new()
			var progress_bar : ProgressBar = ProgressBar.new()
			slot.add_child(progress_bar)
			slot.add_child(timer)
#			var new_style_fill = progress_bar.get_theme_stylebox("fill").duplicate()
#			var new_style_bg = progress_bar.get_theme_stylebox("background").duplicate()
#	
#			new_style_fill.corner_radius_top_left = 0
#			new_style_fill.corner_radius_top_right = 0
#			new_style_fill.corner_radius_bottom_left = 0
#			new_style_fill.corner_radius_bottom_right = 0
#			new_style_fill.bg_color = Color(1, 1, 1, 1)
#			new_style_bg.bg_color = Color(0, 0, 0, 0)
	
			progress_bar.add_theme_stylebox_override("fill", progress_bar_stylebox)
			progress_bar.add_theme_stylebox_override("background", progress_bar_stylebox_empty)
			progress_bar.set_fill_mode(3)
			progress_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			progress_bar.show_percentage = false
			progress_bar.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
			progress_bar.max_value = respawn_time
	
			timer.one_shot = true
	
			slot.button_down.connect(spawn_new_item.bind(slot, timer, progress_bar))
			slot.set_meta("item_id", to_spawn.pick_random())
			update_slot(slot)
func set_up_inventory_location() -> void:
	center_container.use_top_left = true
	await get_tree().process_frame
	center_container.set_position(Vector2(0, -slot_container.size.y))
	
func spawn_new_item(slot : TextureButton, timer : Timer, progress_bar : ProgressBar) -> void:
	if !timer.is_stopped():
		return
	
	if slot.get_meta("item_id")	 == "":
		slot.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		timer.start(respawn_time)
		while timer.time_left >= 0.01:
			progress_bar.value = respawn_time - timer.time_left
			await get_tree().process_frame
		await timer.timeout
		progress_bar.value = 0
		slot.set_mouse_filter(Control.MOUSE_FILTER_PASS)
		#print_debug("Item replaced!")
		slot.set_meta("item_id", to_spawn.pick_random())
		tween_animation(slot, AnimationState.IN)
		await tween_animation(slot, AnimationState.IN)
		update_slot_ui(slot)
		tween_animation(slot, AnimationState.OUT)

func add_container() -> void:    #Überschreibt vorhandene Funktion vom InventoryBase
	add_child(center_container)
	center_container.add_child(slot_container)
