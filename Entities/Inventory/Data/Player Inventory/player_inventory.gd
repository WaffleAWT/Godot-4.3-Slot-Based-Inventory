extends PanelContainer

var grabbed_item_slot

@onready var slots_container: GridContainer = $VBoxContainer/SlotsContainer

func _ready() -> void:
	grabbed_item_slot = get_tree().get_first_node_in_group("grabbed_item")
	visible = false

func toggle_inventory() -> void:
	if visible:
		handle_grabbed_item()
	visible = !visible

func handle_grabbed_item() -> void:
	if not grabbed_item_slot.item:
		return
	
	for slot in slots_container.get_children():
		if slot.item and slot.item.can_stack_with(grabbed_item_slot.item):
			#Attempt to stack with this slot
			var total_quantity = slot.quantity + grabbed_item_slot.quantity
			if total_quantity <= slot.MAX_STACK_SIZE:
				#Entire stack fits in the slot
				slot.quantity = total_quantity
				grabbed_item_slot.item = null
				grabbed_item_slot.quantity = 0
				grabbed_item_slot.update_grabbed_item()
				slot.update_slot()
				return
			else:
				#Part of the stack fits, leave the remainder in the grabbed slot
				var remaining = total_quantity - slot.MAX_STACK_SIZE
				slot.quantity = slot.MAX_STACK_SIZE
				grabbed_item_slot.quantity = remaining
				grabbed_item_slot.update_grabbed_item()
				slot.update_slot()
	
	#If no stackable slot is found, try to place in the first empty slot
	for slot in slots_container.get_children():
		if not slot.item:
			slot.item = grabbed_item_slot.item
			slot.quantity = grabbed_item_slot.quantity
			grabbed_item_slot.item = null
			grabbed_item_slot.quantity = 0
			grabbed_item_slot.update_grabbed_item()
			slot.update_slot()
			return
	
	#If neither stacking nor placement in an empty slot is possible
	owner.full_drop(grabbed_item_slot.item, grabbed_item_slot.quantity)
	grabbed_item_slot.item = null
	grabbed_item_slot.quantity = 1
	grabbed_item_slot.update_grabbed_item()

func add_item_to_inventory(item : Item, quantity : int) -> bool:
	#Attempt to stack with an existing slot
	for slot in slots_container.get_children():
		if slot.item and slot.item.can_stack_with(item):
			var total_quantity = slot.quantity + quantity
			if total_quantity <= slot.MAX_STACK_SIZE:
				#Entire stack fits in the slot
				slot.quantity = total_quantity
				slot.update_slot()
				return true
			else:
				#Part of the stack fits; leave the remainder
				slot.quantity = slot.MAX_STACK_SIZE
				quantity = total_quantity - slot.MAX_STACK_SIZE
				slot.update_slot()
	
	#Try to find an empty slot for the remainder
	for slot in slots_container.get_children():
		if not slot.item:
			slot.item = item
			slot.quantity = quantity
			slot.update_slot()
			return true
	
	#If no space is available, return false
	return false

func has_space_for_item(item: Item, quantity: int) -> bool:
	#Check for stackable slots
	for slot in slots_container.get_children():
		if slot.item and slot.item.can_stack_with(item):
			var available_space = slot.MAX_STACK_SIZE - slot.quantity
			if available_space >= quantity:
				return true  #Slot has enough space to stack
	
	#Check for empty slots
	for slot in slots_container.get_children():
		if not slot.item:
			return true  #An empty slot is available
	
	return false  #No space for the item
