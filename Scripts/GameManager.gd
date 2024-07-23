extends Node2D

@export var current_room : Room
@export var rooms : Array

var jam_count : int = 0
var deaths : int = 0
var time : float = 0.0
var msec : int = 0
var sec : int = 0
var min  : int = 0

var has_won : bool = false

@onready var win_scene = preload("res://Scenes/win_screen.tscn")

var temp

func _ready():
	temp = jam_count

func _process(delta):
	if temp != jam_count:
		temp = jam_count
	if(!has_won):
		time += delta
	elif(has_won):
		win()
	else:
		pass
		
func win():
	has_won = true
	var children = get_children()
	for i in children:
		i.queue_free()
	var b = win_scene.instantiate()
	b.position = Vector2.ZERO
	add_child(b)
	b.deaths = deaths
	b.time = time
	b.jam_count = jam_count
	b.win()



func _on_area_2d_body_entered(body):
	win()
