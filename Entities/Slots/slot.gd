extends PanelContainer

const MAX_STACK_SIZE : int = 25

const EMPTY_SLOT_TEXTURE : CompressedTexture2D = preload("res://Entities/Slots/Art/Empty Slot.png")
const FULL_SLOT_TEXTURE : CompressedTexture2D = preload("res://Entities/Slots/Art/Full Slot.png")

@export_enum("fuel", "smeltable", "product") var type
@export var item : Item
@export_range(1, MAX_STACK_SIZE) var quantity : int = 1

var grabbed_item_slot
var item_tooltip

@export_group("Dependencies")
@export var slot_texture: TextureRect
@export var item_texture: Sprite2D
@export var quantity_label: Label

func _ready() -> void:
	update_slot()
	grabbed_item_slot = get_tree().get_first_node_in_group("grabbed_item")
	item_tooltip = get_tree().get_first_node_in_group("item_tooltip")

func _on_gui_input(event : InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()):
		handle_left_click()
	elif event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed()):
		handle_right_click()

func _on_mouse_entered() -> void:
	if item:
		show_tooltip()

func _on_mouse_exited() -> void:
	item_tooltip.hide()

func handle_left_click() -> void:
	if not grabbed_item_slot.item and item: #Grabbed slot is empty
		grab_item()
	elif not item and grabbed_item_slot.item and slots_do_match(): #Clicked slot is empty
		drop_item()
	elif item and grabbed_item_slot.item: #Both slots have items
		if item.can_stack_with(grabbed_item_slot.item):
			stack_items()
		else:
			swap_items()

func handle_right_click() -> void:
	if grabbed_item_slot.item: #If the grabbed slot is not empty
		if not item and slots_do_match(): #If the clicked slot is empty
			drop_single_item()
		elif item.can_stack_with(grabbed_item_slot.item):  #If the clicked slot has the same item
			stack_single_item()
		else: #Swap if the items don't match
			swap_items()
	elif item: #If the grabbed slot is empty but the clicked slot has an item
		grab_item()

func grab_item() -> void:
	if type == 1 and owner.smelting_in_progress:
		return
	
	item_tooltip.hide()
	grabbed_item_slot.item = item
	grabbed_item_slot.quantity = quantity
	grabbed_item_slot.update_grabbed_item()
	
	item = null
	quantity = 1
	update_slot()

func drop_item() -> void:
	item = grabbed_item_slot.item
	quantity = grabbed_item_slot.quantity
	update_slot()
	
	grabbed_item_slot.item = null
	grabbed_item_slot.quantity = 1
	grabbed_item_slot.update_grabbed_item()
	show_tooltip()

func stack_items() -> void:
	var total_quantity = quantity + grabbed_item_slot.quantity
	
	if total_quantity <= MAX_STACK_SIZE:
		quantity = total_quantity
		grabbed_item_slot.item = null
		grabbed_item_slot.quantity = 1
		grabbed_item_slot.update_grabbed_item()
	else:
		var remaining = total_quantity - MAX_STACK_SIZE
		quantity = MAX_STACK_SIZE
		grabbed_item_slot.quantity = remaining
		grabbed_item_slot.update_grabbed_item()
	
	update_slot()

func swap_items() -> void:
	if slots_do_match() and not type == 1:
		var temp_item = item
		var temp_quantity = quantity
		
		item = grabbed_item_slot.item
		quantity = grabbed_item_slot.quantity
		
		grabbed_item_slot.item = temp_item
		grabbed_item_slot.quantity = temp_quantity
		
		update_slot()
		grabbed_item_slot.update_grabbed_item()
		show_tooltip()

func drop_single_item() -> void:
	if not item:
		item = grabbed_item_slot.item
		quantity = 1
		grabbed_item_slot.quantity -= 1
		if grabbed_item_slot.quantity <= 0:
			grabbed_item_slot.item = null
			grabbed_item_slot.quantity = 1
		grabbed_item_slot.update_grabbed_item()
	
	update_slot()

func stack_single_item() -> void:
	if quantity < MAX_STACK_SIZE:
		quantity += 1
		grabbed_item_slot.quantity -= 1
		if grabbed_item_slot.quantity <= 0:
			grabbed_item_slot.item = null
			grabbed_item_slot.quantity = 1
		grabbed_item_slot.update_grabbed_item()
	
	update_slot()

func update_slot() -> void:
	if item:
		slot_texture.texture = FULL_SLOT_TEXTURE
		item_texture.texture = item.texture
		item_texture.show()
		if quantity > 1 and not item.stackable:
			quantity = 1
			push_error("%s is not stackable, setting quantity to 1" % item.name)
		elif quantity > 1:
			quantity_label.text = str(quantity)
			quantity_label.show()
		else:
			quantity_label.hide()
	else:
		slot_texture.texture = EMPTY_SLOT_TEXTURE
		item_texture.hide()
		quantity_label.hide()

func slots_do_match() -> bool:
	match type:
		0:
			return grabbed_item_slot.item is ItemFuel
		1:
			return grabbed_item_slot.item is ItemSmeltable
		2:
			return false
		_:
			return true

func show_tooltip() -> void:
	item_tooltip.label.text = "%s\n%s" % [item.name, item.description]
	item_tooltip.show()
