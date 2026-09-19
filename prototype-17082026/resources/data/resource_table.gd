#Liste aller Items und Bücherregale! Ein Singleton reicht völlig für dieses Projekt aus. Ein JSON parser wäre Overkill.
extends Node

const ITEMS : Array[String] = [
	"blue_orb",
	"green_orb",
	"red_orb",
	"orange_orb",
	"violet_orb"
]

var UPGRADES : Dictionary = {
	"shelf_upgrade": [
		{"cost" : 100, "has_upgrade" : false, "shelf_added" : 1},
		{"cost" : 200, "has_upgrade" : false, "shelf_added" : 1},
		{"cost" : 300, "has_upgrade" : false, "shelf_added" : 1}
		],
	"trashcan_upgrade": [
		{"cost" : 100, "has_upgrade" : false, "multiplier" : 1},
		{"cost" : 200, "has_upgrade" : false, "multiplier" : 1},
		{"cost" : 300, "has_upgrade" : false, "multiplier" : 1}
		],
	"item_randomizer_upgrade": [
		{"cost" : 100, "has_upgrade" : false, "multiplier" : 1},
		{"cost" : 200, "has_upgrade" : false, "multiplier" : 1},
		{"cost" : 300, "has_upgrade" : false, "multiplier" : 1}
		],
	"inventory_upgrade": [
		{"cost" : 100, "has_upgrade" : false, "multiplier" : 1},
		{"cost" : 200, "has_upgrade" : false, "multiplier" : 1},
		{"cost" : 300, "has_upgrade" : false, "multiplier" : 1}
		],
	"points_multiplier": [
		{"cost" : 100, "has_upgrade" : false, "multiplier" : 1},
		{"cost" : 200, "has_upgrade" : false, "multiplier" : 1},
		{"cost" : 300, "has_upgrade" : false, "multiplier" : 1}
		],
	"timer_upgrade": [
		{"cost" : 100, "has_upgrade" : false, "multiplier" : 1},
		{"cost" : 200, "has_upgrade" : false, "multiplier" : 1},
		{"cost" : 300, "has_upgrade" : false, "multiplier" : 1}
		],
}

var SHELVES : Dictionary = {
	"dusty_shelf": {
		"cost" : 0, "has_shelf" : true, "clear_time" : 10.0,
		"reward_time" : 10.0, "penalty_time" : 10.0,
		"points" : 10, "texture" : preload("res://assets/textures/bookshelves/dusty_shelf.png")
	},
	"oak_shelf": {
		"cost" : 100, "has_shelf" : false, "clear_time" : 10.0,
		"reward_time" : 10.0, "penalty_time" : 10.0,
		"points" : 50, "texture" : preload("res://assets/textures/bookshelves/oak_shelf.png")
	},
	"pine_shelf": {
		"cost" : 500, "has_shelf" : false, "clear_time" : 9.0,
		"reward_time" : 14.0, "penalty_time" : 10.0,
		"points" : 100, "texture" : preload("res://assets/textures/debug/debug_border.png")
	},
	"refined_oak_shelf": {
		"cost" : 5000, "has_shelf" : false, "clear_time" : 5.0,
		"reward_time" : 20.0, "penalty_time" : 5.0,
		"points" : 1000, "texture" : preload("res://assets/textures/debug/debug_border.png")
	},
	"refined_pine_shelf": {
		"cost" : 15000, "has_shelf" : false, "clear_time" : 3.0,
		"reward_time" : 25.0, "penalty_time" : 3.0,
		"points" : 5000, "texture" : preload("res://assets/textures/debug/debug_border.png")
	},
	"super_shelf": {
		"cost" : 100000, "has_shelf" : false, "clear_time" : 1.0,
		"reward_time" : 60.0, "penalty_time" : 0.0,
		"points" : 10000, "texture" : preload("res://assets/textures/debug/debug_border.png")
	}
}
