var Instruction = preload("res://interpreter/Instruction.gd")
var KeyValuePair = preload("res://interpreter/KeyValuePair.gd")
var Utilities = preload("res://Utilities.gd")

func run(token_set):
	var assignment_index = Utilities.get_assignment_operator_index(token_set)
	var operation_index = Utilities.get_mathematical_operator_index(token_set)

	if assignment_index:
		return __handle_assignment(token_set, assignment_index)
	elif token_set.back().type == Consts.TOKEN_TYPES.SEPARATOR:
		return __handle_separator(token_set)
	elif token_set[0].type == Consts.TOKEN_TYPES.KEYWORD:
		return __handle_keyword(token_set)
	elif token_set[0].type == Consts.TOKEN_TYPES.BUILTIN:
		return __handle_builtin(token_set)
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
	elif token_set[0].value == 'if' or token_set[0].value == 'while':
		return __handle_if_while(token_set)
	elif token_set[0].value == 'function':
		return __handle_function(token_set)
	elif token_set[0].value == 'return':
		return __handle_return(token_set)
	elif token_set[0].value == 'import':
		return __handle_import(token_set)
	elif token_set[0].value == 'class':
		return __handle_class(token_set)

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

func __handle_builtin(token_set):
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.BUILTIN, token_set[0].value)

func __handle_if_while(token_set):
	assert(token_set[1].value == '(')
	assert(token_set[token_set.size() - 1].value == ')')

	var expression = Utilities.parse_end_until_matching_separator(token_set, [])

	var type
	if token_set[0].value == 'if':
		type = Consts.INSTRUCTION_TYPES.IF
	else:
		type = Consts.INSTRUCTION_TYPES.WHILE
	return Instruction.new().set_if(type, run(expression['entries'][0]))

func __handle_operation(token_set, operation_index):
	return Instruction.new().set_operation(
		Consts.INSTRUCTION_TYPES.OPERATION,
		token_set[operation_index].value,
		run(token_set.slice(0, operation_index - 1)),
		run(token_set.slice(operation_index + 1, token_set.size() - 1))
	)

func __handle_separator(token_set):
	if token_set.back().value == ']':
		var results = Utilities.parse_end_until_matching_separator(token_set, [','])
		var start_of_braces = token_set.size() - 1 - results['length']

		if start_of_braces == 0:
			return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.ARRAY, __run_array(results['entries']))
		else:
			var token_subset = token_set.slice(0, start_of_braces - 1)
			return Instruction.new().set_index(Consts.INSTRUCTION_TYPES.INDEX, run(token_subset), run(results['entries'][0]))
	elif token_set.back().value == ')':
		var results = Utilities.parse_end_until_matching_separator(token_set, [','])
		var start_of_parens = token_set.size() - 1 - results['length']

		if start_of_parens == 1 and token_set[0].value == 'function':
			return Instruction.new().set_function(Consts.INSTRUCTION_TYPES.FUNCTION, __run_array(results['entries']))
		else:
			var token_subset = token_set.slice(0, start_of_parens - 1)
			return Instruction.new().set_call(Consts.INSTRUCTION_TYPES.CALL, run(token_subset), __run_array(results['entries']))
	elif token_set.back().value == '}':
		var result_pairs = Utilities.parse_object_definition(token_set)
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.OBJECT, __run_pairs(result_pairs))

func __handle_identifier(token_set):
	assert(token_set.size() == 1)
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.VARIABLE, token_set[0].value)

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
	assert(token_set[1].value == '(')
	assert(token_set[token_set.size() - 1].value == ')')

	var args = Utilities.parse_end_until_matching_separator(token_set.slice(1, token_set.size() - 1), [','])
	return Instruction.new().set_function(Consts.INSTRUCTION_TYPES.FUNCTION, __run_array(args['entries']))

func __handle_return(token_set):
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.RETURN, run(token_set.slice(1, len(token_set) - 1)))

func __handle_import(token_set):
	var stringValue = token_set[1].value
	stringValue.erase(0, 1)
	stringValue.erase(stringValue.length() - 1, 1)
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.IMPORT, stringValue)

func __handle_class(token_set):
	return Instruction.new().set_class(Consts.INSTRUCTION_TYPES.CLASS)

func __run_array(array):
	var args = []
	for arg in array:
		args.push_back(run(arg))
	return args

func __run_pairs(pairs):
	var results = []
	for pair in pairs:
		results.push_back(KeyValuePair.new().set(run(pair[0]), run(pair[1])))
	return results
