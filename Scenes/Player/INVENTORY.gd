extends Node

var inventory_space := 4
var inventory_used := 0
var inventory_full := false

var in_hand = "null"
var current_hand_index = 1

var inventory_array: Array = []

var wrench = false
var keycard_1 = false
var keycard_2 = false
var keycard_3 = false

var open_door_1 = false
var open_door_2 = false
var open_door_3 = false
var boss_room = false
var gate_open = false

var GAME_WON = false

#list other objects
