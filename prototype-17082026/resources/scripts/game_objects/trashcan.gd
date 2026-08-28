extends InventoryBase

@export var empty_trash_time : float

var center_container : CenterContainer = CenterContainer.new()

func _ready() -> void:
	super._ready()
	set_up_inventory()

func set_up_inventory() -> void:
	can_replace_item_slot = false
	can_take_item_out_of_slot = false
	
	center_container.use_top_left = true
	await get_tree().process_frame
	center_container.set_position(Vector2(0, -slot_container.size.y * 2.5))
	
	for trash_slot in slot_container.get_children():
		if trash_slot is TextureButton:
			var trashcan_timer : Timer = Timer.new()
			var trashcan_progress_bar : ProgressBar = ProgressBar.new()
			trash_slot.add_child(trashcan_timer)
			trash_slot.add_child(trashcan_progress_bar)
			
			trash_slot.button_down.connect(trash_item.bind(trash_slot, trashcan_timer, trashcan_progress_bar))
			add_trashcan_properties(trashcan_timer, trashcan_progress_bar)
			print_debug("AAA")

func add_trashcan_properties(trashcan_timer : Timer, trashcan_progress_bar : ProgressBar) -> void:
	var new_style_fill = trashcan_progress_bar.get_theme_stylebox("fill").duplicate()
	var new_style_bg = trashcan_progress_bar.get_theme_stylebox("background").duplicate()
	
	new_style_fill.corner_radius_top_left = 0
	new_style_fill.corner_radius_top_right = 0
	new_style_fill.corner_radius_bottom_left = 0
	new_style_fill.corner_radius_bottom_right = 0
	new_style_fill.bg_color = Color(1, 1, 1, 1)
	new_style_bg.bg_color = Color(0, 0, 0, 0)
	
	trashcan_progress_bar.add_theme_stylebox_override("fill", new_style_fill)
	trashcan_progress_bar.add_theme_stylebox_override("background", new_style_bg)
	trashcan_progress_bar.set_fill_mode(3)
	trashcan_progress_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	trashcan_progress_bar.show_percentage = false
	trashcan_progress_bar.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
	trashcan_progress_bar.max_value = empty_trash_time
	
	trashcan_timer.one_shot = true

func trash_item(slot : TextureButton, trashcan_timer : Timer, trashcan_progress_bar : ProgressBar) -> void:
	if !trashcan_timer.is_stopped():
		return
		
	if get_slot_id(slot) != "":
		trashcan_timer.start(empty_trash_time)
		while trashcan_timer.time_left >= 0.01:
			trashcan_progress_bar.value = empty_trash_time - trashcan_timer.time_left
			await get_tree().process_frame
		await trashcan_timer.timeout
		trashcan_progress_bar.value = 0
		slot.set_meta("item_id", "")
		tween_animation(slot, AnimationState.IN)
		await tween_animation(slot, AnimationState.IN)
		update_slot_ui(slot)
		tween_animation(slot, AnimationState.OUT)

func add_container() -> void:
	add_child(center_container)
	center_container.add_child(slot_container)
