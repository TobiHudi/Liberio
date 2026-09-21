extends InventoryBase

func _ready() -> void:
	inventory_slots = GameManager.inventory_amount
	inventory_columns = GameManager.inventory_amount
	super._ready()

func add_container() -> void:
	var center_container : CenterContainer = CenterContainer.new()
	add_child(center_container)
	center_container.use_top_left = true
	center_container.set_position(Vector2(0, -100))
	center_container.add_child(slot_container)
