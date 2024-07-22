extends Node2D

@export var current_room : Room
@export var jam_count : int
@export var rooms : Array

var temp

func _ready():
	temp = jam_count
	print(jam_count)

func _process(_delta):
	if temp != jam_count:
		print(jam_count)
		temp = jam_count
