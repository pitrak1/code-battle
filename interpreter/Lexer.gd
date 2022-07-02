var Token = preload("res://interpreter/Token.gd")
var Utilities = preload("res://interpreter/Utilities.gd")

func run(contents):
	var tokens = []
	
	var lines = contents.split('\n')
	
	for line_number in range(lines.size()):
		var line = lines[line_number]
		var result = __handle_line(tokens, line, line_number)
		if result and result['type'] == 'error':
			return {'status': 'error', 'line_number': line_number, 'column': result['index']}
		
	return {'status': 'success', 'tokens': tokens}

func __handle_line(tokens, input_string, line_number):
	var index = 0
	while index < input_string.length():
		var result = __handle_next_token(input_string, index)

		if result['type'] == Consts.TOKEN_TYPES.ERROR:
			return {'type': 'error', 'index': index}
		elif result['type'] == Consts.TOKEN_TYPES.COMMENT:
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
	elif next_characters in Consts.OPERATORS:
		return {'type': Consts.TOKEN_TYPES.OPERATOR, 'value': next_characters}
	elif next_characters[0] in Consts.OPERATORS:
		return {'type': Consts.TOKEN_TYPES.OPERATOR, 'value': next_characters[0]}
	elif next_characters[0] == '=':
		return {'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': next_characters[0]}
	elif next_characters[0] == ';':
		return {'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': next_characters[0]}
	elif next_characters == '//':
		return {'type': Consts.TOKEN_TYPES.COMMENT}
	else:
		return {'type': Consts.TOKEN_TYPES.ERROR}


func __get_next_two_characters(input_string, index):
	var characters = input_string[index]
			
	if index < input_string.length() - 1:
		characters += input_string[index + 1]

	return characters

func __handle_number(input_string, index):
	var number = Utilities.get_characters_in_collection(input_string, index, [Consts.DIGITS, ['.']])
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
	elif identifier in Consts.BOOLEANS:
		return {'type': Consts.TOKEN_TYPES.BOOLEAN, 'value': identifier}
	elif identifier in Consts.BUILTINS:
		return {'type': Consts.TOKEN_TYPES.BUILTIN, 'value': identifier}
	else:
		return {'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': identifier}
		
