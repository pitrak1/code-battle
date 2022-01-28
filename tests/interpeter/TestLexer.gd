extends "res://addons/gut/test.gd"

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

func before_each():
	lexer = lexerScript.new()
	
func assert_tokens(tokens, expected_tokens):
	assert_eq(tokens.size(), expected_tokens.size(), 'Tokens is length ' + str(tokens.size()) + ', expected ' + str(expected_tokens.size()))
	for i in range(tokens.size()):
		assert_eq(tokens[i].type, expected_tokens[i]['type'], 'Token ' + str(i) + ' is of type ' + Consts.TOKEN_TYPE_STRINGS[tokens[i].type] + ', expected ' + Consts.TOKEN_TYPE_STRINGS[expected_tokens[i]['type']])
		assert_eq(tokens[i].value, expected_tokens[i]['value'], 'Token ' + str(i) + ' has value ' + tokens[i].value + ', expected ' + expected_tokens[i]['value'])
		
# DECLARATION AND ASSIGNMENT

func test_supports_declaration():
	var tokens = lexer.run("var x;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.KEYWORD, 'value': 'var'},
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_number_assignment():
	var tokens = lexer.run("x = 5;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
		{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_single_quote_string_assignment():
	var tokens = lexer.run("x = 'test1';")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
		{'type': Consts.TOKEN_TYPES.STRING, 'value': '\'test1\''},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_double_quote_string_assignment():
	var tokens = lexer.run("x = \"test1\";")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
		{'type': Consts.TOKEN_TYPES.STRING, 'value': '"test1"'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_boolean_assignment():
	var tokens = lexer.run("x = true;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
		{'type': Consts.TOKEN_TYPES.BOOLEAN, 'value': 'true'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_identifier_assignment():
	var tokens = lexer.run("x = y;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'y'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_expression_assignment():
	var tokens = lexer.run("x = y + 5;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'y'},
		{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '+'},
		{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_declaration_assignment():
	var tokens = lexer.run("var x = 5;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.KEYWORD, 'value': 'var'},
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
		{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
# OPERATORS

func test_supports_addition_operator():
	var tokens = lexer.run("x + 6;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '+'},
		{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_multiplication_operator():
	var tokens = lexer.run("x * 6;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '*'},
		{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_equality_operator():
	var tokens = lexer.run("x == 6;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '=='},
		{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_mixed_operators():
	var tokens = lexer.run("x + 5 == 6 * 3;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '+'},
		{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
		{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '=='},
		{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
		{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '*'},
		{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '3'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
# FUNCTIONS AND SEPARATORS

func test_supports_functions_and_parenthesis():
	var tokens = lexer.run("print('12345');")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.KEYWORD, 'value': 'print'},
		{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '('},
		{'type': Consts.TOKEN_TYPES.STRING, 'value': '\'12345\''},
		{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ')'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_multiple_arguments():
	var tokens = lexer.run("func('12345', 3);")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'func'},
		{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '('},
		{'type': Consts.TOKEN_TYPES.STRING, 'value': '\'12345\''},
		{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ','},
		{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '3'},
		{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ')'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
func test_supports_braces():
	var tokens = lexer.run("func({});")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'func'},
		{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '('},
		{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '{'},
		{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '}'},
		{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ')'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
