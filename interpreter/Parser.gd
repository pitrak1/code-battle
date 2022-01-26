class ParseNode:
	var type
	var operator
	var value
	var left
	var right
	var function
	var args = []
	
	func _init(__type):
		self.type = __type
		

func run(tokens):
	var instructions = []
	var current_instruction = []
	var current_token_index = 0
	var current_token = tokens[current_token_index]
	
	while (current_token.type != Consts.TOKEN_TYPE.EOF):
		if (current_token.type == Consts.TOKEN_TYPE.SEMICOLON):
			var parsed_instruction = __parse_instruction(current_instruction)
			instructions.push_back(parsed_instruction)
			current_instruction = []
		else:
			current_instruction.push_back(current_token)
		current_token_index += 1
		current_token = tokens[current_token_index]
	
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
		
	text += Consts.ASL_NODE_TYPE_TO_STRING[instruction.type]
	if (instruction.value):
		text += ': ' + instruction.value
		
	print(text)
	
	if instruction.left:
		__print_ast_recursive(instruction.left)
		depth -= 1
		
	if instruction.right:
		__print_ast_recursive(instruction.right)
		depth -= 1


#func __print_instruction(instruction):
#	print('INSTRUCTION:')
#	for i in instruction:
#		print(i.text)


func __parse_instruction(instruction):
	var assignment_index = __get_assignment_operator_index(instruction)
	var mathematical_index = __get_mathematical_operator_index(instruction)
#	__print_instruction(instruction)
	if assignment_index:
		var node = ParseNode.new(Consts.ASL_NODE_TYPE.ASSIGNMENT)
		node.operator = Consts.TOKEN_TYPE.EQUALS
		node.left = __parse_instruction(instruction.slice(0, assignment_index - 1))
		node.right = __parse_instruction(instruction.slice(assignment_index + 1, instruction.size() - 1))
		return node
	elif mathematical_index:
		var node = ParseNode.new(Consts.ASL_NODE_TYPE.OPERATION)
		node.operator = instruction[mathematical_index].type
		node.left = __parse_instruction(instruction.slice(0, mathematical_index - 1))
		node.right = __parse_instruction(instruction.slice(mathematical_index + 1, instruction.size() - 1))
		return node
	elif instruction[0].type == Consts.TOKEN_TYPE.KEYWORD:
		assert(instruction[0].text == 'var')
		assert(instruction.size() == 2)
		assert(instruction[1].type == Consts.TOKEN_TYPE.IDENTIFIER)
		var node = ParseNode.new(Consts.ASL_NODE_TYPE.DECLARATION)
		node.value = instruction[1].text
		return node
	elif instruction[0].type == Consts.TOKEN_TYPE.IDENTIFIER:
		assert(instruction.size() == 1)
		var node = ParseNode.new(Consts.ASL_NODE_TYPE.VARIABLE)
		node.value = instruction[0].text
		return node
	elif instruction[0].type == Consts.TOKEN_TYPE.NUMBER:
		assert(instruction.size() == 1)
		var node = ParseNode.new(Consts.ASL_NODE_TYPE.NUMBER)
		node.value = instruction[0].text
		return node
	elif instruction[0].type == Consts.TOKEN_TYPE.STRING:
		assert(instruction.size() == 1)
		var node = ParseNode.new(Consts.ASL_NODE_TYPE.STRING)
		node.value = instruction[0].text
		return node
	else:
		print('ERROR')
		
func __get_assignment_operator_index(instruction):
	for i in range(instruction.size()):
		if instruction[i].type == Consts.TOKEN_TYPE.EQUALS:
			return i
			
func __get_mathematical_operator_index(instruction):
	var i = instruction.size() - 1
	while i >= 0:
		if instruction[i].type == Consts.TOKEN_TYPE.ADD or instruction[i].type == Consts.TOKEN_TYPE.MULTIPLY:
			return i
		i -= 1
		
		
