extends Node

var selected_item : String
var selected_shelf : String
var player_points : int

#Upgrade variables
var shelf_amount = 1
var trashcan_amount = 3
var item_randomizer_amount = 6
var inventory_amount = 1
var points_multiplier : float = 1
var start_timer = 1

func _ready() -> void:
	EventBus.update_upgrades.connect(update_upgrades)
	update_upgrades()
	
	if selected_shelf == "":
		selected_shelf = "dusty_shelf"

func update_upgrades() -> void:
	var new_shelf_amount = 1
	var new_trashcan_amount = 3
	var new_item_randomizer_amount = 6
	var new_inventory_amount = 1
	var new_points_multiplier : float = 1
	var new_start_timer = 1
	
	# Reads a String out of the ResourceTable, goes through all the unlocked levels
	# and adds the values from the Upgrade. After that it applies the upgrade value
	# to the new value that will be set over to the coresponding value!
	# Example: new_shelf_amount -> shelf_amount.
	for upgrade_type in ResourceTable.UPGRADES:
		var upgrade_list : Array = ResourceTable.UPGRADES[upgrade_type]
		var upgrade_value = 0
		for level in upgrade_list:
			if level.get("has_upgrade", true):
				upgrade_value += level.get("value", 0)
		
		match upgrade_type:
			"shelf_upgrade":
				new_shelf_amount += upgrade_value
				print(upgrade_type + " = " + str(new_shelf_amount))
			"trashcan_upgrade":
				new_trashcan_amount += upgrade_value
				print(upgrade_type + " = " + str(new_trashcan_amount))
			"item_randomizer_upgrade":
				new_item_randomizer_amount += upgrade_value
				print(upgrade_type + " = " + str(new_item_randomizer_amount))
			"inventory_upgrade":
				new_inventory_amount += upgrade_value
				print(upgrade_type + " = " + str(new_inventory_amount))
			"points_multiplier":
				new_points_multiplier += upgrade_value
				print(upgrade_type + " = " + str(new_points_multiplier))
			"timer_upgrade":
				new_start_timer += upgrade_value
				print(upgrade_type + " = " + str(new_start_timer))
	shelf_amount = new_shelf_amount
	trashcan_amount = new_trashcan_amount
	item_randomizer_amount = new_item_randomizer_amount
	inventory_amount = new_inventory_amount
	points_multiplier = new_points_multiplier
	start_timer = new_start_timer
