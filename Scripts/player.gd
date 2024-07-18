extends CharacterBody2D

#pls work

const SPEED = 200.0
const ACCELERATION = 1400.0
const FRICTION = 1400.0
const JUMP_VELOCITY = -300.0

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
var selected_point : Marker2D

var is_shooting : bool

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyotye_jump_timer = $CoyoteJumpTimer
@onready var bomb = preload("res://Scenes/bomb.tscn")


func _physics_process(delta):
	select_point()
	if Input.is_action_just_pressed("Shoot"):
		shoot()
	apply_gravity(delta)
	handle_jump()
	var input_axis = Input.get_axis("Left", "Right")
	handle_acceleration(input_axis, delta)
	apply_friction(input_axis, delta)
	update_animations(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	var just_left_ledge = was_on_floor and not is_on_floor() and velocity.y >= 0
	if just_left_ledge:
		coyotye_jump_timer.start()
		
func shoot():
	is_shooting = true
	var b = bomb.instantiate()
	b.position = selected_point.global_position
	owner.add_child(b)
	b.launch(bomb_direction * launch_power)
	self.velocity += -bomb_direction * player_launch_amount

func select_point():
	var input_vector : Vector2 = Vector2(Input.get_axis("Left", "Right"), Input.get_axis("Up", "Down"))
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
	if is_on_floor() or coyotye_jump_timer.time_left > 0.0:		
		if Input.is_action_just_pressed("Jump"):
			velocity.y = JUMP_VELOCITY
	if not is_on_floor():
		if Input.is_action_just_released("Jump") and velocity.y < JUMP_VELOCITY/2:
			velocity.y = JUMP_VELOCITY/2
			
func apply_friction(input_axis, delta):
	if input_axis == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
func handle_acceleration(input_axis, delta):
	if input_axis != 0:
		velocity.x = move_toward(velocity.x, SPEED * input_axis, ACCELERATION * delta)
		
func update_animations(input_axis):
	if(!is_shooting):
		if input_axis == -facing_direction:
			self.scale.x *= -1
			facing_direction *= -1
			
		if (input_axis != 0):
			animated_sprite_2d.play("run")
			
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


