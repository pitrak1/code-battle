var Instruction = preload("res://interpreter/Instruction.gd")
var KeyValuePair = preload("res://interpreter/KeyValuePair.gd")

func run(token_set):
	var assignment_index = __get_assignment_operator_index(token_set)
	var operation_index = __get_mathematical_operator_index(token_set)

	if assignment_index:
		return __handle_assignment(token_set, assignment_index)
	elif token_set[0].type == Consts.TOKEN_TYPES.KEYWORD:
		return __handle_keyword(token_set)
	elif token_set[0].type == Consts.TOKEN_TYPES.SEPARATOR:
		return __handle_separator(token_set)
	elif operation_index:
		return __handle_operation(token_set, operation_index)
	elif token_set[0].type == Consts.TOKEN_TYPES.IDENTIFIER:
		return __handle_identifier(token_set)
	elif token_set[0].type == Consts.TOKEN_TYPES.NUMBER:
		return __handle_number(token_set)
	elif token_set[0].type == Consts.TOKEN_TYPES.STRING:
		return __handle_string(token_set)
	elif token_set[0].type == Consts.TOKEN_TYPES.BOOLEAN:
		return __handle_boolean(token_set)

func __get_assignment_operator_index(token_set):
	for i in range(token_set.size()):
		if token_set[i].type == Consts.TOKEN_TYPES.ASSIGNMENT:
			return i

func __get_mathematical_operator_index(token_set):
	var operator_priority = Consts.OPERATORS.size()
	var operator_location = Consts.OPERATORS.size()

	var in_square_brackets = false

	for i in range(token_set.size() - 1, 0, -1):
		if token_set[i].value == ']':
			in_square_brackets = true
		elif token_set[i].value == '[':
			in_square_brackets = false
		elif token_set[i].type == Consts.TOKEN_TYPES.OPERATOR and not in_square_brackets:
			var current_operator_priority = Consts.OPERATORS.find(token_set[i].value)
			if current_operator_priority < operator_priority:
				operator_priority = current_operator_priority
				operator_location = i

	if operator_priority != Consts.OPERATORS.size():
		return operator_location

func __handle_assignment(token_set, assignment_index):
	return Instruction.new().set_operation(
		Consts.INSTRUCTION_TYPES.ASSIGNMENT,
		'=',
		run(token_set.slice(0, assignment_index - 1)),
		run(token_set.slice(assignment_index + 1, token_set.size() - 1))
	)

func __handle_keyword(token_set):
	if token_set[0].value == 'var':
		return __handle_var(token_set)
	elif token_set[0].value == 'export':
		return __handle_export(token_set)
	elif token_set[0].value == 'print':
		return __handle_print(token_set)
	elif token_set[0].value == 'highlight':
		return __handle_highlight(token_set)
	elif token_set[0].value == 'if' or token_set[0].value == 'while':
		return __handle_if_while(token_set)
	elif token_set[0].value == 'function':
		return __handle_function(token_set)
	elif token_set[0].value == 'return':
		return __handle_return(token_set)

func __handle_var(token_set):
	assert(token_set.size() == 2)
	assert(token_set[1].type == Consts.TOKEN_TYPES.IDENTIFIER)
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.DECLARATION, token_set[1].value)

func __handle_export(token_set):
	assert(token_set.size() == 3)
	assert(token_set[1].type == Consts.TOKEN_TYPES.KEYWORD)
	assert(token_set[1].value == 'var')
	assert(token_set[2].type == Consts.TOKEN_TYPES.IDENTIFIER)
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.DECLARATION, token_set[2].value, true)

func __handle_print(token_set):
	assert(token_set[1].value == '(')
	assert(token_set[token_set.size() - 1].value == ')')

	var instruction_range
	if token_set.size() <= 3:
		instruction_range = run(token_set.slice(2, 2))
	else:
		instruction_range = run(token_set.slice(2, token_set.size() - 2))

	return Instruction.new().set_call(Consts.INSTRUCTION_TYPES.BUILTIN, 'print', [instruction_range])

func __handle_highlight(token_set):
	assert(token_set[1].value == '(')
	assert(token_set[token_set.size() - 1].value == ')')

	var instruction_start = 2
	var instruction_end = 2

	var args = []

	while instruction_end < token_set.size():
		if token_set[instruction_end + 1].type == Consts.TOKEN_TYPES.SEPARATOR:
			if token_set[instruction_end + 1].value == ',':
				args.push_back(run(token_set.slice(instruction_start, instruction_end)))
				instruction_start = instruction_end + 2
				instruction_end = instruction_start
			elif token_set[instruction_end + 1].value == ')':
				args.push_back(run(token_set.slice(instruction_start, instruction_end)))
				break
			else:
				instruction_end += 1

	return Instruction.new().set_call(Consts.INSTRUCTION_TYPES.BUILTIN, 'highlight', args)

