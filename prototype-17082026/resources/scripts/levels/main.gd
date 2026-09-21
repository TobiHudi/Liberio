extends Node

@export var box_container: BoxContainer
@onready var shelf_object : PackedScene = preload("res://scenes/game_objects/shelf.tscn")

var shelf_amount = GameManager.shelf_amount

func _ready() -> void:
	spawn_game_objects()
	print(box_container.get_children())
func spawn_game_objects() -> void:
	for shelf in shelf_amount:
		var new_shelf = shelf_object.instantiate()
		box_container.add_child(new_shelf)
