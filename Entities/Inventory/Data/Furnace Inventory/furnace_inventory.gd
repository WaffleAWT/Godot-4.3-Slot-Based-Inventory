extends VBoxContainer

signal work_updated(working)

@export var fuel_slot : PanelContainer
@export var smeltable_slot : PanelContainer
@export var output_slot : PanelContainer
@export var progress_bar : ProgressBar
@export var fuel_timer : Timer
@export var smeltable_timer : Timer

var working : bool = false : set = set_working

func _ready() -> void:
	progress_bar.value = 0.0

func _process(_delta : float) -> void:
	if visible:
		handle_smelt()

func set_working(value : bool) -> void:
	working = value
	work_updated.emit(value)
	if not working:
		smeltable_timer.stop()
		progress_bar.value = 0.0

func handle_smelt() -> void:
	if not working and fuel_slot.item and smeltable_slot.item:
		if output_slot.item == null or (output_slot.item.can_stack_with(smeltable_slot.item.product) and output_slot.quantity < output_slot.MAX_STACK_SIZE):
			smelt(true)
	update_progress_bar()

func update_progress_bar() -> void:
	if not smeltable_timer.is_stopped():
		if smeltable_slot.item:
			var elapsed_time = smeltable_slot.item.time_to_smelt - smeltable_timer.time_left
			progress_bar.value = (elapsed_time / smeltable_slot.item.time_to_smelt) * progress_bar.max_value
		else:
			progress_bar.value = 0.0

func smelt(add_extra_time : bool) -> void:
	if add_extra_time:
		fuel_timer.start(fuel_slot.item.burn_time + 0.1)
	else:
		fuel_timer.start(fuel_slot.item.burn_time)
	
	fuel_slot.quantity -= 1
	fuel_slot.update_slot()
	if fuel_slot.quantity <= 0:
		fuel_slot.item = null
		fuel_slot.quantity = 1
		fuel_slot.update_slot()
	if not working:
		smeltable_timer.start(smeltable_slot.item.time_to_smelt)
		working = true

func complete_smelt() -> void:
	working = false
	
	var smeltable_item = smeltable_slot.item as ItemSmeltable
	
	#Handle output placement
	if output_slot.item == null and smeltable_item:
		output_slot.item = smeltable_item.product
		output_slot.quantity = 1
	elif output_slot.item.can_stack_with(smeltable_item.product) and output_slot.quantity < output_slot.MAX_STACK_SIZE and smeltable_item:
		output_slot.quantity += 1
	
	#Reduce smeltable quantity or clear slot
	if smeltable_item:
		smeltable_slot.quantity -= 1
		if smeltable_slot.quantity <= 0:
			smeltable_slot.item = null
			smeltable_slot.quantity = 1
		smeltable_slot.update_slot()
	
	#Reset progress bar
	progress_bar.value = 0
	
	#Update slots
	fuel_slot.update_slot()
	output_slot.update_slot()

func _on_smeltable_timer_timeout() -> void:
	if working:
		complete_smelt()

func _on_fuel_timer_timeout() -> void:
	if fuel_slot.item and smeltable_slot.item:
		smelt(false)
	else:
		working = false
