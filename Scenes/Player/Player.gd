extends CharacterBody3D

const ACCEL = 10
const DEACCEL = 30

@export_group("PARAMETERS")
@export var SPEED = 5.0
const SPRINT_MULT = 2
@export var CROUCH_MOVE_SPEED = 3.0
@export var CROUCH_SPEED = 2.0
@export var MOUSE_SENSITIVITY = 0.2
@export var max_hp = 100

const default_height = 1.0
const crouch_height = 0.5

@onready var body_collider = $body
@onready var head_check = $HeadCheck

var hp := 100
@onready var healthbar := $Player_UI/CanvasLayer/HealthBar
@onready var dmg_timer = $DmgTimer
var can_take_dmg = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera = $rotation_helper/Camera3D

@onready var rotation_helper = $rotation_helper
var dir = Vector3.ZERO

@onready var grab = $rotation_helper/Camera3D/Grab

@onready var player_wrench = $rotation_helper/Camera3D/Hand/PlayerWrench
@onready var wrench_animation_player = $rotation_helper/Camera3D/Hand/PlayerWrench/AnimationPlayer
@onready var wrench_col = $rotation_helper/Camera3D/Hand/PlayerWrench/CollisionShape3D

@onready var keycard_1 = $rotation_helper/Camera3D/Hand/PlayerKeycard1
@onready var keycard_2 = $rotation_helper/Camera3D/Hand/PlayerKeycard2
@onready var keycard_3 = $rotation_helper/Camera3D/Hand/PlayerKeycard3

@onready var use_message = $Player_UI/CanvasLayer/Use
@onready var pickup_message = $Player_UI/CanvasLayer/Pickup

#INVENTORY
#Hold in a global script
#loop to check what object
#make object enabled when picked
#array to check if inv full

