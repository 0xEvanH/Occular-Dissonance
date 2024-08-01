extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

var SPEED = 3.0
const JUMP_VELOCITY = 6

@export var hp = 2

var added_velocity = 8.0

var can_take_dmg = true

@onready var animated_sprite_3d = $AnimatedSprite3D

var player_found = false

var alive = true

@onready var hit = $Hit

#stop and jump at player when in range
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if alive:
		
		var current_location = global_transform.origin
		var next_location = nav_agent.get_next_path_position()
		var new_velocity
		if can_jump == false:
			new_velocity = (next_location - current_location).normalized() * SPEED
		elif can_jump == true:
			new_velocity = (next_location - current_location).normalized() * added_velocity
		
		if player_found:
			nav_agent.set_velocity(new_velocity)
	
	if Inventory.GAME_WON == true:
		$Death.visible = false
		$DeathHuman.visible = true
	
	if hp <= 0 and alive == true:
		velocity = Vector3.ZERO
		$DeathSound.play()
		$AnimatedSprite3D.visible = false
		$Death.visible = true
		alive = false

func update_target_location(target_location):
	if player_found:
		nav_agent.target_position = target_location

func _on_navigation_agent_3d_target_reached():
	pass

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if alive:
		velocity = velocity.move_toward(safe_velocity, .25)
		move_and_slide()

func _on_player_detect_body_entered(body):
	if alive:
		can_jump = true
		if can_jump:
			velocity.y = JUMP_VELOCITY
			$Jump.play()
			animated_sprite_3d.play("jump")
			jump_timer.start()

var can_jump = false
@onready var jump_timer = $Jump_Timer

func _on_jump_timer_timeout():
	can_jump = false

@onready var dmgtimer = $Weapon_Detect/DmgTimer

func _on_weapon_detect_body_entered(body):
	if can_take_dmg:
		hp -= 1
		$Screech.play()
		hit.play()
		can_take_dmg = false
		dmgtimer.start()

func _on_dmg_timer_timeout():
	can_take_dmg = true

func _on_floor_check_body_entered(body):
	animated_sprite_3d.play("default")

func _on_follow_player_body_entered(body):
	player_found = true

func _on_follow_player_body_exited(body):
	player_found = false
