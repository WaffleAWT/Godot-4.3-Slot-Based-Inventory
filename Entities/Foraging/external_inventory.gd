extends StaticBody2D

@export var inventory_scene : PackedScene
@export var animator : AnimatedSprite2D
@export_enum("storage", "workstation") var type

var inventories_container
var inventory
var work_animator : AnimationPlayer

func _ready() -> void:
	inventories_container = get_tree().get_first_node_in_group("inventories_container")
	var furnace_inventory = inventory_scene.instantiate()
	inventories_container.add_child(furnace_inventory)
	inventory = furnace_inventory
	inventory.hide()
	
	if type == 1:
		inventory.work_updated.connect(work_updated)
		for child in get_children():
			if child is AnimationPlayer:
				work_animator = child
				break

func work_updated(working : bool) -> void:
	if working:
		animator.play("working")
		if work_animator:
			work_animator.play("working")
	else:
		animator.play("idle")
		if work_animator:
			work_animator.play("idle")

func toggle_inventory() -> void:
	if inventory.visible:
		inventory.hide()
		if type == 0:
			animator.play("close")
	else:
		inventory.show()
		if type == 0:
			animator.play("open")
