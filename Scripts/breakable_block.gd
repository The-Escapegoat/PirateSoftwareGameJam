extends StaticBody2D
@onready var bolk = $Bolk


func on_bomb():
	bolk.pitch_scale = randf_range(1.0, 1.4)
	bolk.play()
	self.queue_free()
