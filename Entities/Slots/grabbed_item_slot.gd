extends PanelContainer

var item : Item
var quantity : int = 1

@onready var item_texture: Sprite2D = $ItemTexture
@onready var quantity_label: Label = $QuantityLabel

func _ready() -> void:
	update_grabbed_item()

func _process(_delta : float) -> void:
	if visible:
		global_position = get_global_mouse_position()

func update_grabbed_item() -> void:
	if item:
		item_texture.texture = item.texture
		quantity_label.text = str(quantity)
		show()
		if quantity > 1:
			quantity_label.show()
		else:
			quantity_label.hide()
	else:
		hide()
