signal call_print
signal call_highlight

var lexer = preload("res://interpreter/Lexer.gd")
var parser = preload("res://interpreter/Parser.gd")

func run(__instructions):
	var scopes = []
	scopes.push_back({'local': {}, 'export': {}})


	while len(__instructions):
		var instruction = __instructions.pop_front()
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
		Consts.INSTRUCTION_TYPES.IMPORT:
			return __handle_import(instruction, scopes)
		Consts.INSTRUCTION_TYPES.FUNCTION:
			return __handle_function_definition(instruction, scopes)
		Consts.INSTRUCTION_TYPES.CALL:
			return __handle_function_call(instruction, scopes)
		Consts.INSTRUCTION_TYPES.RETURN:
			return __handle_return(instruction, scopes)

func __find_variable(key, scopes):
	var i = scopes.size() - 1
	while i >= 0:
		if scopes[i]['local'].has(key):
			return scopes[i]['local'][key]
		elif scopes[i]['export'].has(key):
			return scopes[i]['export'][key]
		else:
			i -= 1

func __handle_function_call(instruction, scopes):
	var function_def = __find_variable(instruction.function, scopes)
	assert(function_def)

	scopes.push_back({'local': {}, 'export': {}})
	assert(len(function_def.args) == len(instruction.args))
	var arg_index = 0
	while arg_index < len(function_def.args):
		scopes[scopes.size() - 1]['local'][function_def.args[arg_index].value] = __interpret_instruction(instruction.args[arg_index], scopes)
		arg_index += 1

	for inst in function_def.instructions:
		__interpret_instruction(inst, scopes)

	var return_value = scopes[scopes.size() - 1]['local']['return']
	scopes.pop_back()
	return return_value

func __handle_assignment(instruction, scopes):
	var value = __interpret_instruction(instruction.right, scopes)
	var scope_info = __interpret_instruction(instruction.left, scopes, true)
	scopes[scope_info.index][scope_info['export']][scope_info.key] = value

func __handle_declaration(instruction, scopes):
	var exported_value = 'local'
	if instruction.exported:
		exported_value = 'export'

	scopes[scopes.size() - 1][exported_value][instruction.value] = null
	return {'index': scopes.size() - 1, 'key': instruction.value, 'export': exported_value}

func __handle_function_definition(instruction, scopes):
	scopes[scopes.size() - 1][instruction.value] = instruction
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
	scopes.push_back({'local': {}, 'export': {}})
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

func __handle_import(instruction, scopes):
	var file = File.new()
	file.open(instruction.value, File.READ)
	var contents = file.get_as_text()
	file.close()

	var __lexer = lexer.new()
	var results = __lexer.run(contents)
	if results['status'] != 'success':
		print("ERROR")

	var __parser = parser.new()
	var __instructions = __parser.run(results['tokens'])

	var __scopes = self.run(__instructions)

	for key in __scopes[0]['export'].keys():
		scopes[scopes.size() - 1]['local'][key] = __scopes[0]['export'][key]

func __handle_return(instruction, scopes):
	scopes[scopes.size() - 1]['local']['return'] = __interpret_instruction(instruction.value, scopes)
