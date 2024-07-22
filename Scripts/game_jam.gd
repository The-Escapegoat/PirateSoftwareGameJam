extends Area2D

var bob_speed = 5
var start_y
var t = 0
var d

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.play("idle")
	start_y = global_position.y

func _physics_process(delta):

	t = t + delta
	d = sin(t * bob_speed)
	
	global_position.y = start_y + (bob_speed * d)


func _on_body_entered(body):
	if(body.is_in_group("Player")):
		$AnimatedSprite2D.play("collect")
		await $AnimatedSprite2D.animation_finished
		owner.owner.jam_count += 1
		self.queue_free()
		
