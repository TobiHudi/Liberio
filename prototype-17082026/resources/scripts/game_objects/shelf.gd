extends InventoryBase

var bonus_time : float
var bonus_points : int
var penalty_time : float
var clear_shelf_time : float
@export var clear_slot_time : float
@export var timer_and_item_container : Container

var allowed_item : String
var timer : Timer = Timer.new()
var label : Label = Label.new()
var item_picture : TextureRect = TextureRect.new()
var points_label : Label = Label.new()

var chosen_shelf

func _ready() -> void:
	self.scale = Vector2(1.6, 1.6)
	empty_slot_texture = load("res://assets/textures/products/shelf_slot.png")
	fallback_texture =load("res://assets/textures/products/shelf_slot.png")
	super._ready()
	set_up_resource_table_data_and_slot_attributes()
	label.text = str("%.0f" % clear_shelf_time)
	can_replace_item_slot = false
	can_take_item_out_of_slot = false
	
	
	timer.one_shot = true
	add_child(timer)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	timer_and_item_container.add_child(item_picture)
	timer_and_item_container.add_child(label)
	randomize_shelf()

func add_container() -> void:
	$CenterContainer/Panel/MarginContainer/VBoxContainer.add_child(slot_container)

func _process(_delta: float) -> void:
	if !timer.is_stopped():
		label.text = str("%.0f" % timer.time_left)

func check_shelf_status() -> void:
	#Implementiere Partikel Effekte für erfolgreiches platzieren von Slot.
	var slots_filled : int = 0
	for shelf_slot in slot_container.get_children():
		if shelf_slot is TextureButton && shelf_slot.get_meta("item_id") == allowed_item:
			slots_filled += 1
			
	if slots_filled == inventory_slots:
		for shelf_slot in slot_container.get_children():
			if shelf_slot is TextureButton:
				shelf_slot.set_mouse_filter(Control.MOUSE_FILTER_IGNORE)
		#Spielt die "pulse" animation, wenn das Regal voll ist.
		var tweeny_pulse : Tween = create_tween()
		tweeny_pulse.set_loops()
		tweeny_pulse.tween_property(slot_container, "modulate", Color(1, 1, 1, 0), 0.2).set_ease(Tween.EASE_IN)
		tweeny_pulse.tween_property(slot_container, "modulate", Color(1, 1, 1, 1), 0.2).set_ease(Tween.EASE_OUT)
		tween_animation(points_label, AnimationState.OUT)
		await get_tree().create_timer(1).timeout
		tween_animation(points_label, AnimationState.IN)
		#Startet den Timer für das Zurücksetzen des Regals
		timer.start(clear_shelf_time)
		await timer.timeout
		
		randomize_shelf()
		
		#Setzt den Label Text + Entfernt den Pulse Effekt.
		label.text = str("%.0f" % clear_shelf_time)
		tweeny_pulse.kill()
		slot_container.modulate = Color(1, 1, 1, 1)
		#Sucht Alle vorhandenen Slots.
		for shelf_slot in slot_container.get_children():
			if shelf_slot is TextureButton:
				
				tween_animation(shelf_slot, AnimationState.IN)
				await EventBus.animation_finished
				shelf_slot.set_meta("item_id", "")
				update_slot(shelf_slot)
				tween_animation(shelf_slot, AnimationState.OUT)
				shelf_slot.set_mouse_filter(Control.MOUSE_FILTER_STOP)
				
				await get_tree().create_timer(clear_slot_time).timeout
		EventBus.game_timer_update.emit(bonus_time)
		GameManager.player_points += bonus_points
		
		print_debug("ALLE SLOTS BEFÜLLT :D")

func on_item_accept(item_id : String, _index : int) -> bool:
	return item_id == allowed_item #Returned true wenn item_id == allowed_item
func on_item_failure(slot : TextureButton, index : int) -> void:
	print_debug(allowed_item)
	super.on_item_failure(slot, index)
	EventBus.game_timer_update.emit(-penalty_time)

func randomize_shelf() -> void:
	allowed_item = ResourceTable.ITEMS.pick_random()
	CheatScript.current_cheat_item = allowed_item
	var full_path = path_to_textures.path_join(allowed_item + ".png")
	print_debug(full_path)
	item_picture.texture = load(full_path)
	
func set_up_resource_table_data_and_slot_attributes() -> void:
	var resource_table_size = ResourceTable.SHELVES.size()
	GameManager.chosen_shelf = ResourceTable.SHELVES.keys()[randi() % resource_table_size]
	chosen_shelf = GameManager.chosen_shelf
	var current_shelf = ResourceTable.SHELVES.get(chosen_shelf)
	print_debug(chosen_shelf)
	if current_shelf == null: 
		print_debug("WRONG OR NO VALUE ASSIGNED")
		bonus_time = 999
		bonus_points = 999
		penalty_time = 999
		clear_shelf_time = 999
		$CenterContainer/Panel/NinePatchRect.texture = null
	else:
		bonus_time = current_shelf.reward_time
		bonus_points = current_shelf.points
		penalty_time = current_shelf.penalty_time
		clear_shelf_time = current_shelf.clear_time
		$CenterContainer/Panel/NinePatchRect.texture = current_shelf.texture
	
	$CenterContainer.add_child(points_label)
	print_debug("Label created")
	points_label.pivot_offset_ratio = Vector2(0.5, 0.5)
	points_label.text = str(current_shelf.points)
	
	tween_animation(points_label, AnimationState.IN)
	for slot in slot_container.get_children():
		if slot is TextureButton:
			slot.button_down.connect(check_shelf_status)
