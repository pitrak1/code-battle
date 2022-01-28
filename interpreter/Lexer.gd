const quotes = ['\'', '"']
const whitespace = ['\t', '\n', ' ']
const digits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
const letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
const keywords = ['var', 'print']

var tokens
var line_number
var 	line
var current_column
var current_character
var start_column

func run(path):
	var file = File.new()
	file.open(path, File.READ)
	
	tokens = []
	line_number = 0
	
	while file.get_position() < file.get_len():
		line = file.get_line()
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
			elif current_character == '(' or current_character == ')':
				current_column += 1
				tokens.push_back(__create_token('parenthesis', current_character, line_number, start_column))
			elif current_character == '{' or current_character == '}':
				current_column += 1
				tokens.push_back(__create_token('brace', current_character, line_number, start_column))
			elif current_character == ',':
				current_column += 1
				tokens.push_back(__create_token('comma', current_character, line_number, start_column))
			elif current_character == '+' or current_character == '*':
				current_column += 1
				tokens.push_back(__create_token('operation', current_character, line_number, start_column))
			elif current_character == '(' or current_character == ')':
				current_column += 1
				tokens.push_back(__create_token('parenthesis', current_character, line_number, start_column))
			elif current_character == '=':
				current_column += 1
				var next_character = line[current_column]
				if next_character == '=':
					current_column += 1
					tokens.push_back(__create_token('equality', '==', line_number, start_column))
				else:
					tokens.push_back(__create_token('assignment', current_character, line_number, start_column))
			elif current_character == ';':
				current_column += 1
				tokens.push_back(__create_token('semicolon', current_character, line_number, start_column))
			else:
				current_column += 1
	
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
	
func __create_token(type, value, line_number, start_column):
	return {
		'type': type, 
		'value': value, 
		'line_number': line_number, 
		'start_column': start_column
	}

func __handle_number():
	var number = ''
	while current_column < line.length() and __is_digit(current_character):
		number += current_character
		current_column += 1
		current_character = line[current_column]
	tokens.push_back(__create_token('number', number, line_number, start_column))

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
	tokens.push_back(__create_token('string', string, line_number, start_column))
	
func __handle_word():
	var identifier = ''
	while current_column < line.length() and __is_alphanumeric_or_underscore(current_character):
		identifier += current_character
		current_column += 1
		current_character = line[current_column]
	if identifier in keywords:
		tokens.push_back(__create_token('keyword', identifier, line_number, start_column))
	elif identifier == 'true' or identifier == 'false':
		tokens.push_back(__create_token('boolean', identifier, line_number, start_column))
	else:
		tokens.push_back(__create_token('identifier', identifier, line_number, start_column))
