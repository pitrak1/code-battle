var Utilities = preload("res://Utilities.gd")

var grid_position
var g
var h
var parent

func _init(__grid_position, __g, __end, __parent):
	grid_position = __grid_position
	g = __g
	h = Utilities.get_absolute_distance(__grid_position, __end)
	parent = __parent

func f():
	return g + h