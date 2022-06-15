var Instruction = preload("res://interpreter/Instruction.gd")
var KeyValuePair = preload("res://interpreter/KeyValuePair.gd")
var TokenSetParser = preload("res://interpreter/TokenSetParser.gd")

var input
var input_index
var token_set
var scopes
var scope_index
var instructions
var token_set_parser

func run(__input):
	input = __input
	input_index = 0
	token_set = []
	instructions = []
	scopes = [instructions]
	scope_index = 0
	token_set_parser = TokenSetParser.new()

	while input_index < input.size():
		var token = input[input_index]
		__handle_token(token)
		input_index += 1

	return instructions

func __handle_token(token):
	if (token.type == Consts.TOKEN_TYPES.SEMICOLON):
		__read_token_set_into_scope()
	elif (token.value == '{' and __block_contains_semicolon()):
		__handle_block()
	elif (token.value == '}' and __block_contains_semicolon_reverse()):
		__handle_end_block()
	else:
		token_set.push_back(token)

func __read_token_set_into_scope():
	var parsed_instruction = token_set_parser.run(token_set)
	scopes[scope_index].push_back(parsed_instruction)
	token_set = []
	return parsed_instruction

func __handle_block():
	var instruction = __read_token_set_into_scope()
	if instruction.type == Consts.INSTRUCTION_TYPES.ASSIGNMENT:
		scopes.push_back(instruction.right.instructions)
	else:
		scopes.push_back(instruction.instructions)
	scope_index += 1

func __handle_end_block():
	token_set = []
	scopes.pop_back()
	scope_index -= 1

func __block_contains_semicolon():
	var index = input_index
	while index < input.size():
		if input[index].value == '}':
			return false
		elif input[index].value == ';':
			return true
		else:
			index += 1

func __block_contains_semicolon_reverse():
	var index = input_index
	while index >= 0:
		if input[index].value == '{':
			return false
		elif input[index].value == ';':
			return true
		else:
			index -= 1
