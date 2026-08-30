#Add this to the Canvas for the GameScene!
extends Node

@export var timer_label : Label

var timer : float
var start_timer : bool = false
var is_timer_finished : bool = false

func _ready() -> void:
	EventBus.game_timer_start.connect(timer_started)
	EventBus.game_timer_update.connect(timer_update)
	
func timer_started(new_time : float) -> void:
	timer = new_time
	start_timer = true
func timer_update(new_time : float) -> void: 
	timer += new_time

func _process(delta: float) -> void:
	if start_timer:
		timer -= delta
		timer_label.text = str("%.0f" % timer)
		print_debug(timer)
		#GameManager.game_timer = timer
		if timer <= 0:
			is_timer_finished = true
	if is_timer_finished:
		game_finished()

func game_finished() -> void: 
	EventBus.game_timer_finished.emit()
	get_tree().quit()