func __handle_if_while(token_set):
	assert(token_set[1].value == '(')
	assert(token_set[token_set.size() - 1].value == ')')

	var instruction_start = 2
	var instruction_end = 2

	var expression

	while instruction_end < token_set.size():
		if token_set[instruction_end + 1].value == ')':
			expression = run(token_set.slice(instruction_start, instruction_end))
			break
		else:
			instruction_end += 1

	var type
	if token_set[0].value == 'if':
		type = Consts.INSTRUCTION_TYPES.IF
	else:
		type = Consts.INSTRUCTION_TYPES.WHILE
	return Instruction.new().set_if(type, expression)

func __handle_operation(token_set, operation_index):
	return Instruction.new().set_operation(
		Consts.INSTRUCTION_TYPES.OPERATION,
		token_set[operation_index].value,
		run(token_set.slice(0, operation_index - 1)),
		run(token_set.slice(operation_index + 1, token_set.size() - 1))
	)

func __handle_separator(token_set):
	if token_set[0].value == '[':
		var index = 1
		var results = []
		var current_set_start = 1
		while token_set[index].value != ']':
			if token_set[index].value == ',':
				results.push_back(run(token_set.slice(current_set_start, index - 1)))
				current_set_start = index + 1
			index += 1
		results.push_back(run(token_set.slice(current_set_start, index - 1)))
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.ARRAY, results)
	elif token_set[0].value == '{':
		var index = 1
		var results = []
		var current_set_start = index
		var key
		while token_set[index].value != '}':
			if token_set[index].value == ':':
				key = run(token_set.slice(current_set_start, index - 1))
				current_set_start = index + 1
			elif token_set[index].value == ',':
				results.push_back(KeyValuePair.new().set(key, run(token_set.slice(current_set_start, index - 1))))
				current_set_start = index + 1
			index += 1
		results.push_back(KeyValuePair.new().set(key, run(token_set.slice(current_set_start, index - 1))))
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.OBJECT, results)

func __handle_identifier(token_set):
	if (token_set.size() == 1):
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.VARIABLE, token_set[0].value)
	elif token_set[1].value == '[':
		assert(token_set[token_set.size() - 1].value == ']')
		return Instruction.new().set_index(Consts.INSTRUCTION_TYPES.INDEX, token_set[0].value, run(token_set.slice(2, token_set.size() - 2)))
	elif token_set[1].value == '(':
		assert(token_set[token_set.size() - 1].value == ')')

		var args = []

		var argument_start = 2
		var argument_end = 2
		if token_set[2].value != ')':
			while argument_end < token_set.size():
				if token_set[argument_end + 1].value == ',' or token_set[argument_end + 1].value == ')':
					var instruction = run(token_set.slice(argument_start, argument_end))
					args.push_back(instruction)
					argument_start = argument_end + 2
					argument_end = argument_end + 2
				else:
					argument_end += 1

		return Instruction.new().set_call(Consts.INSTRUCTION_TYPES.CALL, token_set[0].value, args)

func __handle_number(token_set):
	assert(token_set.size() == 1)
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.NUMBER, int(float(token_set[0].value)))

func __handle_string(token_set):
	assert(token_set.size() == 1)
	var stringValue = token_set[0].value
	stringValue.erase(0, 1)
	stringValue.erase(stringValue.length() - 1, 1)
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.STRING, stringValue)


func __handle_boolean(token_set):
	assert(token_set.size() == 1)
	var value = token_set[0].value == 'true'
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.BOOLEAN, value)

func __handle_function(token_set):
	assert(token_set[1].type == Consts.INSTRUCTION_TYPES.VARIABLE)
	assert(token_set[2].value == '(')
	assert(token_set[token_set.size() - 1].value == ')')

	var args = []

	var argument_index = 3
	if token_set[3].value != ')':
		while argument_index < token_set.size():
			if token_set[argument_index + 1].value == ',':
				var instruction = Instruction.new().set_value(Consts.INSTRUCTION_TYPES.VARIABLE, token_set[argument_index].value)
				args.push_back(instruction)
				argument_index = argument_index + 2
			elif token_set[argument_index + 1].value == ')':
				var instruction = Instruction.new().set_value(Consts.INSTRUCTION_TYPES.VARIABLE, token_set[argument_index].value)
				args.push_back(instruction)
				break
			else:
				argument_index += 1

	return Instruction.new().set_function(Consts.INSTRUCTION_TYPES.FUNCTION, token_set[1].value, args)

func __handle_return(token_set):
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.RETURN, run(token_set.slice(1, len(token_set) - 1)))

