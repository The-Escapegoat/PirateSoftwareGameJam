extends CharacterBody2D

var speed = 300
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var launching : bool = false
var launch_direction : Vector2
var can_fall : bool
@export var weight : int
#pls work
@onready var HangTimer = $HangTime

func launch(direction : Vector2):
	can_fall = false
	HangTimer.start()
	launching = true
	launch_direction = direction
	velocity = launch_direction

func _physics_process(delta):
	if (HangTimer.time_left <= 0):
		can_fall = true
	if(can_fall):	
		apply_gravity(delta)
		
	if(is_on_floor() or is_on_ceiling() or is_on_wall()):
		explode()
	move_and_slide()
		
func explode():
	print("boom")
	self.queue_free()

func apply_gravity(delta):
	velocity.y += gravity * delta
