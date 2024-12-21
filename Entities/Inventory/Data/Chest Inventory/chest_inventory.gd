extends PanelContainer

var grabbed_item_slot

@onready var slots_container: GridContainer = $VBoxContainer/SlotsContainer

func _ready() -> void:
	grabbed_item_slot = get_tree().get_first_node_in_group("grabbed_item")
	visible = false

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
