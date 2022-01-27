func run(instructions):
	var scopes = []
	scopes.push_back({})
	
	for instruction in instructions:
		__interpret_instruction(instruction, scopes)
		
	for scope in scopes:
		for key in scope.keys():
			print(key + ': ' + str(scope[key]))
		print()
		
func __interpret_instruction(instruction, scopes):
	match (instruction['type']):
		'assignment':
			var scope_info = __interpret_instruction(instruction['left'], scopes)
			var value = __interpret_instruction(instruction['right'], scopes)
			scopes[scope_info['index']][scope_info['key']] = value
		'declaration':
			scopes[scopes.size() - 1][instruction['value']] = null
			return {'index': scopes.size() - 1, 'key': instruction['value']}
		'number':
			return int(float(instruction['value']))
		'variable':
			return __find_variable(instruction['value'], scopes)
		'operation':
			var operand_1 = __interpret_instruction(instruction['left'], scopes)
			var operand_2 = __interpret_instruction(instruction['right'], scopes)
			if instruction['operator'] == '+':
				return operand_1 + operand_2
			elif instruction['operator'] == '*':
				return operand_1 * operand_2

func __find_variable(key, scopes):
	var i = scopes.size() - 1
	while i >= 0:
		if scopes[i].has(key):
			return scopes[i][key]
