#Diese Klasse Erlaubt das, Überprüfen, auswechseln, aufnehmen und platzieren
#von Items in einer Control Umgebung. game_manager und event_bus werden.
class_name InventoryBase
extends Node

@export var slot_container : Container

@export var inventory_slots : int = 5
var path_to_textures = "res://assets/textures/products/"
var fallback_texture = preload("res://assets/textures/products/fallback_texture.png")
var empty_slot_texture = preload("res://assets/textures/products/empty_slot.png")

enum AnimationState {IN, OUT, FAILURE}

var can_replace_item_slot : bool = true
var can_place_item_in_slot : bool = true
var can_take_item_out_of_slot : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_up_and_create_slots()		#Kreiert die Inventar Slots
func set_up_and_create_slots() -> void:
	for slot in range(inventory_slots):
		#Kreiert ein TextureButton als Ghost in der Memory.
		var texture_button : TextureButton = TextureButton.new() 
		texture_button.set_meta("item_id", "") #Kreiert eine "ID" für den Slot
		texture_button.texture_normal = empty_slot_texture
		slot_container.add_child(texture_button)
		#Bindet die Pick Up funktion an den Button und gibt für die Pick Up funktion den TextureButton und die Slot Nr. weiter.
		texture_button.button_down.connect(pick_up_and_place_item.bind(texture_button, slot)) 
		
		texture_button.pivot_offset = texture_button.size / 2 #Zentriert den Pivot vom Slot (Nur für die Anim.)
		#print_debug("Slot kreiert!")

#Diese zwei funktionen aktualisieren den Slot.
#ToDo -> Custom Tooltip!
func update_slot(slot : TextureButton):
	tween_animation(slot, AnimationState.IN)
	await EventBus.animation_finished
	update_slot_ui(slot)
	tween_animation(slot, AnimationState.OUT)
	EventBus.item_changed.emit()
func update_slot_ui(slot : TextureButton) -> void:
	var current_item_id = get_slot_id(slot)
	
	if current_item_id != "":
		var full_path = path_to_textures.path_join(current_item_id + ".png")
		
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
	
	if selected_item.is_empty() && !slot_id.is_empty(): take_item(slot)
	elif slot_id.is_empty() && !selected_item.is_empty(): place_item(slot, index)
	elif !selected_item.is_empty() && !slot_id.is_empty(): replace_item(slot, index)
	else: print_debug("Hand ist Leer")

func take_item(slot : TextureButton) -> void:
	var old_slot_id : String = get_slot_id(slot)
	print_debug("Take Item")
	#Item ist im Inventar und wird in die Hand gesetzt.
	if can_take_item_out_of_slot:
		slot.set_meta("item_id", "")					#get_slot_id(slot) nicht möglich, da die Globale Variabel bearbeitet wird.
		GameManager.selected_item = old_slot_id 	#get_selected_item() nicht möglich, da die Globale Variabel bearbeitet wird.
		update_slot(slot)
		#print_debug("Item wurde in die Hand gesetzt: ", temp_item_id)
	else:
		
		print_debug(get_slot_id(slot).capitalize() + " kann hier nicht entfernt werden.")

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
				on_item_failure(get_selected_item(), index)
		else: 
			print_debug("Item kann nicht in diesen Slot platziert werden.")

func replace_item(slot : TextureButton, index : int) -> void:
	var old_slot_id = get_slot_id(slot)
	print_debug("Replace Item")
	#Item wird getauscht.
	if can_replace_item_slot:
		if on_item_accept(get_selected_item(), index):
			slot.set_meta("item_id", get_selected_item())
			GameManager.selected_item = old_slot_id #get_selected_item() nicht möglich, da die Globale Variabel bearbeitet wird.
		
			update_slot(slot)
		
			print_debug("Inventar und Hand getauscht.")
		else:
			on_item_failure(get_selected_item(), index)
	else:
		print_debug(get_selected_item().capitalize() + " kann nicht mit " + get_slot_id(slot).capitalize() + " getauscht werden!")

func tween_animation(slot : TextureButton, animation_state: AnimationState) -> void:
	
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
			tween.tween_property(slot, "modulate", Color(1, 0, 0, 1), 0.1)
			tween.tween_property(slot, "modulate", Color(1, 1, 1, 1), 0.1)

#Kann bei belieben in anderen Scripts bearbeitet werden um z.b. einen gewisse ID zu verlangen, an einem bestimmten Slot.
func on_item_accept(_item_id : String, _index : int) -> bool:
	return true 
	
#Kann bei belieben in anderen Scripts bearbeitet werden um z.b. einen gewisse ID als feedback zu geben.
func on_item_failure(item_id : String, index : int) -> void:
	print_debug(item_id.capitalize() + " ist falsch! Slot Nr. " + str(index))

func get_slot_id(slot : TextureButton) -> String : return slot.get_meta("item_id")
func get_selected_item() -> String: return GameManager.selected_item