func _ready():
	healthbar.value = hp
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg_to_rad(event.relative.y * MOUSE_SENSITIVITY * -1))
		self.rotate_y(deg_to_rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation
		camera_rot.x = clampf(camera_rot.x, -1.4, 1.4)
		rotation_helper.rotation = camera_rot
	
	# Release/Grab Mouse for debugging. You can change or replace this.
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Inventory.in_hand == "Wrench":
		if Input.is_action_just_pressed("attack"):
			wrench_animation_player.play("whack_h")
	
	if Input.is_action_just_pressed("slot1"):
		Inventory.current_hand_index = 1
	elif Input.is_action_just_pressed("slot2"):
		Inventory.current_hand_index = 2
	elif Input.is_action_just_pressed("slot3"):
		Inventory.current_hand_index = 3
	elif Input.is_action_just_pressed("slot4"):
		Inventory.current_hand_index = 4
	
	if Input.is_action_just_pressed("swap_down"):
		if Inventory.current_hand_index < 5:
			if can_swap:
				if Inventory.current_hand_index >= 4:
					Inventory.current_hand_index = 1
				else:
					Inventory.current_hand_index += 1
				can_swap = false
				scroll_timer.start()
	if Input.is_action_just_pressed("swap_up"):
		if Inventory.current_hand_index > 0:
			if can_swap:
				if Inventory.current_hand_index <= 1:
					Inventory.current_hand_index = 4
				else:
					Inventory.current_hand_index -= 1
				can_swap = false
				scroll_timer.start()

var can_swap = true
@onready var scroll_timer = $ScrollTimer

@onready var animation_player = $rotation_helper/Camera3D/AnimationPlayer

var sprinting = false

func _physics_process(delta):
	var head_hit = false
	var moving = false
	
	if head_check.is_colliding():
		head_hit = true
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if head_hit:
		velocity.y = -2
	
	# Handle Crouch.
	if Input.is_action_pressed("crouch"):
		body_collider.shape.height -= CROUCH_SPEED * delta
		SPEED = CROUCH_MOVE_SPEED
	elif not head_hit:
		body_collider.shape.height += CROUCH_SPEED * delta
	
	body_collider.shape.height = clamp(body_collider.shape.height, crouch_height, default_height)
	
	var accel
	if dir.dot(velocity) > 0:
		accel = ACCEL
		moving = true
	else:
		accel = DEACCEL
		moving = false
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Mright", "Mleft", "Mup", "Mdown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() * accel * delta
	
	if Input.is_key_pressed(KEY_SHIFT):
		direction = direction * SPRINT_MULT
		sprinting = true
	else:
		sprinting = false
	
	if hp <= 0:
		get_tree().reload_current_scene()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		
		if !sprinting:
			handle_footstep_audio(0.6)
		else:
			handle_footstep_audio(0.4)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
	
	if input_dir.y > 0:
		animation_player.play("bob")
	elif input_dir.y < 0:
		animation_player.play("bob")
	else:
		animation_player.stop()
	
	if input_dir.x > 0:
		rotation_helper.rotation.z = lerp_angle(rotation_helper.rotation.z, deg_to_rad(-3), 0.05)
	elif input_dir.x < 0:
		rotation_helper.rotation.z = lerp_angle(rotation_helper.rotation.z, deg_to_rad(3), 0.05)
	else:
		rotation_helper.rotation.z = lerp_angle(rotation_helper.rotation.z, deg_to_rad(0), 0.05)
	
	if Inventory.in_hand == "null":
		player_wrench.visible = false
		keycard_1.visible = false
		keycard_2.visible = false
		keycard_3.visible = false
	if Inventory.in_hand == "Wrench":
		player_wrench.visible = true
		keycard_1.visible = false
		keycard_2.visible = false
		keycard_3.visible = false
	elif Inventory.in_hand == "Keycard1":
		player_wrench.visible = false
		keycard_1.visible = true
		keycard_2.visible = false
		keycard_3.visible = false
	elif Inventory.in_hand == "Keycard2":
		player_wrench.visible = false
		keycard_1.visible = false
		keycard_2.visible = true
		keycard_3.visible = false
	elif Inventory.in_hand == "Keycard3":
		player_wrench.visible = false
		keycard_1.visible = false
		keycard_2.visible = false
		keycard_3.visible = true
	
	#GRABBING
	if grab.get_collider() is StaticBody3D:
		if grab.get_collider().name == "Wrench":
			pickup_message.visible = true
			if Input.is_key_pressed(KEY_E):
				grab.get_collider().queue_free()
				player_wrench.visible = true
				Inventory.wrench = true
				Inventory.in_hand = "Wrench"
				Inventory.inventory_array.append("Wrench")
		if grab.get_collider().name == "Keycard1":
			pickup_message.visible = true
			if Input.is_key_pressed(KEY_E):
				grab.get_collider().queue_free()
				Inventory.keycard_1 = true
				Inventory.inventory_array.append("Keycard1")
		if grab.get_collider().name == "Keycard2":
			pickup_message.visible = true
			if Input.is_key_pressed(KEY_E):
				grab.get_collider().queue_free()
				Inventory.keycard_2 = true
				Inventory.inventory_array.append("Keycard2")
		if grab.get_collider().name == "Keycard3":
			pickup_message.visible = true
			if Input.is_key_pressed(KEY_E):
				grab.get_collider().queue_free()
				Inventory.keycard_3 = true
				Inventory.inventory_array.append("Keycard3")
	else:
		pickup_message.visible = false
	
	if Inventory.inventory_used == Inventory.inventory_space:
		Inventory.inventory_full = true
	
	if grab.get_collider() is StaticBody3D:
		if grab.get_collider().name == "Keydoor_1":
			use_message.visible = true
			if Inventory.in_hand == "Keycard1":
				if Input.is_action_just_pressed("interact"):
					Inventory.open_door_1 = true
					print("woo")
			else:
				$Correct.play()
		elif grab.get_collider().name == "Keydoor_2":
			use_message.visible = true
			if Inventory.in_hand == "Keycard2":
				if Input.is_action_just_pressed("interact"):
					Inventory.open_door_2 = true
			else:
				$Correct.play()
		elif grab.get_collider().name == "Keydoor_3":
			use_message.visible = true
			if Inventory.in_hand == "Keycard3":
				if Input.is_action_just_pressed("interact"):
					Inventory.open_door_3 = true
			else:
				$Correct.play()
		elif grab.get_collider().name == "Gate_Opener":
			use_message.visible = true
			if Input.is_action_just_pressed("interact"):
				Inventory.gate_open = true
		elif grab.get_collider().name == "Medbay" or grab.get_collider().name == "Medbay2":
			use_message.visible = true
			if Input.is_action_just_pressed("interact"):
				hp = 100
				var health_tween = get_tree().create_tween()
				health_tween.tween_property(healthbar, "value", hp, 1)
		elif grab.get_collider().name == "Keypad":
			use_message.visible = true
			if Input.is_action_just_pressed("interact"):
				$Player_UI/CanvasLayer/PanelContainer2.visible = true
	else:
		use_message.visible = false

@export var spider_damage = 10
@export var zombie_damage = 20
@export var gronk_damage = 40

func _on_damage_taker_body_entered(body):
	if can_take_dmg:
		if body.name == "Enemy_1":
			hp -= spider_damage
			var health_tween = get_tree().create_tween()
			health_tween.tween_property(healthbar, "value", hp, 1)
			can_take_dmg = false
			animation_player.play("hurt")
			dmg_timer.start()
		if body.name == "Enemy2":
			hp -= zombie_damage
			var health_tween = get_tree().create_tween()
			health_tween.tween_property(healthbar, "value", hp, 1)
			can_take_dmg = false
			animation_player.play("hurt")
			dmg_timer.start()
		if body.name == "Enemy3":
			hp -= gronk_damage
			var health_tween = get_tree().create_tween()
			health_tween.tween_property(healthbar, "value", hp, 1)
			can_take_dmg = false
			animation_player.play("hurt")
			dmg_timer.start()

@onready var footstep_noise = $Footsteps
@onready var footstep_noise_timer = $Footsteps/Footstep_Timer

func handle_footstep_audio(speed):
	if footstep_noise_timer.time_left <= 0:
		footstep_noise.pitch_scale = randf_range(0.8, 1.2)
		footstep_noise.play()
		footstep_noise_timer.start(speed)

func _on_dmg_timer_timeout():
	can_take_dmg = true

func _on_scroll_timer_timeout():
	can_swap = true
