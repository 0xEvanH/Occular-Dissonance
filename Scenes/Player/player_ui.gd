extends Control

#delegate item icon to item slot

@export var max_slots := 4
var current_slots_filled := 0

var item_slot_1_status: bool = false
var item_slot_2_status: bool = false
var item_slot_3_status: bool = false
var item_slot_4_status: bool = false

@onready var slot_1 = $CanvasLayer/PanelContainer/HBoxContainer/slot_1
@onready var slot_2 = $CanvasLayer/PanelContainer/HBoxContainer/slot_2
@onready var slot_3 = $CanvasLayer/PanelContainer/HBoxContainer/slot_3
@onready var slot_4 = $CanvasLayer/PanelContainer/HBoxContainer/slot_4

var wrench = preload("res://Scenes/Player/ItemIcons/wrench_icon.tscn")
var keycard1 = preload("res://Scenes/Player/ItemIcons/keycard_1_icon.tscn")
var keycard2 = preload("res://Scenes/Player/ItemIcons/keycard_2_icon.tscn")
var keycard3 = preload("res://Scenes/Player/ItemIcons/keycard_3_icon.tscn")


func _process(delta):
	if Inventory.current_hand_index == 1:
		Inventory.in_hand = item_picked_slot_1()
	elif Inventory.current_hand_index == 2:
		Inventory.in_hand = item_picked_slot_2()
	elif Inventory.current_hand_index == 3:
		Inventory.in_hand = item_picked_slot_3()
	elif Inventory.current_hand_index == 4:
		Inventory.in_hand = item_picked_slot_4()
	
	if item_picked_slot_1() == "Wrench":
		if item_slot_1_status == false:
			instance_icon(wrench, slot_1)
			item_slot_1_status = true
	if item_picked_slot_2() == "Keycard1":
		if item_slot_2_status == false:
			instance_icon(keycard1, slot_2)
			item_slot_2_status = true
	if item_picked_slot_3() == "Keycard1":
		if item_slot_3_status == false:
			instance_icon(keycard1, slot_3)
			item_slot_3_status = true
	if item_picked_slot_4() == "Keycard1":
		if item_slot_4_status == false:
			instance_icon(keycard1, slot_4)
			item_slot_4_status = true
	if item_picked_slot_2() == "Keycard2":
		if item_slot_2_status == false:
			instance_icon(keycard2, slot_2)
			item_slot_2_status = true
	if item_picked_slot_3() == "Keycard2":
		if item_slot_3_status == false:
			instance_icon(keycard2, slot_3)
			item_slot_3_status = true
	if item_picked_slot_4() == "Keycard2":
		if item_slot_4_status == false:
			instance_icon(keycard2, slot_4)
			item_slot_4_status = true
	if item_picked_slot_2() == "Keycard3":
		if item_slot_2_status == false:
			instance_icon(keycard3, slot_2)
			item_slot_2_status = true
	if item_picked_slot_3() == "Keycard3":
		if item_slot_3_status == false:
			instance_icon(keycard3, slot_3)
			item_slot_3_status = true
	if item_picked_slot_4() == "Keycard3":
		if item_slot_4_status == false:
			instance_icon(keycard3, slot_4)
			item_slot_4_status = true

func instance_icon(object, slot):
	var icon_inst = object.instantiate()
	slot.add_child(icon_inst)
	icon_inst.global_position = slot.global_position

func item_picked_slot_1():
	var item
	if Inventory.inventory_array.size() >= 1:
		item = Inventory.inventory_array[0]
		return item

func item_picked_slot_2():
	var item
	if Inventory.inventory_array.size() >= 2:
		item = Inventory.inventory_array[1]
		return item

func item_picked_slot_3():
	var item
	if Inventory.inventory_array.size() >= 3:
		item = Inventory.inventory_array[2]
		return item

func item_picked_slot_4():
	var item
	if Inventory.inventory_array.size() >= 4:
		item = Inventory.inventory_array[3]
		return item

func _on_line_edit_text_submitted(new_text):
	if new_text == "5647":
		Inventory.boss_room = true
		$CanvasLayer/PanelContainer2.visible = false
	else:
		$CanvasLayer/PanelContainer2/VBoxContainer/Label.text = "Incorrect."

func _on_cancel_pressed():
	$CanvasLayer/PanelContainer2.visible = false
