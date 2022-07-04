static func get_absolute_distance(start, end):
	var diff_x = start.x - end.x
	var diff_y = start.y - end.y

	if (diff_x > 0 and diff_y > 0) or (diff_x < 0 and diff_y < 0):
		return max(abs(diff_x), abs(diff_y))
	else:
		return abs(diff_x) + abs(diff_y)

static func parse_arguments(token_set):
	var args = []
	var current_index = 0

	var current_arg = parse_until_matching_separator(token_set, current_index, '(', ',')
	while current_arg:
		current_index += len(current_arg) + 1
		args.push_back(current_arg)
		current_arg = parse_until_matching_separator(token_set, current_index, '(', ',')

	return args

static func parse_until_matching_separator(token_set, starting_index, matching_separator, additional_values):
	var separators = []
	var end_index = starting_index

	while end_index < token_set.size():
		var value = token_set[end_index].value
		if value in Consts.MATCHED_SEPARATORS:
			if not len(separators) and value == Consts.MATCHING_SEPARATORS[matching_separator]:
				return token_set.slice(starting_index, end_index - 1)
			elif len(separators) and value == Consts.MATCHING_SEPARATORS[separators.back()]:
				separators.pop_back()
				end_index += 1
			else:
				separators.push_back(value)
				end_index += 1
		elif not len(separators) and value in additional_values:
			return token_set.slice(starting_index, end_index - 1)
		else:
			end_index += 1
