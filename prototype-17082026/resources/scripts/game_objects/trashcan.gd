extends InventoryBase

@export var empty_trash_time : float

func _ready() -> void:
	super._ready()
	can_replace_item_slot = false
	can_take_item_out_of_slot = false
	
	for trash_slot in slot_container.get_children():
		if trash_slot is TextureButton:
			trash_slot.button_down.connect(trash_item.bind(trash_slot))
	
func trash_item(slot : TextureButton) -> void:
	if slot.get_meta("item_id") != "":
		var timer : Timer = Timer.new()
		add_child(timer)
		timer.start(empty_trash_time)
		await timer.timeout
		slot.set_meta("item_id", "")
		update_slot_ui(slot)
