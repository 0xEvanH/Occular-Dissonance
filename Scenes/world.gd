extends Node3D

@onready var player = $Player

@onready var gate = $Gate

var gateopen = true

func _physics_process(delta):
	get_tree().call_group("enemies", "update_target_location", player.global_transform.origin)
	
	if Inventory.boss_room == true:
		$Alarm.play()
	
	if gateopen == true:
		if Inventory.gate_open == true:
			gate.queue_free()
			gateopen = false

func _on_intro_timer_timeout():
	$Ambience.play()
	$Start.play()
	$Morse.play()
	$Brain.play()
	$Safe.play()
