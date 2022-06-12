extends "res://addons/gut/test.gd"

func assert_scopes(scopes, expected_scopes, identifier):
	for i in range(scopes.size()):
		__assert_scopes_recursive(scopes.get_scope(i), expected_scopes[i], identifier)

func __assert_scopes_recursive(scope, expected_scope, identifier):
	if typeof(scope) == TYPE_OBJECT:
		for key in scope.get_variable_names():
			if typeof(scope.find_variable(key)) == TYPE_OBJECT or typeof(scope.find_variable(key)) == TYPE_DICTIONARY:
				__assert_scopes_recursive(scope.find_variable(key), expected_scope[key], identifier)
			else:
				assert_eq(scope.find_variable(key), expected_scope[key], identifier + ': key does not match, expected ' + str(key) + ': ' + str(expected_scope[key]) + ', got ' + str(key) + ': ' + str(scope.find_variable(key)))
	else:
		for key in scope.keys():
			if typeof(scope[key]) == TYPE_OBJECT or typeof(scope[key]) == TYPE_DICTIONARY:
				__assert_scopes_recursive(scope[key], expected_scope[key], identifier)
			else:
				assert_eq(scope[key], expected_scope[key], identifier + ': key does not match, expected ' + str(key) + ': ' + str(expected_scope[key]) + ', got ' + str(key) + ': ' + str(scope[key]))

const keys = ['operator', 'left', 'right', 'value', 'function', 'args']

func assert_instructions(instructions, expected_instructions, identifier):
	assert_eq(instructions.size(), expected_instructions.size(), identifier + ': Instructions is length ' + str(instructions.size()) + ', expected ' + str(expected_instructions.size()))
	for i in range(instructions.size()):
		assert_instruction(instructions[i], expected_instructions[i], identifier)


func assert_instruction(instruction, expected_instruction, identifier):
	assert_true('type' in expected_instruction.keys())
	assert_eq(instruction['type'], expected_instruction['type'], identifier + ': key type does not match, expected: ' + Consts.INSTRUCTION_TYPE_STRINGS[expected_instruction['type']] + ', actual: ' + Consts.INSTRUCTION_TYPE_STRINGS[instruction['type']])

	for key in keys:
		if instruction.get(key):
			assert_true(key in expected_instruction.keys(), identifier + ': unexpected key ' + key)
			if key == 'args':
				for i in range(instruction['args'].size()):
					assert_instruction(instruction['args'][i], expected_instruction['args'][i], identifier)
			elif key == 'left' or key == 'right':
				assert_instruction(instruction[key], expected_instruction[key], identifier)
			elif key == 'expression':
				assert_instruction(instruction['expression'], expected_instruction['expression'], identifier)
			elif key == 'instructions':
				for i in range(instruction['instructions'].size()):
					assert_instruction(instruction['instructions'][i], expected_instruction['instructions'][i], identifier)
			elif key == 'value':
				if typeof(instruction['value']) == TYPE_ARRAY:
					assert_eq(instruction['value'].size(), expected_instruction['value'].size(), identifier + ': array sizes do not match, expected: ' + str(expected_instruction['value'].size()) + ', actual: ' + str(instruction['value'].size()))
					if instruction['type'] == Consts.INSTRUCTION_TYPES.ARRAY:
						for i in range(instruction['value'].size()):
							assert_instruction(instruction['value'][i], expected_instruction['value'][i], identifier)
					elif instruction['type'] == Consts.INSTRUCTION_TYPES.OBJECT:
						for i in range(instruction['value'].size()):
							assert_instruction(instruction['value'][i]['key'], expected_instruction['value'][i]['key'], identifier)
							assert_instruction(instruction['value'][i]['value'], expected_instruction['value'][i]['value'], identifier)
				else:
					assert_eq(instruction[key], expected_instruction[key], identifier + ': values do not match, expected: ' + str(expected_instruction[key]) + ', actual: ' + str(instruction[key]))

func assert_tokens(tokens, expected_tokens, identifier):
	assert_eq(tokens.size(), expected_tokens.size(), identifier + ': Tokens is length ' + str(tokens.size()) + ', expected ' + str(expected_tokens.size()))
	for i in range(tokens.size()):
		assert_eq(tokens[i].type, expected_tokens[i]['type'], identifier + ': Token ' + str(i) + ' is of type ' + Consts.TOKEN_TYPE_STRINGS[tokens[i].type] + ', expected ' + Consts.TOKEN_TYPE_STRINGS[expected_tokens[i]['type']])
		assert_eq(tokens[i].value, expected_tokens[i]['value'], identifier + ': Token ' + str(i) + ' has value ' + tokens[i].value + ', expected ' + expected_tokens[i]['value'])

func shuffle_collection(collection):
	var result = collection.duplicate()
	result.shuffle()
	return result

func generate_collection_input(collection):
	var result = ''

	for i in range(collection.size()):
		result += collection[i] + ' '

	return result


func assert_collection(tokens, collection, type, identifier):
	assert_eq(tokens.size(), collection.size(), identifier + ': Tokens is length ' + str(tokens.size()) + ', expected ' + str(collection.size()))
	for i in range(tokens.size()):
		assert_eq(tokens[i].type, type, identifier + ': Token ' + str(i) + ' is of type ' + Consts.TOKEN_TYPE_STRINGS[tokens[i].type] + ', expected ' + Consts.TOKEN_TYPE_STRINGS[type])
		assert_eq(tokens[i].value, collection[i], identifier + ': Token ' + str(i) + ' has value ' + tokens[i].value + ', expected ' + collection[i])

