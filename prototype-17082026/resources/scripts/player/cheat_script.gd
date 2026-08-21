extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cheat_button"):
		GameManager.selected_item = "bubi"
		EventBus.item_changed.emit()
