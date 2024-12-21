extends Area2D

@export var speed : float = 200.0
@export var pick_up_distance : float = 10.0
@export var item : Item
@export var quantity : int = 1

var target_body: Node2D = null
var can_pick_up : bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	sprite_2d.texture = item.texture

func _process(delta : float) -> void:
	if target_body and can_pick_up:
		#Check if the item can be added to the inventory before moving
		if item and quantity > 0:
			var inventory_has_space = target_body.inventory.has_space_for_item(item, quantity)
			if not inventory_has_space:
				return  #Exit if there's no space
		
		var direction = (target_body.global_position - global_position).normalized()
		global_position += direction * speed * delta
		
		if global_position.distance_to(target_body.global_position) <= pick_up_distance:
			if item and quantity > 0:
				var success = target_body.add_item_to_inventory(item, quantity)
				if success:
					queue_free()
				else:
					print("Inventory full! Could not collect item.")

func _on_body_entered(body : Node2D) -> void:
	if can_pick_up:
		target_body = body

func _on_timer_timeout() -> void:
	can_pick_up = true

func _on_body_exited(_body : Node2D) -> void:
	target_body = null
