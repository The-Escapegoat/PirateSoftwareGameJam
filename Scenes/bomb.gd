extends CharacterBody2D

var speed = 300
var direction = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	position.x += speed * direction*delta
