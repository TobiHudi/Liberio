extends InventoryBase

@export var respawn_time : float
@export var progress_bar_stylebox : StyleBoxFlat
@export var progress_bar_stylebox_empty : StyleBoxFlat

var item_to_spawn : Array[String] = ResourceTable.ITEMS

func _ready() -> void:
	#Overwrites Textures
	empty_slot_texture = load("res://assets/textures/products/inventory_slot.png")
	fallback_texture =load("res://assets/textures/products/inventory_slot.png")
	super._ready()
	set_up_slot()
#Overwrites current add_container() function.
func add_container() -> void:
	var center_container : CenterContainer = CenterContainer.new()
	add_child(center_container)
	center_container.use_top_left = true
	center_container.set_position(Vector2(0, -20))   #Currently Hard-Coded
	center_container.add_child(slot_container)
#Sets Up Slot textures and properties.
func set_up_slot() -> void:
	#Sets up InventorySlot Abilities.
	can_replace_item_slot = false
	can_place_item_in_slot = false
	for slot in slot_container.get_children():
		if slot is TextureButton:
			#Adds Timer and ProgressBar for each slot.
			var timer : Timer = Timer.new()
			var progress_bar : ProgressBar = ProgressBar.new()
			slot.add_child(progress_bar)
			slot.add_child(timer)
			progress_bar.add_theme_stylebox_override("fill", progress_bar_stylebox)
			progress_bar.add_theme_stylebox_override("background", progress_bar_stylebox_empty)
			progress_bar.set_fill_mode(3)
			progress_bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			progress_bar.show_percentage = false
			progress_bar.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
			progress_bar.max_value = respawn_time
			timer.one_shot = true
			
			#Binds SpawnNewItem to all slots.
			slot.button_down.connect(spawn_new_item.bind(slot, timer, progress_bar))
			
			#Randomizes Slot Item
			slot.set_meta("item_id", item_to_spawn.pick_random())
			update_slot(slot)
#Spawns new item if slot is empty after taking an item out.
func spawn_new_item(slot : TextureButton, timer : Timer, progress_bar : ProgressBar) -> void:
	if !timer.is_stopped():
		return
	#If slot is empty, remove mouse access and pick random item.
	if slot.get_meta("item_id")	 == "":
		slot.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		
		#Updates ProgressBar while Timer is running
		timer.start(respawn_time)
		while timer.time_left >= 0.01:
			progress_bar.value = respawn_time - timer.time_left
			await get_tree().process_frame
		await timer.timeout
		
		#Resets ProgressBar and regain mouse access.
		progress_bar.value = 0
		slot.set_mouse_filter(Control.MOUSE_FILTER_PASS)
		
		#Sets new ItemID and animate slot for a smooth transition.
		slot.set_meta("item_id", item_to_spawn.pick_random())
		tween_animation(slot, AnimationState.IN)
		await tween_animation(slot, AnimationState.IN)
		update_slot_ui(slot)
		tween_animation(slot, AnimationState.OUT)
