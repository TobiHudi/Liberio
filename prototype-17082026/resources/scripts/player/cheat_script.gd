extends Node

var current_cheat_item

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cheat_button"):
		GameManager.selected_item = current_cheat_item
		EventBus.item_changed.emit()
