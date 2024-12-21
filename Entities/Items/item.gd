class_name Item
extends Resource

@export var name : String
@export_multiline var description : String
@export var stackable : bool
@export var texture : AtlasTexture

func can_stack_with(other : Item) -> bool:
	return stackable and name == other.name
