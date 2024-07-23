extends Control

var jam_count : int = 0
var time : float = 0.0
var msec : int = 0
var sec : int = 0
var min  : int = 0
var deaths : int = 0

func win():
	msec = fmod(time, 1) * 100
	sec = fmod(time, 60)
	min = fmod(time, 3600 )/60
	$Time.text = "%02d:%02d.%03d" % [min, sec, msec]
	$Jam.text = str(jam_count)
	$Deaths.text = str(deaths)
