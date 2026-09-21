extends Node

var current_cheat_item

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cheat_add_item"):
		GameManager.selected_item = current_cheat_item
		EventBus.item_changed.emit()
		print_debug(current_cheat_item)
		
	if event.is_action_pressed("cheat_start_game"):
		EventBus.game_timer_start.emit(20.0)
	
	if event.is_action_pressed("cheat_add_money"):
		GameManager.player_points = 10000
