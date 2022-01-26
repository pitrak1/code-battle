const quotes = ['\'', '"']
const whitespace = ['\t', '\n', ' ']
const digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
const letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
const keywords = ['var']

class Token:
	var type
	var text
	var line
	var column
	
	func _init(__type, __text, __line, __column):
		self.type = __type
		self.text = __text
		self.line = __line
		self.column = __column
		

func run(path):
	var file = File.new()
	file.open(path, File.READ)
	
	var tokens = []
	var line_number = 0
	
	while file.get_position() < file.get_len():
		var line = file.get_line()
		line_number += 1
		
		var current_column = 0
		while current_column < line.length():
			var start_column = current_column
			var current_character = line[current_column]
			
			if __is_whitespace(current_character):
				current_column += 1
			elif __is_digit(current_character):
				var number = ''
				while current_column < line.length() and __is_digit(current_character):
					number += current_character
					current_column += 1
					current_character = line[current_column]
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.NUMBER, number, line_number, start_column))
			elif __is_quote(current_character):
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
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.STRING, string, line_number, start_column))
			elif __is_alpha_or_underscore(current_character):
				var identifier = ''
				while current_column < line.length() and __is_alphanumeric_or_underscore(current_character):
					identifier += current_character
					current_column += 1
					current_character = line[current_column]
				if identifier in keywords:
					tokens.push_back(Token.new(Consts.TOKEN_TYPE.KEYWORD, identifier, line_number, start_column))
				elif identifier == 'true' or identifier == 'false':
					tokens.push_back(Token.new(Consts.TOKEN_TYPE.BOOLEAN, identifier, line_number, start_column))
				else:
					tokens.push_back(Token.new(Consts.TOKEN_TYPE.IDENTIFIER, identifier, line_number, start_column))
			elif current_character == '(':
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.OPEN_PARENTHESIS, current_character, line_number, start_column))
			elif current_character == ')':
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.CLOSE_PARENTHESIS, current_character, line_number, start_column))
			elif current_character == '{':
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.OPEN_BRACE, current_character, line_number, start_column))
			elif current_character == '}':
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.CLOSE_BRACE, current_character, line_number, start_column))
			elif current_character == ',':
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.COMMA, current_character, line_number, start_column))
			elif current_character == '+':
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.ADD, current_character, line_number, start_column))
			elif current_character == '*':
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.MULTIPLY, current_character, line_number, start_column))
			elif current_character == '=':
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.EQUALS, current_character, line_number, start_column))
			elif current_character == ';':
				current_column += 1
				tokens.push_back(Token.new(Consts.TOKEN_TYPE.SEMICOLON, current_character, line_number, start_column))
			else:
				current_column += 1
	
	tokens.push_back(Token.new(Consts.TOKEN_TYPE.EOF, '<EOF>', line_number, 0))				
	file.close()
	
	return tokens
	
	
func __is_whitespace(character):
	return character in whitespace
	
func __is_digit(character):
	return character in digits
	
func __is_alpha_or_underscore(character):
	return character in letters or character == '_'
	
func __is_alphanumeric_or_underscore(character):
	return __is_alpha_or_underscore(character) or __is_digit(character)
	
func __is_quote(character):
	return character in quotes
	
