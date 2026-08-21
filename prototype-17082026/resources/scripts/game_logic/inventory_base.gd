#Diese Klasse Erlaubt das, Überprüfen, auswechseln, aufnehmen und platzieren
#von Items in einer Control Umgebung. game_manager und event_bus werden.
class_name InventoryBase
extends Node

@export var slot_container : Container

@export var inventory_slots : int = 5
var path_to_textures = "res://assets/textures/products/"
var fallback_texture = preload("res://assets/textures/products/fallback_texture.png")
var empty_slot_texture = preload("res://assets/textures/products/empty_slot.png")

var can_replace_item_slot : bool = true
var can_place_item_in_slot : bool = true
var can_take_item_out_of_slot : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	create_slots()		#Kreiert die Inventar Slots
func create_slots() -> void:
	for slot in range(inventory_slots):
		#Kreiert ein TextureButton als Ghost in der Memory.
		var texture_button : TextureButton = TextureButton.new() 
		texture_button.set_meta("item_id", "") #Kreiert eine "ID" für 
		texture_button.texture_normal = empty_slot_texture
		#Bindet die Pick Up funktion an den Button und gibt für die Pick Up funktion den TextureButton und die Slot Nr. weiter.
		texture_button.button_down.connect(pick_up_and_place_item.bind(texture_button, slot)) 
		slot_container.add_child(texture_button) #Fügt den Ghost aus der Memory in das Spiel als Kind vom Slot Container.
		#print_debug("Slot kreiert!")

#Kann bei belieben in anderen Scripts bearbeitet werden um z.b. einen gewisse ID zu verlangen, an einem bestimmten Slot.
func on_item_accept(_item_id : String, _index : int) -> bool:
	return true 
	
#Kann bei belieben in anderen Scripts bearbeitet werden um z.b. einen gewisse ID als feedback zu geben.
func on_item_failure(item_id : String, index : int) -> void:
	print_debug(item_id.capitalize() + " ist falsch! Slot Nr. " + str(index))
	
#Updated die Textur auf den neuesten stand. Es muss nur der Slot klarerweise referiert werden.
#ToDo -> Custom Tooltip!
func update_slot_ui(slot : TextureButton):
	var item_id = slot.get_meta("item_id")
	
	slot.pivot_offset = slot.size / 2
	var tweeny_out : Tween = create_tween()
	tweeny_out.tween_property(slot, "scale", Vector2.ZERO, 0.05)
	await tweeny_out.finished
	
	if item_id != "":
		var full_path = path_to_textures.path_join(item_id + ".png")
		
		if ResourceLoader.exists(full_path):
			slot.texture_normal = load(full_path)
			slot.tooltip_text = item_id.capitalize() #Sollte noch zu einem CUSTOM Tooltip geändert werden!
		else: 
			slot.texture_normal = fallback_texture
			slot.tooltip_text = item_id.capitalize()
			push_warning("FEHLER! TEXTUR EXISTIERT NICHT, WECHSLE ZUR FALLBACK TEXTUR!")
		
	else: 
		slot.texture_normal = empty_slot_texture
		slot.tooltip_text = ""
	
	var tweeny_in : Tween = create_tween()
	tweeny_in.tween_property(slot, "scale", Vector2.ONE, 0.05)
	EventBus.item_changed.emit()

func pick_up_and_place_item(slot : TextureButton, index : int) -> void:
	
	var temp_item_id : String = slot.get_meta("item_id")
	var temp_selected_item_id : String = GameManager.selected_item
	
	if GameManager.selected_item == "" && temp_item_id != "":
		#Item ist im Inventar und wird in die Hand gesetzt.
		if can_take_item_out_of_slot:
			slot.set_meta("item_id", "")
			GameManager.selected_item = temp_item_id
			update_slot_ui(slot)
			#print_debug("Item wurde in die Hand gesetzt: ", temp_item_id)
		else:
			print_debug(temp_item_id.capitalize() + " kann hier nicht entfernt werden.")

	elif GameManager.selected_item != "" && temp_item_id == "":
		#Item ist in der Hand und wird abgegeben.
		if can_place_item_in_slot:
			if on_item_accept(temp_selected_item_id, index):
				slot.set_meta("item_id", GameManager.selected_item)
				GameManager.selected_item = ""
			
				update_slot_ui(slot)
			
				print_debug("Item wurde in das Inventar gesetzt: ", slot.get_meta("item_id"))
			else:
				on_item_failure(temp_selected_item_id, index)
		else: 
			print_debug("Item kann nicht in diesen Slot platziert werden.")
		

	elif GameManager.selected_item != "" && temp_item_id != "":
		#Item wird getauscht.
		
		if can_replace_item_slot:
			if on_item_accept(temp_selected_item_id, index):
				slot.set_meta("item_id", GameManager.selected_item)
				GameManager.selected_item = temp_item_id
			
				update_slot_ui(slot)
			
				print_debug("Inventar und Hand getauscht.")
			else:
				on_item_failure(temp_selected_item_id, index)
		else:
			print_debug(temp_selected_item_id.capitalize() + " kann nicht mit " + temp_item_id.capitalize() + " getauscht werden!")
	else:
		print_debug("Inventar und Hand leer.")
