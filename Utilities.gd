static func get_absolute_distance(start, end):
	var diff_x = start.x - end.x
	var diff_y = start.y - end.y

	if (diff_x > 0 and diff_y > 0) or (diff_x < 0 and diff_y < 0):
		return max(abs(diff_x), abs(diff_y))
	else:
		return abs(diff_x) + abs(diff_y)

static func get_assignment_operator_index(token_set):
	for i in range(token_set.size()):
		if token_set[i].type == Consts.TOKEN_TYPES.ASSIGNMENT:
			return i

static func get_mathematical_operator_index(token_set):
	var operator_priority = Consts.OPERATORS.size()
	var operator_location = Consts.OPERATORS.size()

	var args = []
	var separators = []

	for i in range(token_set.size() - 1, 0, -1):
		if token_set[i].value in Consts.CLOSING_SEPARATORS:
				separators.push_back(token_set[i].value)
		elif len(separators) and token_set[i].value == Consts.MATCHING_SEPARATORS[separators.back()]:
			separators.pop_back()
		elif token_set[i].type == Consts.TOKEN_TYPES.OPERATOR and len(separators) == 0:
			var current_operator_priority = Consts.OPERATORS.find(token_set[i].value)
			if current_operator_priority < operator_priority:
				operator_priority = current_operator_priority
				operator_location = i

	if operator_priority != Consts.OPERATORS.size():
		return operator_location

static func parse_object_definition(token_set):
	var values = parse_end_until_matching_separator(token_set, [','])
	var entries = values['entries']

	var pairs = []
	for i in range(entries.size()):
		var entry = entries[i]
		for j in range(entry.size()):
			if entry[j].value == ':':
				pairs.push_back([entry.slice(0, j - 1), entry.slice(j + 1, entry.size() - 1)])

	return pairs

static func parse_end_until_matching_separator(token_set, additional_values):
	var separators = [token_set.back().value]
	var entries = []
	var start_index = token_set.size() - 2
	var end_index = token_set.size() - 2

	while start_index >= 0 and len(separators) > 0:
		var value = token_set[start_index].value
		if value in Consts.CLOSING_SEPARATORS:
			separators.push_back(value)
		elif value == Consts.MATCHING_SEPARATORS[separators.back()]:
			separators.pop_back()
		elif len(separators) == 1 and value in additional_values:
			entries.push_back(token_set.slice(start_index + 1, end_index))
			end_index = start_index - 1
		start_index -= 1
	
	entries.push_back(token_set.slice(start_index + 2, end_index))
	entries.invert()

	var length = token_set.size() - 1 - (start_index + 1)
	return {'entries': entries, 'length': length }
