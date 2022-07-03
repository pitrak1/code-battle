var __node = preload("res://PathfinderNode.gd")

const MAP_WIDTH = 9
const MAP_HEIGHT = 9

class FSorter:
	static func sort_f(a, b):
		if a.f() < b.f():
			return true
		return false

func run(world, start, end):
	var open = []
	var closed = {}
	var current_low = __node.new(start, 0, end, null)

	open.push_back(current_low)

	while len(open) > 0 and current_low.grid_position != end:
		current_low = __find_lowest_f(open)

		var __children = __get_adjacent_children(world, current_low, end)

		for __child in __children:
			__add_child_to_open_list(open, closed, __child)

		closed[str(current_low.grid_position.x) + '_' + str(current_low.grid_position.y)] = current_low.f()
			
			
	var results = []
	while current_low.parent != null:
		results.push_back(current_low.grid_position)
		current_low = current_low.parent
		
	results.invert()
	return results


func __add_child_to_open_list(open, closed, child):
	for __open in open:
		if __open.grid_position == child.grid_position and __open.f() < child.f():
			return

	var closed_key = str(child.grid_position.x) + '_' + str(child.grid_position.y)
	if closed.has(closed_key):
		if closed.get(closed_key) < child.f():
			return

	# print('ADDING')
	# print(child.grid_position)

	open.push_back(child)

func __find_lowest_f(open):
	open.sort_custom(FSorter, 'sort_f')
	return open.pop_front()

func __get_adjacent_children(world, parent, end):
	var __children = []
	var lowest_g = parent.g

	# left
	if parent.grid_position.y > 1:
		var __pos = parent.grid_position + Vector2(0, -1)
		if world.is_passable(__pos):
			__children.push_back(__node.new(__pos, lowest_g + 1, end, parent))

	# upleft
	if parent.grid_position.y > 1 and  parent.grid_position.x > 1:
		var __pos = parent.grid_position + Vector2(-1, -1)
		if world.is_passable(__pos):
			__children.push_back(__node.new(__pos, lowest_g + 1, end, parent))

	# upright
	if parent.grid_position.x > 1:
		var __pos = parent.grid_position + Vector2(-1, 0)
		if world.is_passable(__pos):
			__children.push_back(__node.new(__pos, lowest_g + 1, end, parent))

	# right
	if parent.grid_position.y < MAP_WIDTH - 1:
		var __pos = parent.grid_position + Vector2(0, 1)
		if world.is_passable(__pos):
			__children.push_back(__node.new(__pos, lowest_g + 1, end, parent))

	# rightdown
	if parent.grid_position.y < MAP_WIDTH - 1 and parent.grid_position.x < MAP_HEIGHT - 1:
		var __pos = parent.grid_position + Vector2(1, 1)
		if world.is_passable(__pos):
			__children.push_back(__node.new(__pos, lowest_g + 1, end, parent))

	# leftdown
	if parent.grid_position.x < MAP_HEIGHT - 1:
		var __pos = parent.grid_position + Vector2(1, 0)
		if world.is_passable(__pos):
			__children.push_back(__node.new(__pos, lowest_g + 1, end, parent))

	return __children
