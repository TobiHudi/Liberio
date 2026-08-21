extends InventoryBase

@export var allowed_item : String
@export var bonus_time : float
@export var penalty_time : float

func _ready() -> void:
	super._ready()
	can_replace_item_slot = false
	can_take_item_out_of_slot = false
	for slot in slot_container.get_children():
		if slot is TextureButton:
			slot.button_down.connect(check_shelf_status.bind(slot))

func check_shelf_status(_slot : TextureButton) -> void:
	#Implementiere Partikel Effekte für erfolgreiches platzieren von Slot.
	var slots_filled : int = 0
	for shelf_slot in slot_container.get_children():
		if shelf_slot is TextureButton && shelf_slot.get_meta("item_id") == allowed_item:
			slots_filled += 1
			#print_debug(slots_filled)
			
	if slots_filled == inventory_slots:
		for shelf_slot in slot_container.get_children():
			if shelf_slot is TextureButton:
				
				shelf_slot.pivot_offset = shelf_slot.size / 2
				var tweeny_out = create_tween()
				tweeny_out.tween_property(shelf_slot, "scale", Vector2.ZERO, 0.05)
				await tweeny_out.finished
				
				shelf_slot.set_meta("item_id", "")
				update_slot_ui(shelf_slot)
				
				var tweeny_in : Tween = create_tween()
				tweeny_in.tween_property(shelf_slot, "scale", Vector2.ONE, 0.05)
				
				GameManager.game_timer += bonus_time
				
		print_debug("ALL SLOTS FILLED!")
		
func on_item_accept(item_id : String, _index : int) -> bool:
	return item_id == allowed_item
	
func on_item_failure(_item_id : String, _index : int) -> void:
	GameManager.game_timer -= penalty_time
	print_debug("Grrrr... No " + allowed_item.capitalize() + " no deal!")
