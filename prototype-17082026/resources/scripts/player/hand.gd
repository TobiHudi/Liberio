extends Control

@export_dir var path_to_textures
var texture_rect : TextureRect = TextureRect.new()
var fallback_texture = preload("res://assets/textures/products/fallback_texture.png")
var tweeny : Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(texture_rect)
	EventBus.item_changed.connect(update_texture)
	texture_rect.pivot_offset = texture_rect.size / 2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position() + Vector2(20, 20)

func update_texture() -> void:
	if tweeny and tweeny.is_valid():
		tweeny.kill()
		texture_rect.scale = Vector2.ONE
		
	var full_path = path_to_textures.path_join(GameManager.selected_item + ".png")
	if full_path != path_to_textures + ".png":
		if ResourceLoader.exists(full_path):
			texture_rect.texture = load(full_path)
			#print_debug("Updating Texture...")
			start_pulsing_animation()
		else: texture_rect.texture = fallback_texture
	else:
		texture_rect.texture = null
		#print_debug("Texture wird entfernt...")

func start_pulsing_animation() -> void:
	tweeny = create_tween()
	tweeny.set_loops()
	
	tweeny.tween_property(texture_rect, "scale", Vector2(0.8, 0.8), 0.2)
	tweeny.tween_property(texture_rect, "scale", Vector2(1, 1), 0.2)
