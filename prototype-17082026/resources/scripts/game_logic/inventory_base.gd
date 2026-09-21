#Diese Klasse Erlaubt das, Überprüfen, auswechseln, aufnehmen und platzieren
#von Items in einer Control Umgebung. game_manager und event_bus werden.
class_name InventoryBase
extends Control

#Edit these two variables to get zour inventory size!
var inventory_slots : int
var inventory_columns : int

var path_to_textures = "res://assets/textures/products/"
var fallback_texture = preload("res://assets/textures/products/fallback_texture.png")
var empty_slot_texture = preload("res://assets/textures/inventory_slots/empty_slot.png")
var failure_texture = preload("res://assets/textures/icons/failure_cross.png")

var slot_container : GridContainer = GridContainer.new()

enum AnimationState {IN, OUT, FAILURE}

var can_replace_item_slot : bool = true
var can_place_item_in_slot : bool = true
var can_take_item_out_of_slot : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.scale = Vector2(1.4, 1.4)
	set_up_and_create_slots()		#Kreiert die Inventar Slots
	add_container()
func set_up_and_create_slots() -> void:
	slot_container.set_columns(inventory_columns)
	for slot in range(inventory_slots):
		var texture_button : TextureButton = TextureButton.new() 
		var texture_button_bg : TextureRect = TextureRect.new()
		texture_button.set_meta("item_id", "") #Kreiert eine "ID" für den Slot
		texture_button.texture_normal = empty_slot_texture
		texture_button_bg.texture = empty_slot_texture
		slot_container.add_child(texture_button)
		texture_button.add_child(texture_button_bg)
		
		#Bindet die Pick Up funktion an den Button und gibt für die Pick Up funktion den TextureButton und die Slot Nr. weiter.
		texture_button.button_down.connect(pick_up_and_place_item.bind(texture_button, slot))
		
		texture_button.set_size(texture_button_bg.texture.get_size(), false)
		texture_button.set_pivot_offset(texture_button.size / 2) #Zentriert den Pivot vom Slot (Nur für die Anim.)
		#print_debug("Slot kreiert!")
func add_container() -> void: add_child(slot_container)		#Bearbeite mich, für Custom positionen.

func update_slot(slot : TextureButton):
	tween_animation(slot, AnimationState.IN)
	await EventBus.animation_finished
	update_slot_ui(slot)
	tween_animation(slot, AnimationState.OUT)
	EventBus.item_changed.emit()
func update_slot_ui(slot : TextureButton) -> void:
	var current_item_id = get_slot_id(slot)
	
	if current_item_id != "":
		var full_path = get_full_slot_texture_path(slot)
		
		if ResourceLoader.exists(full_path):
			slot.texture_normal = load(full_path)
			slot.tooltip_text = current_item_id.capitalize() #Sollte noch zu einem CUSTOM Tooltip geändert werden!
		else: 
			slot.texture_normal = fallback_texture
			slot.tooltip_text = current_item_id.capitalize()
			push_warning("FEHLER! TEXTUR EXISTIERT NICHT, WECHSLE ZUR FALLBACK TEXTUR!")
		
	else: 
		slot.texture_normal = empty_slot_texture
		slot.tooltip_text = ""

func pick_up_and_place_item(slot : TextureButton, index : int) -> void:
	
	var selected_item : String = get_selected_item()
	var slot_id : String = get_slot_id(slot)
	
	if selected_item.is_empty() && !slot_id.is_empty(): take_item(slot, index)
	elif slot_id.is_empty() && !selected_item.is_empty(): place_item(slot, index)
	elif !selected_item.is_empty() && !slot_id.is_empty(): replace_item(slot, index)
	else: on_item_failure(slot, index)

func take_item(slot : TextureButton, index : int) -> void:
	var old_slot_id : String = get_slot_id(slot)
	print_debug("Take Item")
	#Item ist im Inventar und wird in die Hand gesetzt.
	if can_take_item_out_of_slot:
		slot.set_meta("item_id", "")				#get_slot_id(slot) nicht möglich, da die Globale Variabel bearbeitet wird.
		GameManager.selected_item = old_slot_id 	#get_selected_item() nicht möglich, da die Globale Variabel bearbeitet wird.
		update_slot(slot)
		#print_debug("Item wurde in die Hand gesetzt: ", temp_item_id)
	else:
		on_item_failure(slot, index)
