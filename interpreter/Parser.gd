class Instruction:
	var type
	var operator
	var left
	var right
	var value
	var expression
	var instructions
	var function
	var args
	
	func set_operation(__type, __operator, __left, __right):
		type = __type
		operator = __operator
		left = __left
		right = __right
		return self
		
	func set_value(__type, __value):
		type = __type
		value = __value
		return self
		
	func set_call(__type, __function, __args):
		type = __type
		function = __function
		args = __args
		return self
		
	func set_if(__type, __expression):
		type = __type
		expression = __expression
		instructions = []
		return self

var instructions
var tokens
var token_index
var scopes

func run(__tokens):
	instructions = []
	
	tokens = __tokens
	token_index = 0
	
	scopes = [instructions]
	
	__read_instructions_into_scope(0)

	return instructions
	
func __read_instructions_into_scope(scope_index):
	var current_token_set = []
	
	while token_index < tokens.size():
		var token = tokens[token_index]
		if (token.type == Consts.TOKEN_TYPES.SEMICOLON):
			var parsed_instruction = __parse_token_set(current_token_set)
			scopes[scope_index].push_back(parsed_instruction)
			current_token_set = []
			token_index += 1
		elif (token.type == Consts.TOKEN_TYPES.SEPARATOR and token.value == '{'):
			var parsed_instruction = __parse_token_set(current_token_set)
			scopes[scope_index].push_back(parsed_instruction)
			current_token_set = []
			scopes.push_back(parsed_instruction.instructions)
			token_index += 1
			__read_instructions_into_scope(scope_index + 1)
		elif (token.type == Consts.TOKEN_TYPES.SEPARATOR and token.value == '}'):
			current_token_set = []
			scopes.pop_back()
			token_index += 1
			__read_instructions_into_scope(scope_index - 1)
		else:
			current_token_set.push_back(token)
			token_index += 1
	
func __parse_token_set(token_set):
	var assignment_index = __get_assignment_operator_index(token_set)
	var operation_index = __get_mathematical_operator_index(token_set)
	
	if assignment_index:
		return Instruction.new().set_operation(
			Consts.INSTRUCTION_TYPES.ASSIGNMENT, 
			'=',
			__parse_token_set(token_set.slice(0, assignment_index - 1)),
			__parse_token_set(token_set.slice(assignment_index + 1, token_set.size() - 1))
		)
	elif token_set[0].type == Consts.TOKEN_TYPES.KEYWORD:
		if token_set[0].value == 'var':
			assert(token_set.size() == 2)
			assert(token_set[1].type == Consts.TOKEN_TYPES.IDENTIFIER)
			return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.DECLARATION, token_set[1].value)
		elif token_set[0].value == 'print':		
			assert(token_set[1].value == '(')
			assert(token_set[token_set.size() - 1].value == ')')
			
			var instruction_range
			if token_set.size() <= 3:
				instruction_range = __parse_token_set(token_set.slice(2, 2))
			else:
				instruction_range = __parse_token_set(token_set.slice(2, token_set.size() - 2))
				
			return Instruction.new().set_call(Consts.INSTRUCTION_TYPES.BUILTIN, 'print', [instruction_range])
		elif token_set[0].value == 'highlight':		
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
		elif token_set[0].value == 'if' or token_set[0].value == 'while':
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
			
	elif operation_index:
		return Instruction.new().set_operation(
			Consts.INSTRUCTION_TYPES.OPERATION,
			token_set[operation_index].value,
			__parse_token_set(token_set.slice(0, operation_index - 1)),
			__parse_token_set(token_set.slice(operation_index + 1, token_set.size() - 1))
		)
	elif token_set[0].type == Consts.TOKEN_TYPES.IDENTIFIER:
		assert(token_set.size() == 1)
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.VARIABLE, token_set[0].value)
	elif token_set[0].type == Consts.TOKEN_TYPES.NUMBER:
		assert(token_set.size() == 1)
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.NUMBER, int(float(token_set[0].value)))
	elif token_set[0].type == Consts.TOKEN_TYPES.STRING:
		assert(token_set.size() == 1)
		var stringValue = token_set[0].value
		stringValue.erase(0, 1)
		stringValue.erase(stringValue.length() - 1, 1)
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.STRING, stringValue)
	elif token_set[0].type == Consts.TOKEN_TYPES.BOOLEAN:
		assert(token_set.size() == 1)
		var value = token_set[0].value == 'true'
		return Instruction.new().set_value(Consts.INSTRUCTION_TYPES.BOOLEAN, value)

		
func __get_assignment_operator_index(token_set):
	for i in range(token_set.size()):
		if token_set[i].type == Consts.TOKEN_TYPES.ASSIGNMENT:
			return i
			
func __get_mathematical_operator_index(token_set):
	var i = token_set.size() - 1
	
	var operators = Consts.OPERATORS
	
	var operator_priority = operators.size()
	var operator_location = operators.size()
	
	while i >= 0:
		if token_set[i].type == Consts.TOKEN_TYPES.OPERATOR:
			var current_operator_priority = operators.find(token_set[i].value)
			if current_operator_priority < operator_priority:
				operator_priority = current_operator_priority
				operator_location = i
		i -= 1		
		
	if operator_priority != operators.size():
		return operator_location
		

var depth

func print_ast(instructions):
	for inst in instructions:
		depth = -1
		__print_ast_recursive(inst)

func __print_ast_recursive(instruction):
	depth += 1
	
	var text = ''
	for _i in range(0, depth):
		text += '\t'
		
	text += Consts.INSTRUCTION_TYPE_STRINGS[instruction.type]
	if instruction.value:
		text += ': ' + str(instruction.value)
		
	print(text)
	
	if instruction.expression:
		__print_ast_recursive(instruction.expression)
		depth -= 1
	
	if instruction.left:
		__print_ast_recursive(instruction.left)
		depth -= 1
		
	if instruction.right:
		__print_ast_recursive(instruction.right)
		depth -= 1
		
	if instruction.instructions:
		for inst in instruction.instructions:
			__print_ast_recursive(inst)
			depth -= 1


