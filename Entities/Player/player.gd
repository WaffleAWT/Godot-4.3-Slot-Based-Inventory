extends CharacterBody2D

const MAX_SPEED : float = 80.0
const ACCELERATION : float = 500.0
const DECELERATION : float = 500.0

@export var animator : AnimatedSprite2D
@export var interaction_area : Area2D

var target
var inventory : PanelContainer
var active_item : Item : set = set_active_item

func _ready() -> void:
	inventory = get_tree().get_first_node_in_group("player_inventory")

func _physics_process(delta : float) -> void:
	var input_vector : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animator.play("run")
		if input_vector.x > 0.0:
			animator.flip_h = false
		elif input_vector.x < 0.0:
			animator.flip_h = true
	else:
		velocity = velocity.move_toward(Vector2.ZERO, DECELERATION * delta)
		animator.play("idle")
	
	move_and_slide()

func _input(event : InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("esc"):
			get_tree().quit()
		
		if Input.is_action_just_pressed("toggle_inventory"):
			toggle_inventory()
			close_external_inventories()
		
		if Input.is_action_just_pressed("interact") and target:
			if target.is_in_group("external_inventory_owner"):
				target.toggle_inventory()
				if not inventory.visible and target.inventory.visible:
					toggle_inventory()

func set_active_item(value : Item) -> void:
	active_item = value
	if active_item:
		pass
	else:
		pass

func toggle_inventory() -> void:
	inventory.toggle_inventory()

func close_external_inventories() -> void:
	if target and target.is_in_group("external_inventory_owner") and target.inventory.visible:
		target.toggle_inventory()

func add_item_to_inventory(item : Item, quantity : int) -> bool:
	if inventory:
		return inventory.add_item_to_inventory(item, quantity)
	return false

func _on_interaction_area_body_entered(body : Node2D) -> void:
	if not target:
		target = body

func _on_interaction_area_body_exited(body : Node2D) -> void:
	if body == target:
		close_external_inventories()
		if inventory.visible:
			toggle_inventory()
		target = null
