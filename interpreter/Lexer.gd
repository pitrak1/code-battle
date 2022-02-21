var Token = preload("res://interpreter/Token.gd")
var Utilities = preload("res://interpreter/Utilities.gd")

func print_tokens(tokens):
	for token in tokens:
		print(token.value + ' ' + Consts.TOKEN_TYPE_STRINGS[token.type])

func run(contents):
	var tokens = []
	
	var lines = contents.split('\n')
	
	for line_number in range(lines.size()):
		var line = lines[line_number]
		__handle_line(tokens, line, line_number)
		
	return {'status': 'success', 'tokens': tokens}

func __handle_line(tokens, input_string, line_number):
	var index = 0
	while index < input_string.length():
		var result = __handle_next_token(input_string, index)

		if not result:
			return
		elif result['type'] == Consts.TOKEN_TYPES.WHITESPACE:
			index += 1
		else:
			tokens.push_back(Token.new(result['type'], result['value'], line_number, index))
			index += result['value'].length()


func __handle_next_token(input_string, index):
	var next_characters = __get_next_two_characters(input_string, index)

	if next_characters[0] in Consts.WHITESPACE:
		return {'type': Consts.TOKEN_TYPES.WHITESPACE, 'value': null}
	elif next_characters[0] in Consts.DIGITS:
		return __handle_number(input_string, index)
	elif next_characters[0] in Consts.QUOTES:
		return __handle_string(input_string, index)
	elif next_characters[0] in Consts.SEPARATORS:
		return {'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': next_characters[0]}
	elif next_characters[0] in Consts.LETTERS or next_characters[0] == '_':
		return __handle_word(input_string, index)
	elif next_characters[0] in Consts.OPERATORS or next_characters in Consts.OPERATORS:
		return __handle_operator(input_string, index)
	elif next_characters[0] == '=':
		return {'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': next_characters[0]}
	elif next_characters[0] == ';':
		return {'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': next_characters[0]}
	elif next_characters == '//':
		return null


func __get_next_two_characters(input_string, index):
	var characters = input_string[index]
			
	if index < input_string.length() - 1:
		characters += input_string[index + 1]

	return characters

func __handle_number(input_string, index):
	var number = Utilities.get_characters_in_collection(input_string, index, Consts.DIGITS)
	return {'type': Consts.TOKEN_TYPES.NUMBER, 'value': number}

func __handle_string(input_string, index):
	var starting_quote = input_string[index]
	index += 1
	var string_body = Utilities.get_characters_not_in_collection(input_string, index, [starting_quote])
	var string = starting_quote + string_body + starting_quote
	return {'type': Consts.TOKEN_TYPES.STRING, 'value': string}
	
func __handle_word(input_string, index):
	var identifier = Utilities.get_characters_in_collection(input_string, index, [Consts.DIGITS, Consts.LETTERS, '_'])
	index += identifier.length()

	if identifier in Consts.KEYWORDS:
		return {'type': Consts.TOKEN_TYPES.KEYWORD, 'value': identifier}
	elif identifier == 'true' or identifier == 'false':
		return {'type': Consts.TOKEN_TYPES.BOOLEAN, 'value': identifier}
	else:
		return {'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': identifier}
		
func __handle_operator(input_string, index):
	var result
	var current_character = input_string[index]
	if current_character in Consts.OPERATORS:
		result = current_character
		index += 1
	else:
		result = current_character + input_string[index + 1]
		index += 2
	return {'type': Consts.TOKEN_TYPES.OPERATOR, 'value': result}
