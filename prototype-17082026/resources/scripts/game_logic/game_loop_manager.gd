#Add this to the Canvas for the GameScene!
extends Node

@export var timer_label : Label
@export var points_label : Label

var timer : float
var start_timer : bool = false
var is_timer_finished : bool = false

func _ready() -> void:
	EventBus.game_timer_start.connect(timer_started)
	EventBus.game_timer_update.connect(timer_update)
	timer_started(30 + GameManager.start_timer)
	
func timer_started(new_time : float) -> void:
	timer = new_time
	timer_running()
	
func timer_update(new_time : float) -> void: 
	timer += new_time
func timer_running() -> void:
	start_timer = true
	while start_timer:
		timer -= get_process_delta_time()
		timer_label.text = str("%.1f" % timer)
		points_label.text = str(GameManager.player_points)
		if timer <= 0:
			timer_label.text = "0"
			start_timer = false
		await get_tree().process_frame
	game_finished()

func game_finished() -> void: 
	var game_over_menu = load("res://scenes/ui/game_over_menu.tscn")
	var game_over_instance = game_over_menu.instantiate()
	add_child(game_over_instance)
	print_debug("Game Finished")
