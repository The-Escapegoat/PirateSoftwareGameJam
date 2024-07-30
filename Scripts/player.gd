extends CharacterBody2D

#pls work

const SPEED = 200.0
const ACCELERATION = 1400.0
const FRICTION = 2000.0
const JUMP_VELOCITY = -350.0

@export var player_launch_amount = 300

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var shoot_name : String

var facing_direction : int = 1

var bomb_direction : Vector2

@export var side_point : Marker2D
@export var up_point : Marker2D
@export var up_side_point : Marker2D
@export var down_side_point : Marker2D
@export var down_point : Marker2D
@export var launch_power : int
@export var explosion_power : int
var selected_point : Marker2D

var current_checkpoint : Vector2

var is_shooting : bool

var can_move : bool = true
var can_shoot : bool = true

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyotye_jump_timer = $CoyoteJumpTimer
@onready var cooldown = $Cooldown
@onready var bomb = preload("res://Scenes/bomb.tscn")
@onready var footsteps = $footsteps
@onready var jump_sfx = $jump_sfx
@onready var death_sfx = $death_sfx

@onready var jump_buffer_timer = $JumpBuffer
@onready var shoot_buffer_timer = $ShootBuffer
var jump_buffered : bool = false
var shoot_buffered : bool = false


func _physics_process(delta):
	if(can_move):
		select_point()
		if(cooldown.time_left == 0):
			can_shoot = true
			
		if (Input.is_action_just_pressed("Shoot") or shoot_buffered) and can_shoot:
			shoot()
		elif Input.is_action_just_pressed("Shoot") and !can_shoot:
			shoot_buffered = true
			shoot_buffer_timer.start()
			
		apply_gravity(delta)
		handle_jump()
		var input_axis = Input.get_axis("Left", "Right")
		input_axis = roundi(input_axis)
		handle_acceleration(input_axis, delta)
		apply_friction(input_axis, delta)
		update_animations(input_axis)
		var was_on_floor = is_on_floor()
		if (can_move):
			move_and_slide()
			
		var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
		if just_left_ledge:
			coyotye_jump_timer.start()
		
func shoot():
	can_shoot = false
	cooldown.start()
	velocity.y -= velocity.y/2
	is_shooting = true
	var b = bomb.instantiate()
	b.position = selected_point.global_position
	owner.add_child(b)
	b.launch(bomb_direction * launch_power)
	self.velocity += -bomb_direction * player_launch_amount

func select_point():
	var input_vector : Vector2 = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
	roundi(input_vector.x)
	roundi(input_vector.y)
	input_vector = input_vector.normalized()
	if(!is_shooting):
		if(input_vector == Vector2.ZERO or (input_vector.y == 0 and input_vector.x != 0)):
			selected_point = side_point
			shoot_name = "shootSide"
			bomb_direction = Vector2(facing_direction, 0)
		if(input_vector.y < -0.01 and input_vector.x == 0):
			selected_point = up_point
			shoot_name = "shootUp"
			bomb_direction = Vector2(0, -1)
		if(input_vector.y < -0.1 and input_vector.x != 0):
			selected_point = up_side_point
			shoot_name = "shootUpSide"
			bomb_direction = Vector2(facing_direction, -1)
		if(input_vector.y > 0.1 and input_vector.x == 0):
			selected_point = down_point
			shoot_name = "shootDown"
			bomb_direction = Vector2(0, 1)
		if(input_vector.y > 0.1 and input_vector.x != 0):
			selected_point = down_side_point
			shoot_name = "shootDownSide"
			bomb_direction = Vector2(facing_direction, 1)
		bomb_direction = bomb_direction.normalized()
	

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		
func handle_jump():
	
	if(Input.is_action_just_pressed("Jump") and !is_on_floor()):
		jump_buffered = true
		jump_buffer_timer.start()
	if is_on_floor() or coyotye_jump_timer.time_left > 0.0:		
		if Input.is_action_just_pressed("Jump") or jump_buffered:
			velocity.y = JUMP_VELOCITY
			jump_sfx.pitch_scale = randf_range(1.0, 1.4)
			jump_sfx.play()
	if not is_on_floor():
		if Input.is_action_just_released("Jump") and velocity.y < JUMP_VELOCITY/2 and !is_shooting:
			velocity.y = JUMP_VELOCITY/2
			
func apply_friction(input_axis, delta):
	if input_axis == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
func handle_acceleration(input_axis, delta):
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, SPEED * input_axis, ACCELERATION * delta)
		
func update_animations(input_axis):
	if(!is_shooting and can_move):
		if input_axis == -facing_direction:
			self.scale.x *= -1
			facing_direction *= -1
			
		if (input_axis != 0):
			animated_sprite_2d.play("run")
			if animated_sprite_2d.frame == 0 or animated_sprite_2d.frame == 4:
				footsteps.pitch_scale = randf_range(1.0, 1.4)
				footsteps.play()
		else:
			animated_sprite_2d.play("idle")
		if not is_on_floor():
			if velocity.y < 0:
				animated_sprite_2d.play("up")
			elif(velocity.y > 0):
				animated_sprite_2d.play("down")
	else:
		animated_sprite_2d.play(shoot_name)
		await animated_sprite_2d.animation_finished
		is_shooting = false
		
func launch_player(direction : Vector2):
	direction = -bomb_direction
	velocity = direction * explosion_power


func _on_shoot_buffer_timeout():
	shoot_buffered = false
	
func _on_jump_buffer_timeout():
	jump_buffered = false
	
func death():
	velocity = Vector2.ZERO
	owner.deaths += 1
	can_move = false
	animated_sprite_2d.play("death")
	death_sfx.pitch_scale = randf_range(1.0, 1.4)
	death_sfx.play()
	await animated_sprite_2d.animation_finished
	self.global_position = current_checkpoint
	can_move = true
