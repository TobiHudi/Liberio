extends Control

@export_dir var path_to_textures
var texture_rect : TextureRect = TextureRect.new()
var fallback_texture = preload("res://assets/textures/products/fallback_texture.png")
var tweeny : Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_hand_properties()
#adds all connections and properties for Hand.
func add_hand_properties() -> void:
	add_child(texture_rect)
	texture_rect.pivot_offset = texture_rect.size / 2
	EventBus.item_changed.connect(tweeny_animation)
	EventBus.item_changed.connect(update_hand_texture)
#Updates Hand texture, if it exists.
func update_hand_texture() -> void:
	var full_path = path_to_textures.path_join(GameManager.selected_item + ".png")
	if full_path != path_to_textures + ".png":
		if ResourceLoader.exists(full_path):
			texture_rect.texture = load(full_path)
		else: texture_rect.texture = fallback_texture
	else:
		texture_rect.texture = null
#TextureRect mouse follow logic
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position() + Vector2(20, 20)

#Creates a pulsing animation for the held item.
func tweeny_animation() -> void:
	if GameManager.selected_item == "":
		if tweeny and tweeny.is_valid():
			tweeny.kill()
		#Resets TextureRect size.
		texture_rect.scale = Vector2.ONE
	else:
		#Plays animation.
		tweeny = create_tween()
		tweeny.set_loops()
		tweeny.tween_property(texture_rect, "scale", Vector2(0.8, 0.8), 0.2)
		tweeny.tween_property(texture_rect, "scale", Vector2(1, 1), 0.2)
