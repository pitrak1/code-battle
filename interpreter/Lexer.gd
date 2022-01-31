class Token:
	var type
	var value
	var line_number
	var start_column
	
	func _init(__type, __value, __line_number, __start_column):
		type = __type
		value = __value
		line_number = __line_number
		start_column = __start_column

var tokens
var line_number
var 	line
var current_column
var current_character
var next_character
var start_column

func print_tokens():
	for token in tokens:
		print(token.value + ' ' + Consts.TOKEN_TYPE_STRINGS[token.type])

func run(contents):
	tokens = []
	line_number = 0
	
	var lines = contents.split('\n')
	
	for line_number in range(lines.size()):
		line = lines[line_number]
		line_number += 1
		
		current_column = 0
		while current_column < line.length():
			start_column = current_column
			__load_character(false)
			var token_type = __get_token_type(current_character, next_character)
			
			match token_type:
				Consts.TOKEN_TYPES.WHITESPACE:
					current_column += 1
				Consts.TOKEN_TYPES.NUMBER:
					__handle_number()
				Consts.TOKEN_TYPES.STRING:
					__handle_string()
				Consts.TOKEN_TYPES.IDENTIFIER:
					__handle_word()
				Consts.TOKEN_TYPES.SEPARATOR:
					current_column += 1
					tokens.push_back(Token.new(Consts.TOKEN_TYPES.SEPARATOR, current_character, line_number, start_column))
				Consts.TOKEN_TYPES.OPERATOR:
					__handle_operator()
				Consts.TOKEN_TYPES.ASSIGNMENT:
					current_column += 1
					tokens.push_back(Token.new(Consts.TOKEN_TYPES.ASSIGNMENT, current_character, line_number, start_column))
				Consts.TOKEN_TYPES.SEMICOLON:
					current_column += 1
					tokens.push_back(Token.new(Consts.TOKEN_TYPES.SEMICOLON, current_character, line_number, start_column))
				Consts.TOKEN_TYPES.COMMENT:
					current_column = line.length()
				_:
					return {'status': 'error', 'line_number': line_number, 'column': current_column}

	return {'status': 'success', 'tokens': tokens}
	
func __load_character(preincrement = true):
	if preincrement:
		current_column += 1
	
	current_character = line[current_column]
			
	if current_column < line.length() - 1:
		next_character = line[current_column + 1]
	else:
		next_character = ''
	
func __get_token_type(character, next_character):
	if character in Consts.WHITESPACE:
		return Consts.TOKEN_TYPES.WHITESPACE
	elif character in Consts.DIGITS:
		return Consts.TOKEN_TYPES.NUMBER
	elif character in Consts.QUOTES:
		return Consts.TOKEN_TYPES.STRING
	elif character in Consts.SEPARATORS:
		return Consts.TOKEN_TYPES.SEPARATOR
	elif character in Consts.LETTERS or character == '_':
		return Consts.TOKEN_TYPES.IDENTIFIER
	elif character + next_character in Consts.OPERATORS or character in Consts.OPERATORS:
		return Consts.TOKEN_TYPES.OPERATOR
	elif character == '=':
		return Consts.TOKEN_TYPES.ASSIGNMENT
	elif character == ';':
		return Consts.TOKEN_TYPES.SEMICOLON
	elif character + next_character == '//':
		return Consts.TOKEN_TYPES.COMMENT

func __handle_number():
	var number = __get_characters_in_collection(Consts.DIGITS)
	tokens.push_back(Token.new(Consts.TOKEN_TYPES.NUMBER, number, line_number, start_column))

func __handle_string():
	var starting_quote = current_character
	__load_character()
	var string = starting_quote + __get_characters_in_collection([starting_quote], true) + starting_quote
	current_column += 1
	tokens.push_back(Token.new(Consts.TOKEN_TYPES.STRING, string, line_number, start_column))
	
func __handle_word():
	var identifier = __get_characters_in_collection([Consts.DIGITS, Consts.LETTERS, '_'])

	if identifier in Consts.KEYWORDS:
		tokens.push_back(Token.new(Consts.TOKEN_TYPES.KEYWORD, identifier, line_number, start_column))
	elif identifier == 'true' or identifier == 'false':
		tokens.push_back(Token.new(Consts.TOKEN_TYPES.BOOLEAN, identifier, line_number, start_column))
	else:
		tokens.push_back(Token.new(Consts.TOKEN_TYPES.IDENTIFIER, identifier, line_number, start_column))
		
func __handle_operator():
	var result
	if current_character in Consts.OPERATORS:
		result = current_character
		current_column += 1
	else:
		result = current_character + line[current_column + 1]
		current_column += 2
	tokens.push_back(Token.new(Consts.TOKEN_TYPES.OPERATOR, result, line_number, start_column))
	
func __get_characters_in_collection(collection, invert = false):
	var result_collection = []
	for entry in collection:
		var type = typeof(entry)
		if type == TYPE_ARRAY:
			for character in entry:
				result_collection.push_back(character)
		elif type == TYPE_STRING:
			result_collection.push_back(entry)
	
	var string = ''
	if invert:
		while current_column < line.length() - 1 and not current_character in result_collection:
			string += current_character
			__load_character()
	else:
		while current_column < line.length() - 1 and current_character in result_collection:
			string += current_character
			__load_character()
	return string
		