func place_item(slot : TextureButton, index : int) -> void:
	if get_selected_item() != "" && get_slot_id(slot) == "":
		print_debug("Place Item")
		#Item ist in der Hand und wird abgegeben.
		if can_place_item_in_slot:
			if on_item_accept(get_selected_item(), index):
				slot.set_meta("item_id", get_selected_item())	#get_slot_id(slot) nicht möglich, da die Globale Variabel bearbeitet wird.
				GameManager.selected_item = ""					#get_selected_item() nicht möglich, da die Globale Variabel bearbeitet wird.
			
				update_slot(slot)
			
				print_debug("Item wurde in das Inventar gesetzt: ", get_slot_id(slot))
			else:
				on_item_failure(slot, index)
		else: 
			print_debug("Item kann nicht in diesen Slot platziert werden.")
func replace_item(slot : TextureButton, index : int) -> void:
	var old_slot_id = get_slot_id(slot)
	#print_debug("Replace Item")
	if can_replace_item_slot:
		if on_item_accept(get_selected_item(), index):
			slot.set_meta("item_id", get_selected_item())
			GameManager.selected_item = old_slot_id #get_selected_item() nicht möglich, da die Globale Variabel bearbeitet wird.
			update_slot(slot)
		
			print_debug("Inventar und Hand getauscht.")
		else:
			on_item_failure(slot, index)
	else:
		on_item_failure(slot, index)
		print_debug(get_selected_item().capitalize() + " kann nicht mit " + get_slot_id(slot).capitalize() + " getauscht werden!")

func tween_animation(slot : Control, animation_state: AnimationState) -> void:
	
	var tween : Tween = create_tween()
	
	match animation_state:
		AnimationState.IN:
			tween.tween_property(slot, "scale", Vector2.ZERO, 0.05)
			await tween.finished
			tween.kill()
			EventBus.animation_finished.emit()
			
		AnimationState.OUT:
			tween.tween_property(slot, "scale", Vector2.ONE, 0.05)
			
		AnimationState.FAILURE:
			tween.set_loops(5)
			
			tween.tween_property(slot, "modulate", Color(0, 0, 0, 1), 0.1).set_ease(Tween.EASE_IN_OUT)
			tween.tween_property(slot, "modulate", Color(1, 1, 1, 1), 0.1).set_ease(Tween.EASE_IN_OUT)
func create_failure_particles(slot : TextureButton) -> void:
	var cpu_particles : CPUParticles2D
	if slot.get_child(0) is not CPUParticles2D:
		cpu_particles = CPUParticles2D.new()
		var curve : Curve = Curve.new()
		slot.add_child(cpu_particles)
		curve.add_point(Vector2(0, 0))
		curve.add_point(Vector2(0.1, 1))
		curve.add_point(Vector2(0.9, 1))
		curve.add_point(Vector2(1, 0))
		cpu_particles.position = slot.size / 2
		cpu_particles.amount = 1
		cpu_particles.one_shot = true
		cpu_particles.gravity = Vector2(0, 0)
		cpu_particles.texture = failure_texture
		cpu_particles.emitting = true
		cpu_particles.set_param_curve(CPUParticles2D.PARAM_SCALE, curve)
	else:
		cpu_particles.emitting = true
		
func on_item_accept(_item_id : String, _index : int) -> bool:
	return true 
func on_item_failure(slot : TextureButton, index : int) -> void:
	print_debug(get_slot_id(slot).capitalize() + " ist falsch! Slot Nr. " + str(index))
	tween_animation(slot, AnimationState.FAILURE)
	create_failure_particles(slot)

func get_slot_id(slot : TextureButton) -> String : return slot.get_meta("item_id")
func get_selected_item() -> String: return GameManager.selected_item
func get_full_slot_texture_path(slot : TextureButton) -> String: return path_to_textures.path_join(get_slot_id(slot) + ".png")
func get_full_texture_path(texture : String) -> String: return path_to_textures.path_join(texture + ".png")
