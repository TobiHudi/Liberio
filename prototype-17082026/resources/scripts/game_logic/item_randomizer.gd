extends InventoryBase

var to_spawn : Array[String] = ["bubi", "meister_poppa", "stinky"]

func _ready() -> void:
	super._ready()
	can_replace_item_slot = false
	can_place_item_in_slot = false
	for slot in slot_container.get_children():
		if slot is TextureButton:
			var timer : Timer = Timer.new()
			timer.one_shot = true
			add_child(timer)
			slot.button_down.connect(spawn_new_item.bind(slot, timer))
			slot.set_meta("item_id", to_spawn.pick_random())
			update_slot(slot)

func spawn_new_item(slot : TextureButton, timer : Timer) -> void:
	if !timer.is_stopped():
		return
	
	if slot.get_meta("item_id")	 == "":
		timer.start(5)
		await timer.timeout
		#print_debug("Item replaced!")
		slot.set_meta("item_id", to_spawn.pick_random())
		update_slot_ui(slot)
