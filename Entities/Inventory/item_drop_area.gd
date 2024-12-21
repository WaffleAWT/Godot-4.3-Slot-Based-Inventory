extends Control

var grabbed_item_slot

func _ready() -> void:
	grabbed_item_slot = get_tree().get_first_node_in_group("grabbed_item")

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()):
		handle_left_click()
	elif event is InputEventMouseButton and (event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed()):
		handle_right_click()

func handle_left_click() -> void:
	if grabbed_item_slot.item:
		owner.full_drop(grabbed_item_slot.item, grabbed_item_slot.quantity)
		grabbed_item_slot.item = null
		grabbed_item_slot.quantity = 1
		grabbed_item_slot.update_grabbed_item()

func handle_right_click() -> void:
	if grabbed_item_slot.item:
		if grabbed_item_slot.quantity > 1:
			grabbed_item_slot.quantity -= 1
			owner.single_drop(grabbed_item_slot.item)
			grabbed_item_slot.update_grabbed_item()
		elif grabbed_item_slot.quantity == 1:
			owner.single_drop(grabbed_item_slot.item)
			grabbed_item_slot.item = null
			grabbed_item_slot.quantity = 1
			grabbed_item_slot.update_grabbed_item()
