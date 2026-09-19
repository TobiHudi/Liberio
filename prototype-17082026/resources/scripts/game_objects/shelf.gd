extends InventoryBase

@onready var timer_and_item_container : Container = $CenterContainer/Panel/MarginContainer/VBoxContainer/TimerAndItemContainer

var bonus_time : float
var bonus_points : int
var penalty_time : float
var clear_shelf_time : float
var clear_slot_time : float = 0.05
var allowed_item : String
var selected_shelf : String = GameManager.selected_shelf

var timer : Timer = Timer.new()
var empty_shelf_timer_label : Label = Label.new()
var item_picture : TextureRect = TextureRect.new()
var points_label_bg : TextureRect = TextureRect.new()
var points_label : Label = Label.new()

func _ready() -> void:
	#Overwrites Textures
	empty_slot_texture = load("res://assets/textures/products/shelf_slot.png")
	fallback_texture =load("res://assets/textures/products/shelf_slot.png")
	
	self.scale = Vector2(1.6, 1.6)
	super._ready()
	randomize_shelf()
	set_up_shelf()
#Overwrites current add_container() function.
func add_container() -> void:
	#Currently depends on a Node Setup.
	$CenterContainer/Panel/MarginContainer/VBoxContainer.add_child(slot_container)
#Returns True if item_id == allowed_item
func on_item_accept(item_id : String, _index : int) -> bool: return item_id == allowed_item
#Executes this function if on_item_accept is False.
func on_item_failure(slot : TextureButton, index : int) -> void:
	print_debug(allowed_item)
	super.on_item_failure(slot, index)
	EventBus.game_timer_update.emit(-penalty_time)
#Sets up Shelf with all attributes.
func set_up_shelf() -> void:
	#Sets up InventorySlot Abilities.
	can_replace_item_slot = false
	can_take_item_out_of_slot = false
	
	#Connects check_shelf_status on every Slot.
	for slot in slot_container.get_children():
		if slot is TextureButton:
			slot.button_down.connect(check_shelf_status)
	
	#Gets ResourceTable Shelves (Will rather search for a Shelf that is currently selected from the Shop)
	var resource_table_size = ResourceTable.SHELVES.size()
	#GameManager.selected_shelf = ResourceTable.SHELVES.keys()[randi() % resource_table_size]
	var current_shelf = ResourceTable.SHELVES.get(selected_shelf)
	print_debug(selected_shelf)
	
	#Sets ResourceTable properties to the Shelf.
	if selected_shelf == "": 
		print_debug("WRONG OR NO VALUE ASSIGNED")
		bonus_time = 999
		bonus_points = 999
		penalty_time = 999
		clear_shelf_time = 999
		$CenterContainer/Panel/NinePatchRect.texture = null
	else:
		bonus_time = current_shelf.reward_time
		bonus_points = current_shelf.points
		points_label.text = str(current_shelf.points)
		penalty_time = current_shelf.penalty_time
		clear_shelf_time = current_shelf.clear_time
		
		$CenterContainer/Panel/NinePatchRect.texture = current_shelf.texture
	
	#Adds ItemPicture and EmptyShelfTimerLabel
	timer_and_item_container.add_child(item_picture)
	timer_and_item_container.add_child(empty_shelf_timer_label)
	
	#Sets up EmptyShelfTimerLabel
	empty_shelf_timer_label.text = str("%.0f" % clear_shelf_time)
	empty_shelf_timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer.one_shot = true
	add_child(timer)
	
	#Sets up PointsLabel Text with properties.
	var points_label_center : CenterContainer  = CenterContainer.new()
	add_child(points_label_center)
	points_label_center.use_top_left = true
	points_label_center.add_child(points_label_bg)
	
	points_label_bg.texture = load("res://assets/textures/icons/shelf_point_display.png")
	points_label_bg.pivot_offset_ratio = Vector2(0.5, 0.5)	#To Display Animation correctly
	points_label_bg.set_anchors_preset(Control.PRESET_CENTER)
	points_label_bg.add_child(points_label)
	
	points_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	points_label.set_horizontal_alignment(HORIZONTAL_ALIGNMENT_CENTER)
	points_label.set_vertical_alignment(VERTICAL_ALIGNMENT_CENTER)
	points_label.custom_minimum_size = points_label_bg.size
	
	await get_tree().process_frame
	tween_animation(points_label_bg, AnimationState.IN)
#Randomizes wanted Shelf item.
func randomize_shelf() -> void:
	#Picks random Item from the ResourceTable
	allowed_item = ResourceTable.ITEMS.pick_random()
	var full_path = path_to_textures.path_join(allowed_item + ".png")
	print_debug(full_path)
	item_picture.texture = load(get_full_texture_path(allowed_item))
	
	push_warning("Remove Cheat Function on release.")
	CheatScript.current_cheat_item = allowed_item
#Checks how many Shelf slots are filled.
func check_shelf_status() -> void:
	#For Statement, that checks how many Slots have been filled.
	var slots_filled : int = 0
	for shelf_slot in slot_container.get_children():
		if shelf_slot is TextureButton && shelf_slot.get_meta("item_id") == allowed_item:
			slots_filled += 1
	
	#Checks if all slots have been filled.
	if slots_filled == inventory_slots:
		for shelf_slot in slot_container.get_children():
			if shelf_slot is TextureButton:
				shelf_slot.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		
		#Emits GameTimerUpdate and adds the bonus time to the GameLoopManager
		EventBus.game_timer_update.emit(bonus_time)
		
		#Plays a pulse animation while all slots are filled.
		var tweeny_pulse : Tween = create_tween()
		tweeny_pulse.set_loops()
		tweeny_pulse.tween_property(slot_container, "modulate", Color(1, 1, 1, 0), 0.2).set_ease(Tween.EASE_IN)
		tweeny_pulse.tween_property(slot_container, "modulate", Color(1, 1, 1, 1), 0.2).set_ease(Tween.EASE_OUT)
		
		#Adds Points to the Player.
		GameManager.player_points += bonus_points
		tween_animation(points_label_bg, AnimationState.OUT)
		await get_tree().create_timer(0.5).timeout
		tween_animation(points_label_bg, AnimationState.IN)
		
		#Startet den Timer für das Zurücksetzen des Regals
		timer.start(clear_shelf_time)
		
		#Updates EmptyShelfTimerLabel text if the timer is running.
		while timer.time_left >= 0.01:
			empty_shelf_timer_label.text = str("%.0f" % timer.time_left)
			#Awaits the next frame. is_inside_tree() hinders the game to crash, if the scene gets changed.
			if is_inside_tree():
				await get_tree().process_frame
			else: return
		await timer.timeout
		
		#Randomizes Shelf after Timer timeouts.
		randomize_shelf()
		
		#Sets Label Text + Removes Pulse effect.
		empty_shelf_timer_label.text = str("%.0f" % clear_shelf_time)
		
		#Removes pulse effect and resets color transparency
		tweeny_pulse.kill()
		slot_container.modulate = Color(1, 1, 1, 1)
		
		#Changes ItemId, update slots and regains mouse control.
		for shelf_slot in slot_container.get_children():
			if shelf_slot is TextureButton:
				tween_animation(shelf_slot, AnimationState.IN)
				await EventBus.animation_finished
				shelf_slot.set_meta("item_id", "")
				update_slot(shelf_slot)
				tween_animation(shelf_slot, AnimationState.OUT)
				shelf_slot.set_mouse_filter(Control.MOUSE_FILTER_STOP)
				
				#A simple Timer for the loop.
				await get_tree().create_timer(clear_slot_time).timeout
		
		push_warning("Alle Slots Befüllt")
