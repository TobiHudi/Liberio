extends CanvasLayer

var player_ui_panel_container : PanelContainer = PanelContainer.new()
var player_info_label : Label = Label.new()

func _ready() -> void:
	add_child(player_ui_panel_container)
	player_ui_panel_container.add_child(player_info_label)
	player_ui_panel_container.custom_minimum_size = Vector2(0, 50)
	player_ui_panel_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	player_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
#PLACEHOLDER -> Make it Event Based, instead of updating this every frame!!!!
func _process(delta: float) -> void:
	player_info_label.text = "Points: " + str(GameManager.player_points) + "             Multiplier: " + str(GameManager.points_multiplier) + "             Selected Shelf: " + str(GameManager.selected_shelf.capitalize())
