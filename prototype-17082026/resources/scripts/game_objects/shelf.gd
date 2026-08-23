extends InventoryBase

@export var bonus_time : float
@export var penalty_time : float
@export var clear_shelf_time : float

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
	slot_container.get_parent().add_child(label)
	slot_container.get_parent().move_child(label, label.get_index() - 1)

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
		
		#Setzt das gewünschte Item vom Regal und ladet die Textur.
		allowed_item = ResourceTable.items.pick_random()
		var full_path = path_to_textures.path_join(allowed_item)
		item_picture.texture = load(full_path)
		
		#Setzt den Label Text + Entfernt den Pulse Effekt.
		label.text = ""
		tweeny_pulse.kill()
		
		#Sucht Alle vorhandenen Slots.
		for shelf_slot in slot_container.get_children():
			if shelf_slot is TextureButton:
				
				#Führt eine Animation aus und setzt die Item ID zurück und aktuallisiert die UI :P
				shelf_slot.pivot_offset = shelf_slot.size / 2
				var tweeny_out = create_tween()
				tweeny_out.tween_property(shelf_slot, "scale", Vector2.ZERO, 0.05)
				await tweeny_out.finished
				
				shelf_slot.set_meta("item_id", "")
				update_slot_ui(shelf_slot)
				
				var tweeny_in : Tween = create_tween()
				tweeny_in.tween_property(shelf_slot, "scale", Vector2.ONE, 0.05)
				
				GameManager.game_timer += bonus_time
				
		print_debug("ALLE SLOTS BEFÜLLT :D")

func on_item_accept(item_id : String, _index : int) -> bool:
	return item_id == allowed_item

func on_item_failure(_item_id : String, _index : int) -> void:
	GameManager.game_timer -= penalty_time
	print_debug("Grrrr... No " + allowed_item.capitalize() + " no deal!")
