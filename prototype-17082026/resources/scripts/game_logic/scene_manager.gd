extends Node

enum AnimationState {IN, OUT}

var scene_curtain : TextureRect = TextureRect.new()
var scene_curtain_pos = Vector2(0, -720)

func _ready() -> void:
	add_child(scene_curtain)
	scene_curtain.texture = load("res://assets/textures/icons/scene_transition_bg.png")
	scene_curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	scene_curtain.set_position(scene_curtain_pos)

func change_scene(scene_to_load : String):
	on_scene_change_animation(AnimationState.IN)
	await EventBus.animation_finished
	get_tree().change_scene_to_file(scene_to_load)
	on_scene_change_animation(AnimationState.OUT)

func on_scene_change_animation(animation_state : AnimationState):
	var tweeny : Tween = create_tween()
	match animation_state:
		AnimationState.IN:
			scene_curtain.visible = true
			tweeny.tween_property(scene_curtain, "global_position", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_EXPO)
			await tweeny.finished
			EventBus.animation_finished.emit()
		AnimationState.OUT:
			tweeny.tween_property(scene_curtain, "global_position", scene_curtain_pos, 0.2).set_ease(Tween.EASE_IN)
			await tweeny.finished
			scene_curtain.visible = false
			if scene_curtain.position != scene_curtain_pos:
				scene_curtain.set_position(scene_curtain_pos)
