extends CharacterBody2D

var speed = 300
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var launching : bool = false
var launching_player : bool = false
var launch_direction : Vector2
var can_fall : bool
var exploded : bool
@export var weight : int
#pls work
@onready var HangTimer = $HangTime
@onready var Sprite = $AnimatedSprite2D
@onready var Collider = $CollisionShape2D
@onready var explosion_sfx = $explosion_sfx


func launch(direction : Vector2):
	exploded = false
	launching_player = false
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
	
	if ((is_on_floor() or is_on_ceiling() or is_on_wall()) and !exploded):
		explode()
	if (!exploded):
		move_and_slide()
		
func explode():
	exploded =  true
	Collider.disabled = true
	velocity = Vector2.ZERO
	Sprite.play("explosion")
	explosion_sfx.pitch_scale = randf_range(1.0, 1.4)
	explosion_sfx.play()
	$Area2D/CollisionShape2D.disabled = false
	await get_tree().create_timer(0.1).timeout
	if($Area2D/CollisionShape2D != null):
		$Area2D/CollisionShape2D.queue_free()
	await Sprite.animation_finished
	self.queue_free()
	

func apply_gravity(delta):
	velocity.y += gravity * delta


func _on_area_2d_body_entered(body):
	if body.is_in_group("Player") and !launching_player:
		launching_player = true
		body.launch_player((body.position - position).normalized())
	elif body.is_in_group("Bombable"):
		body.on_bomb()
	else :
		pass
#this is a super cool comment
