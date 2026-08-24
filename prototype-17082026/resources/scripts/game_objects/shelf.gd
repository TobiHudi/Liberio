extends InventoryBase

@export var bonus_time : float
@export var penalty_time : float
@export var clear_shelf_time : float
@export var timer_and_item_container : Container

var allowed_item : String
var timer : Timer = Timer.new()
var label : Label = Label.new()
var item_picture : TextureRect = TextureRect.new()

func _ready() -> void:
	
	super._ready()
	can_replace_item_slot = false
	can_take_item_out_of_slot = false
	for slot in slot_container.get_children():
		if slot is TextureButton:
			slot.button_down.connect(check_shelf_status)
	timer.one_shot = true
	add_child(timer)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	timer_and_item_container.add_child(item_picture)
	timer_and_item_container.add_child(label)
	randomize_shelf()

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
		#Spielt die "pulse" animation, wenn das Regal voll ist.
		var tweeny_pulse : Tween = create_tween()
		tweeny_pulse.set_loops()
		tweeny_pulse.tween_property(slot_container, "modulate", Color(1, 1, 1, 0), 0.2).set_ease(Tween.EASE_IN)
		tweeny_pulse.tween_property(slot_container, "modulate", Color(1, 1, 1, 1), 0.2).set_ease(Tween.EASE_OUT)
		
		#Startet den Timer für das Zurücksetzen des Regals
		timer.start(clear_shelf_time)
		await timer.timeout
		
		randomize_shelf()
		
		#Setzt den Label Text + Entfernt den Pulse Effekt.
		label.text = ""
		tweeny_pulse.kill()
		
		#Sucht Alle vorhandenen Slots.
		for shelf_slot in slot_container.get_children():
			if shelf_slot is TextureButton:
				
				tween_animation(shelf_slot, AnimationState.IN)
				await EventBus.animation_finished
				
				shelf_slot.set_meta("item_id", "")
				update_slot(shelf_slot)
				
				tween_animation(shelf_slot, AnimationState.OUT)
				GameManager.game_timer += bonus_time
				
		print_debug("ALLE SLOTS BEFÜLLT :D")

func on_item_accept(item_id : String, _index : int) -> bool:
	return item_id == allowed_item
func on_item_failure(slot : TextureButton, index : int) -> void:
	print_debug(allowed_item)
	super.on_item_failure(slot, index)
	GameManager.game_timer -= penalty_time

func randomize_shelf() -> void:
	allowed_item = ResourceTable.ITEMS.pick_random()
	var full_path = path_to_textures.path_join(allowed_item + ".png")
	print_debug(full_path)
	item_picture.texture = load(full_path)
	
