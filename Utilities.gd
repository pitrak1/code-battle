static func get_absolute_distance(start, end):
	var diff_x = start.x - end.x
	var diff_y = start.y - end.y

	if (diff_x > 0 and diff_y > 0) or (diff_x < 0 and diff_y < 0):
		return max(abs(diff_x), abs(diff_y))
	else:
		return abs(diff_x) + abs(diff_y)