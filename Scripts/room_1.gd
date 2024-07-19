extends Node2D
class_name Room

var player
@onready var camera_point = $CameraPoint

func _ready():
	if(player == null):
		player = get_tree().get_nodes_in_group("Player")[0]
		if self.position.distance_to(player.position) < 1500:
			reload_room()
	
func _physics_process(_delta):
	
	if self.position.distance_to(player.position) > 1500:
		unload_room()
	elif self.position.distance_to(player.position) < 1500:
		reload_room()
		
func unload_room():
	self.process_mode = 4
	self.hide()
	
func reload_room():
	self.process_mode = 0
	self.show()






func _on_area_2d_body_entered(body):
	if body.is_in_group("Player"):
		print(self.name)
		owner.current_room = self
	else:
		pass

func _on_area_2d_body_exited(body):
	pass # Replace with function body.
