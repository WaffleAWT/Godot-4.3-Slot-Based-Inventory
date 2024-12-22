extends PanelContainer

@onready var slot_1 : PanelContainer = $HBoxContainer/Slot
@onready var slot_2 : PanelContainer = $HBoxContainer/Slot2
@onready var slot_3 : PanelContainer = $HBoxContainer/Slot3
@onready var slot_4 : PanelContainer = $HBoxContainer/Slot4
@onready var slot_5 : PanelContainer = $HBoxContainer/Slot5
@onready var highlight : Sprite2D = $Highlight

func _ready() -> void:
	owner.player.active_item = slot_1.item
	highlight.offset.x = 0.0

func _input(event : InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("1") and slot_1.item:
			owner.player.active_item = slot_1.item
			highlight.offset.x = 0.0
		if Input.is_action_just_pressed("2") and slot_2.item:
			owner.player.active_item = slot_2.item
			highlight.offset.x = 28.0
		if Input.is_action_just_pressed("3") and slot_3.item:
			owner.player.active_item = slot_3.item
			highlight.offset.x = 56.0
		if Input.is_action_just_pressed("4") and slot_4.item:
			owner.player.active_item = slot_4.item
			highlight.offset.x = 84.0
		if Input.is_action_just_pressed("5") and slot_5.item:
			owner.player.active_item = slot_5.item
			highlight.offset.x = 112.0

func slot_updated(slot) -> void:
	match slot:
		slot_1:
			if highlight.offset.x == 0.0:
				owner.player.active_item = slot_1.item
		slot_2:
			if highlight.offset.x == 28.0:
				owner.player.active_item = slot_2.item
		slot_3:
			if highlight.offset.x == 56.0:
				owner.player.active_item = slot_3.item
		slot_4:
			if highlight.offset.x == 84.0:
				owner.player.active_item = slot_4.item
		slot_5:
			if highlight.offset.x == 112.0:
				owner.player.active_item = slot_5.item
		_:
			pass
