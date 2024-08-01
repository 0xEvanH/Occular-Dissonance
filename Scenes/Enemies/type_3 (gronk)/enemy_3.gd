extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

var SPEED = 1.0
const JUMP_VELOCITY = 10

@export var hp = 5

var added_velocity = 8.0

var can_take_dmg = true

var player_found = false

#stop and jump at player when in range
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var hit = $Hit

#charge
var alive = true

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if alive:
		
		var current_location = global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity
		new_velocity = (next_location - current_location).normalized() * SPEED
		
		if player_found:
			nav_agent.set_velocity(new_velocity)
	
		handle_footstep_audio(3)
	
	if Inventory.GAME_WON == true:
		$Death.visible = false
		$DeathHuman.visible = true
	
	if hp <= 0 and alive == true:
		velocity = Vector3.ZERO
		$AnimatedSprite3D.visible = false
		$Death.visible = true
		Inventory.GAME_WON = true
		alive = false

func update_target_location(target_location):
	if player_found:
		nav_agent.target_position = target_location

func _on_navigation_agent_3d_target_reached():
	pass

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	velocity = velocity.move_toward(safe_velocity, .25)
	move_and_slide()

func _on_player_detect_body_entered(body):
	pass

@onready var dmgtimer = $Weapon_Detect/DmgTimer

func _on_weapon_detect_body_entered(body):
	if can_take_dmg:
		hp -= 1
		hit.play()
		can_take_dmg = false
		dmgtimer.start()

func _on_dmg_timer_timeout():
	can_take_dmg = true

func _on_follow_player_body_entered(body):
	player_found = true

func _on_follow_player_body_exited(body):
	player_found = false

@onready var gronk_noise = $Gronk
@onready var gronk_timer = $Gronk/Timer

func handle_footstep_audio(speed):
	if gronk_timer.time_left <= 0:
		gronk_noise.pitch_scale = randf_range(0.8, 1.2)
		gronk_noise.play()
		gronk_timer.start(speed)
