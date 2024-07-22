extends Node2D
class_name Room

var player
@onready var camera_point = $CameraPoint

func _ready():
	if(player == null):
		player = get_tree().get_nodes_in_group("Player")[0]
		if self.position.distance_to(player.position) < 1500:
			reload_room()
	check_load_state()
	owner.rooms.append(self)
	
		
func check_load_state():
	if self.position.distance_to(player.position) > 1500 and self.process_mode == 0:
		unload_room()
	elif self.position.distance_to(player.position) <= 1500 and self.process_mode == 4:
		reload_room()
	else:
		pass

func unload_room():
	self.process_mode = 4
	self.hide()
	print("unloaded ", self.name)
	
func reload_room():
	self.process_mode = 0
	self.show()
	print("loaded ", self.name)


func _on_area_2d_body_entered(_body):
	if _body.is_in_group("Player"):
		owner.current_room = self
	else:
		pass

