extends Camera2D

var stored_room : Room
@export var speed: int
var target_position
var transitioning : bool = false
var player

func _ready():
	player = get_tree().get_nodes_in_group("Player")[0]
	stored_room = owner.current_room	
func _physics_process(delta):
	if stored_room != owner.current_room and !transitioning:
		transitioning = true
		if(stored_room.global_position.y > owner.current_room.position.y and transitioning == true):
			player.velocity.y -= 200
			player.gravity = player.gravity/2
			await get_tree().create_timer(0.2).timeout
			player.gravity = player.gravity * 2
		change_rooms()
	if(target_position != null):
		global_position.x = move_toward(global_position.x, target_position.x, speed * delta)
		global_position.y = move_toward(global_position.y, target_position.y, speed * delta)

func change_rooms():
	stored_room = owner.current_room	
	target_position = owner.current_room.camera_point.global_position
	transitioning = false
	for i in owner.rooms:
		i.check_load_state()
	
	
	
