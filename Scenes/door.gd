extends Node3D

@export var door_number = 1

var door_open = true

@onready var open = $Open

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if door_number == 1 and Inventory.open_door_1 == true:
		if door_open:
			$AnimationPlayer.play("open")
			open.play()
			door_open = false
	if door_number == 2 and Inventory.open_door_2 == true:
		if door_open:
			$AnimationPlayer.play("open")
			open.play()
			door_open = false
	if door_number == 3 and Inventory.open_door_3 == true:
		if door_open:
			$AnimationPlayer.play("open")
			open.play()
			door_open = false
	if door_number == 4 and Inventory.boss_room == true:
		if door_open:
			$AnimationPlayer.play("open")
			open.play()
			door_open = false
	if door_number == 5 and Inventory.wrench == true:
		if door_open:
			$AnimationPlayer.play("open")
			open.play()
			door_open = false
