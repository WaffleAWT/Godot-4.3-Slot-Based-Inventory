extends Node2D

const COLLECTABLE_SCENE : PackedScene = preload("res://Entities/Components/Collectable/collectable.tscn")

@export var player : CharacterBody2D

func full_drop(item : Item, quantity : int) -> void:
	var collectable = COLLECTABLE_SCENE.instantiate()
	collectable.item = item
	collectable.quantity = quantity
	collectable.global_position = player.global_position
	get_tree().current_scene.call_deferred("add_child", collectable)

func single_drop(item : Item) -> void:
	var collectable = COLLECTABLE_SCENE.instantiate()
	collectable.item = item
	collectable.quantity = 1
	collectable.global_position = player.global_position
	get_tree().current_scene.add_child(collectable)
