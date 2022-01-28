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
			current_character = line[current_column]
			
			if __is_whitespace(current_character):
				current_column += 1
			elif __is_digit(current_character):
				__handle_number()
			elif __is_quote(current_character):
				__handle_string()
			elif __is_alpha_or_underscore(current_character):
				__handle_word()
			elif current_character in Consts.SEPARATORS:
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPES.SEPARATOR, current_character, line_number, start_column))
			elif current_character in Consts.MATHEMATICAL_OPERATORS or current_character in Consts.BOOLEAN_OPERATORS:
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPES.OPERATOR, current_character, line_number, start_column))
			elif current_character == '=':
				current_column += 1
				var next_character = line[current_column]
				if next_character == '=':
					current_column += 1
					tokens.push_back(Token.new(Consts.TOKEN_TYPES.OPERATOR, '==', line_number, start_column))
				else:
					tokens.push_back(Token.new(Consts.TOKEN_TYPES.ASSIGNMENT, current_character, line_number, start_column))
			elif current_character == ';':
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPES.SEMICOLON, current_character, line_number, start_column))
			elif current_character == '/':
				current_column += 1
				var next_character = line[current_column]
				if next_character == '/':
					break
			else:
				current_column += 1
	
	return tokens
	
	
func __is_whitespace(character):
	return character in Consts.WHITESPACE
	
func __is_digit(character):
	return character in Consts.DIGITS
	
func __is_alpha_or_underscore(character):
	return character in Consts.LETTERS or character == '_'
	
func __is_alphanumeric_or_underscore(character):
	return __is_alpha_or_underscore(character) or __is_digit(character)
	
func __is_quote(character):
	return character in Consts.QUOTES
	
func __handle_number():
	var number = ''
	while current_column < line.length() and __is_digit(current_character):
		number += current_character
		current_column += 1
		current_character = line[current_column]
	tokens.push_back(Token.new(Consts.TOKEN_TYPES.NUMBER, number, line_number, start_column))

func __handle_string():
	var starting_quote = current_character
	var string = current_character
	current_column += 1
	current_character = line[current_column]
	while current_column < line.length() and current_character != starting_quote:
		string += current_character
		current_column += 1
		current_character = line[current_column]
	string += current_character
	current_column += 1
	tokens.push_back(Token.new(Consts.TOKEN_TYPES.STRING, string, line_number, start_column))
	
func __handle_word():
	var identifier = ''
	while current_column < line.length() and __is_alphanumeric_or_underscore(current_character):
		identifier += current_character
		current_column += 1
		current_character = line[current_column]
	if identifier in Consts.KEYWORDS:
		tokens.push_back(Token.new(Consts.TOKEN_TYPES.KEYWORD, identifier, line_number, start_column))
	elif identifier == 'true' or identifier == 'false':
		tokens.push_back(Token.new(Consts.TOKEN_TYPES.BOOLEAN, identifier, line_number, start_column))
	else:
		tokens.push_back(Token.new(Consts.TOKEN_TYPES.IDENTIFIER, identifier, line_number, start_column))
