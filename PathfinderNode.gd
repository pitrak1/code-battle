var grid_position
var g
var h
var parent

func _init(__grid_position, __g, __end, __parent):
	grid_position = __grid_position
	g = __g
	h = abs(__grid_position.x - __end.x) + abs(__grid_position.y - __end.y)
	parent = __parent

func f():
	return g + h