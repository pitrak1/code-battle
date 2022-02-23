var Instruction = preload("res://interpreter/Instruction.gd")
var KeyValuePair = preload("res://interpreter/KeyValuePair.gd")

var token_index

func run(__tokens):
	
	token_index = 0
	var instructions = []
	var scopes = [instructions]
	
	__read_instructions_into_scope(__tokens, scopes, 0)

	return instructions
	
func __read_instructions_into_scope(tokens, scopes, scope_index):
	var current_token_set = []
	
	while token_index < tokens.size():
		var token = tokens[token_index]
		if (token.type == Consts.TOKEN_TYPES.SEMICOLON):
			var parsed_instruction = __parse_token_set(current_token_set)
			scopes[scope_index].push_back(parsed_instruction)
			current_token_set = []
			token_index += 1
		elif (token.type == Consts.TOKEN_TYPES.SEPARATOR and token.value == '{'):
			if __block_contains_semicolon(tokens, token_index):	
				var parsed_instruction = __parse_token_set(current_token_set)
				scopes[scope_index].push_back(parsed_instruction)
				current_token_set = []
				scopes.push_back(parsed_instruction.instructions)
				token_index += 1
				__read_instructions_into_scope(tokens, scopes, scope_index + 1)
			else:
				current_token_set.push_back(token)
				token_index += 1
		elif (token.type == Consts.TOKEN_TYPES.SEPARATOR and token.value == '}'):
			if __set_contains_semicolon(current_token_set):
				current_token_set = []
				scopes.pop_back()
				token_index += 1
				__read_instructions_into_scope(tokens, scopes, scope_index - 1)
			else:
				current_token_set.push_back(token)
				token_index += 1
		else:
			current_token_set.push_back(token)
			token_index += 1

func __block_contains_semicolon(tokens, token_index):
	while token_index < tokens.size():
		if tokens[token_index].value == '}':
			return false
		elif tokens[token_index].value == ';':
			return true
		else:
			token_index += 1

func __set_contains_semicolon(set):
	for i in range(set.size()):
		if set[i].type == Consts.TOKEN_TYPES.SEMICOLON:
			return true
	return false
	
func __parse_token_set(token_set):
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

	for i in range(token_set.size() - 1, 0, -1):
		if token_set[i].type == Consts.TOKEN_TYPES.OPERATOR:
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
		__parse_token_set(token_set.slice(0, assignment_index - 1)),
		__parse_token_set(token_set.slice(assignment_index + 1, token_set.size() - 1))
	)

func __handle_keyword(token_set):
	if token_set[0].value == 'var':
		return __handle_var(token_set)
	elif token_set[0].value == 'print':		
		return __handle_print(token_set)
	elif token_set[0].value == 'highlight':		
		return __handle_highlight(token_set)
	elif token_set[0].value == 'if' or token_set[0].value == 'while':
		return __handle_if_while(token_set)

func __handle_var(token_set):
	assert(token_set.size() == 2)
	assert(token_set[1].type == Consts.TOKEN_TYPES.IDENTIFIER)
	return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.DECLARATION, token_set[1].value)	

func __handle_print(token_set):
	assert(token_set[1].value == '(')
	assert(token_set[token_set.size() - 1].value == ')')
	
	var instruction_range
	if token_set.size() <= 3:
		instruction_range = __parse_token_set(token_set.slice(2, 2))
	else:
		instruction_range = __parse_token_set(token_set.slice(2, token_set.size() - 2))
		
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
				args.push_back(__parse_token_set(token_set.slice(instruction_start, instruction_end)))
				instruction_start = instruction_end + 2
				instruction_end = instruction_start
			elif token_set[instruction_end + 1].value == ')':
				args.push_back(__parse_token_set(token_set.slice(instruction_start, instruction_end)))
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
			expression = __parse_token_set(token_set.slice(instruction_start, instruction_end))
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
		__parse_token_set(token_set.slice(0, operation_index - 1)),
		__parse_token_set(token_set.slice(operation_index + 1, token_set.size() - 1))
	)

func __handle_separator(token_set):
	if token_set[0].value == '[':
		var index = 1
		var results = []
		var current_set_start = 1
		while token_set[index].value != ']':
			if token_set[index].value == ',':
				results.push_back(__parse_token_set(token_set.slice(current_set_start, index - 1)))
				current_set_start = index + 1
			index += 1
		results.push_back(__parse_token_set(token_set.slice(current_set_start, index - 1)))
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.ARRAY, results)
	elif token_set[0].value == '{':
		var index = 1
		var results = []
		var current_set_start = index
		var key
		while token_set[index].value != '}':
			if token_set[index].value == ':':
				key = __parse_token_set(token_set.slice(current_set_start, index - 1))
				current_set_start = index + 1
			elif token_set[index].value == ',':
				results.push_back(KeyValuePair.new().set(key, __parse_token_set(token_set.slice(current_set_start, index - 1))))
				current_set_start = index + 1
			index += 1
		results.push_back(KeyValuePair.new().set(key, __parse_token_set(token_set.slice(current_set_start, index - 1))))
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.OBJECT, results)

func __handle_identifier(token_set):
	if (token_set.size() == 1):
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.VARIABLE, token_set[0].value)
	else:
		assert(token_set[1].value == '[')
		assert(token_set[token_set.size() - 1].value == ']')
		return Instruction.new().set_index(Consts.INSTRUCTION_TYPES.INDEX, token_set[0].value, __parse_token_set(token_set.slice(2, token_set.size() - 2)))
	
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
		


