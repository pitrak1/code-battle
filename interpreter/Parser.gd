func run(tokens):
	var instructions = []
	var current_instruction = []
	
	for token in tokens:
		if (token['type'] == 'semicolon'):
			var parsed_instruction = __parse_instruction(current_instruction)
			instructions.push_back(parsed_instruction)
			current_instruction = []
		else:
			current_instruction.push_back(token)

	return instructions
	
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
		
	text += instruction['type']
	if (instruction.get('value')):
		text += ': ' + instruction['value']
		
	print(text)
	
	if instruction.get('left'):
		__print_ast_recursive(instruction['left'])
		depth -= 1
		
	if instruction.get('right'):
		__print_ast_recursive(instruction['right'])
		depth -= 1


func __parse_instruction(instruction):
	var assignment_index = __get_assignment_operator_index(instruction)
	var mathematical_index = __get_mathematical_operator_index(instruction)

	if assignment_index:
		return {
			'type': 'assignment',
			'operator': '=',
			'left': __parse_instruction(instruction.slice(0, assignment_index - 1)),
			'right': __parse_instruction(instruction.slice(assignment_index + 1, instruction.size() - 1))
		}
	elif mathematical_index:
		return {
			'type': 'operation',
			'operator': instruction[mathematical_index]['value'],
			'left': __parse_instruction(instruction.slice(0, mathematical_index - 1)),
			'right': __parse_instruction(instruction.slice(mathematical_index + 1, instruction.size() - 1))
		}
	elif instruction[0].type == 'keyword':
		assert(instruction[0]['value'] == 'var')
		assert(instruction.size() == 2)
		assert(instruction[1]['type'] == 'identifier')
		return {
			'type': 'declaration',
			'value': instruction[1]['value']
		}
	elif instruction[0]['type'] == 'identifier':
		assert(instruction.size() == 1)
		return {
			'type': 'variable',
			'value': instruction[0]['value']
		}
	elif instruction[0]['type'] == 'number':
		assert(instruction.size() == 1)
		return {
			'type': 'number',
			'value': instruction[0]['value']
		}
	elif instruction[0]['type'] == 'string':
		assert(instruction.size() == 1)
		return {
			'type': 'string',
			'value': instruction[0]['value']
		}
	else:
		print('ERROR')
		
func __get_assignment_operator_index(instruction):
	for i in range(instruction.size()):
		if instruction[i]['type'] == 'assignment':
			return i
			
func __get_mathematical_operator_index(instruction):
	var i = instruction.size() - 1
	while i >= 0:
		if instruction[i]['type'] == 'operation':
			return i
		i -= 1		
