extends CharacterBody2D

var speed = 300
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var launching : bool = false
var launch_direction : Vector2
var can_fall : bool
var exploded : bool
@export var weight : int
#pls work
@onready var HangTimer = $HangTime
@onready var Sprite = $AnimatedSprite2D
@onready var Collider = $CollisionShape2D


func launch(direction : Vector2):
	exploded = false
	can_fall = false
	HangTimer.start()
	launching = true
	launch_direction = direction
	velocity = launch_direction
	Sprite.play("midair")

func _physics_process(delta):
	if (HangTimer.time_left <= 0):
		can_fall = true
	if(can_fall and !exploded):	
		apply_gravity(delta)
	
	if(is_on_floor() or is_on_ceiling() or is_on_wall()):
		explode()
	if (!exploded):
		move_and_slide()
		
func explode():
	exploded =  true
	Collider.disabled = true
	velocity = Vector2.ZERO
	Sprite.play("explosion")
	$Area2D/CollisionShape2D.disabled = false
	await Sprite.animation_finished
	self.queue_free()
	

func apply_gravity(delta):
	velocity.y += gravity * delta


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		body.launch_player()
	else :
		pass
#this is a super cool comment
