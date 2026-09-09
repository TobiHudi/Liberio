extends InventoryBase

@export var empty_trash_time : float
@export var progress_bar_stylebox : StyleBoxFlat
@export var progress_bar_stylebox_empty : StyleBoxFlat

func _ready() -> void:
	super._ready()
	set_up_trashcan()
#Overwrites current add_container() function.
func add_container() -> void:
	var center_container : CenterContainer = CenterContainer.new()
	add_child(center_container)
	center_container.use_top_left = true
	center_container.set_position(Vector2(0, -60))
	center_container.add_child(slot_container)
#Sets up Trashcan properties.
func set_up_trashcan() -> void:
	#Sets up InventorySlot Abilities.
	can_replace_item_slot = false
	can_take_item_out_of_slot = false
	
	#Gets all slots and applies properties to the slots.
	for trash_slot in slot_container.get_children():
		if trash_slot is TextureButton:
			#Adds a Timer and ProgressBar to every Slot.
			var trashcan_timer : Timer = Timer.new()
			var trashcan_progress_bar : ProgressBar = ProgressBar.new()
			trash_slot.add_child(trashcan_timer)
			trash_slot.add_child(trashcan_progress_bar)
			trashcan_progress_bar.add_theme_stylebox_override("fill", progress_bar_stylebox)
			trashcan_progress_bar.add_theme_stylebox_override("background", progress_bar_stylebox_empty)
			trashcan_progress_bar.set_fill_mode(3)
			trashcan_progress_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			trashcan_progress_bar.show_percentage = false
			trashcan_progress_bar.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
			trashcan_progress_bar.max_value = empty_trash_time
			trashcan_timer.one_shot = true
			
			#Connects TrashItem to slot button.
			trash_slot.button_down.connect(trash_item.bind(trash_slot, trashcan_timer, trashcan_progress_bar))
#Resets all values of slot.
func trash_item(slot : TextureButton, trashcan_timer : Timer, trashcan_progress_bar : ProgressBar) -> void:
	#Returns code if the TrashcanTimer is running
	if !trashcan_timer.is_stopped():
		return
	
	#Empties Trash if slot is filled.
	if get_slot_id(slot) != "":
		#Updates ProgressBar while Timer is running
		trashcan_timer.start(empty_trash_time)
		while trashcan_timer.time_left >= 0.01:
			trashcan_progress_bar.value = empty_trash_time - trashcan_timer.time_left
			await get_tree().process_frame
		await trashcan_timer.timeout
		
		#Resets ProgressBar and SlotId values.
		trashcan_progress_bar.value = 0
		slot.set_meta("item_id", "")
		tween_animation(slot, AnimationState.IN)
		await tween_animation(slot, AnimationState.IN)
		update_slot_ui(slot)
		tween_animation(slot, AnimationState.OUT)
	else: print_debug("Slot is empty.")
