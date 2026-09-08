extends Node

enum AnimationState {IN, OUT}
@export var item_to_animate : TextureRect

func change_scene(scene_to_load : String):
	on_scene_change_animation(AnimationState.IN)
	await EventBus.animation_finished
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file(scene_to_load)
	on_scene_change_animation(AnimationState.OUT)
	

func on_scene_change_animation(animation_state : AnimationState):
	var tweeny : Tween = create_tween()
	match animation_state:
		AnimationState.IN:
			tweeny.tween_property(item_to_animate, "global_position", Vector2(0, 0), 0.5).set_trans(Tween.TRANS_EXPO)
			await tweeny.finished
			EventBus.animation_finished.emit()
		AnimationState.OUT:
			tweeny.tween_property(item_to_animate, "global_position", Vector2(0, -650), 0.2).set_ease(Tween.EASE_IN)
