signal call_print
signal call_highlight

func run(instructions):
	var scopes = []
	scopes.push_back({})
	
	for instruction in instructions:
		__interpret_instruction(instruction, scopes)
		
	return scopes
	
func __interpret_instruction(instruction, scopes, left_side = false):
	match (instruction.type):
		Consts.INSTRUCTION_TYPES.ASSIGNMENT:
			return __handle_assignment(instruction, scopes)
		Consts.INSTRUCTION_TYPES.DECLARATION:
			return __handle_declaration(instruction, scopes)
		Consts.INSTRUCTION_TYPES.NUMBER:
			return __handle_number(instruction, scopes)
		Consts.INSTRUCTION_TYPES.VARIABLE:
			return __handle_variable(instruction, scopes, left_side)
		Consts.INSTRUCTION_TYPES.STRING:
			return instruction.value
		Consts.INSTRUCTION_TYPES.BOOLEAN:
			return instruction.value
		Consts.INSTRUCTION_TYPES.OPERATION:
			return __handle_operation(instruction, scopes)
		Consts.INSTRUCTION_TYPES.BUILTIN:
			return __handle_builtin(instruction, scopes)
		Consts.INSTRUCTION_TYPES.IF:
			return __handle_if(instruction, scopes)
		Consts.INSTRUCTION_TYPES.WHILE:
			return __handle_while(instruction, scopes)
		Consts.INSTRUCTION_TYPES.ARRAY:
			return __handle_array(instruction, scopes)
		Consts.INSTRUCTION_TYPES.INDEX:
			return __handle_index(instruction, scopes)
		Consts.INSTRUCTION_TYPES.OBJECT:
			return __handle_object(instruction, scopes)

func __find_variable(key, scopes):
	var i = scopes.size() - 1
	while i >= 0:
		if scopes[i].has(key):
			return scopes[i][key]
		i -= 1

func __handle_assignment(instruction, scopes):
	var value = __interpret_instruction(instruction.right, scopes)
	var scope_info = __interpret_instruction(instruction.left, scopes, true)
	scopes[scope_info.index][scope_info.key] = value

func __handle_declaration(instruction, scopes):
	scopes[scopes.size() - 1][instruction.value] = null
	return {'index': scopes.size() - 1, 'key': instruction.value}

func __handle_number(instruction, scopes):
	return int(float(instruction.value))

func __handle_variable(instruction, scopes, left_side):
	if left_side:
		return {'index': scopes.size() - 1, 'key': instruction.value}
	else:
		return __find_variable(instruction.value, scopes)

func __handle_operation(instruction, scopes):
	var operand_2 = __interpret_instruction(instruction.right, scopes)
	var operand_1 = __interpret_instruction(instruction.left, scopes)
	if instruction.operator == '+':
		return operand_1 + operand_2
	elif instruction.operator == '*':
		return operand_1 * operand_2
	elif instruction.operator == '==':
		return operand_1 == operand_2
	elif instruction.operator == '<':
		return operand_1 < operand_2
	elif instruction.operator == '>':
		return operand_1 > operand_2

func __handle_builtin(instruction, scopes):
	var args = []
	for arg in instruction.args:
		args.push_back(__interpret_instruction(arg, scopes))
	var function_name = instruction.function
	emit_signal("call_" + function_name, args)

func __handle_if(instruction, scopes):
	var expression = __interpret_instruction(instruction.expression, scopes)
	if (expression):
		scopes.push_back({})
		for inst in instruction.instructions:
			__interpret_instruction(inst, scopes)
		scopes.pop_back()

func __handle_while(instruction, scopes):
	var expression = __interpret_instruction(instruction.expression, scopes)
	scopes.push_back({})
	while (expression):
		for inst in instruction.instructions:
			__interpret_instruction(inst, scopes)
		expression = __interpret_instruction(instruction.expression, scopes)
	scopes.pop_back()

func __handle_array(instruction, scopes):
	var results = []
	for inst in instruction.value:
		results.push_back(__interpret_instruction(inst, scopes))
	return results

func __handle_index(instruction, scopes):
	var variable = __find_variable(instruction.value, scopes)
	var index = __interpret_instruction(instruction.index, scopes)
	return variable[index]

func __handle_object(instruction, scopes):
	var result = {}
	for pair in instruction.value:
		var key = __interpret_instruction(pair.key, scopes)
		var value = __interpret_instruction(pair.value, scopes)
		result[key] = value
	return result
