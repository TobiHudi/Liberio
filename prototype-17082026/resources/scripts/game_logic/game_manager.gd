extends Node

var selected_item : String
var selected_shelf : String
var player_points : int
var points_multiplier : float = 1

func _ready() -> void:
	if selected_shelf == "":
		selected_shelf = "dusty_shelf"
