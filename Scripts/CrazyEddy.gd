extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Sprite2D.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	$Sprite2D.visible = true
