signal call_print
signal call_highlight

func run(instructions):
	var scopes = []
	scopes.push_back({})
	
	for instruction in instructions:
		__interpret_instruction(instruction, scopes)
		
	return scopes
	
func print_scopes(scopes):	
	for scope in scopes:
		for key in scope.keys():
			print(key + ': ' + str(scope[key]))
		print()
		
func __interpret_instruction(instruction, scopes):
	match (instruction.type):
		Consts.INSTRUCTION_TYPES.ASSIGNMENT:
			var scope_info = __interpret_instruction(instruction.left, scopes)
			var value = __interpret_instruction(instruction.right, scopes)
			scopes[scope_info.index][scope_info.key] = value
		Consts.INSTRUCTION_TYPES.DECLARATION:
			scopes[scopes.size() - 1][instruction.value] = null
			return {'index': scopes.size() - 1, 'key': instruction.value}
		Consts.INSTRUCTION_TYPES.NUMBER:
			return int(float(instruction.value))
		Consts.INSTRUCTION_TYPES.VARIABLE:
			return __find_variable(instruction.value, scopes)
		Consts.INSTRUCTION_TYPES.STRING:
			return instruction.value
		Consts.INSTRUCTION_TYPES.BOOLEAN:
			return instruction.value
		Consts.INSTRUCTION_TYPES.OPERATION:
			var operand_1 = __interpret_instruction(instruction.left, scopes)
			var operand_2 = __interpret_instruction(instruction.right, scopes)
			if instruction.operator == '+':
				return operand_1 + operand_2
			elif instruction.operator == '*':
				return operand_1 * operand_2
			elif instruction.operator == '==':
				return operand_1 == operand_2
		Consts.INSTRUCTION_TYPES.BUILTIN:
			var args = []
			for arg in instruction.args:
				args.push_back(__interpret_instruction(arg, scopes))
			var function_name = instruction.function
			emit_signal("call_" + function_name, args)
		Consts.INSTRUCTION_TYPES.IF:
			var expression = __interpret_instruction(instruction.expression, scopes)
			if (expression):
				scopes.push_back({})
				for inst in instruction.instructions:
					__interpret_instruction(inst, scopes)
				scopes.pop_back()

func __find_variable(key, scopes):
	var i = scopes.size() - 1
	while i >= 0:
		if scopes[i].has(key):
			return scopes[i][key]
		i -= 1
