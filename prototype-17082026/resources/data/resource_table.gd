#Liste aller Items und Bücherregale! Ein Singleton reicht völlig für dieses Projekt aus. Ein JSON parser wäre Overkill.
extends Node

const ITEMS : Array[String] = [
	"blue_orb",
	"green_orb",
	"red_orb",
	"orange_orb",
	"violet_orb"
]

const SHELVES : Dictionary = {
	"dusty_shelf": {
		"cost" : 0,
		"clear_time" : 15.0,
		"reward_time" : 10.0,
		"penalty_time" : 10.0,
		"point_multiplier" : 1.0,
		"texture" : preload("res://assets/textures/debug/debug_border.png")
	},
	"oak_shelf": {
		"cost" : 10.0,
		"clear_time" : 10.0,
		"reward_time" : 15.0,
		"penalty_time" : 7.0,
		"point_multiplier" : 1.0,
		"texture" : preload("res://assets/textures/debug/debug_border.png")
	},
	"pine_shelf": {
		"cost" : 10.0,
		"clear_time" : 9.0,
		"reward_time" : 17.0,
		"penalty_time" : 10.0,
		"point_multiplier" : 1.1,
		"texture" : preload("res://assets/textures/debug/debug_border.png")
	},
	"refined_oak_shelf": {
		"cost" : 100,
		"clear_time" : 7.0,
		"reward_time" : 20.0,
		"penalty_time" : 6.0,
		"point_multiplier" : 1.1,
		"texture" : preload("res://assets/textures/debug/debug_border.png")
	},
	"refined_pine_shelf": {
		"cost" : 100,
		"clear_time" : 9.0,
		"reward_time" : 23.0,
		"penalty_time" : 9.0,
		"point_multiplier" : 1.2,
		"texture" : preload("res://assets/textures/debug/debug_border.png")
	},
}
