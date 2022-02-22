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

var test_params = [
	
	# DECLARATION AND ASSIGNMENT
	
	{
		'input': 'var x;',
		'expected': [
			{'type': Consts.TOKEN_TYPES.KEYWORD, 'value': 'var'},
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': 'x = 5;',
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "x = 'test1';",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
			{'type': Consts.TOKEN_TYPES.STRING, 'value': '\'test1\''},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "x = \"test1\";",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
			{'type': Consts.TOKEN_TYPES.STRING, 'value': '"test1"'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "x = true;",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
			{'type': Consts.TOKEN_TYPES.BOOLEAN, 'value': 'true'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "x = y;",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'y'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "x = y + 5;",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'y'},
			{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '+'},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "var x = 5;",
		'expected': [
			{'type': Consts.TOKEN_TYPES.KEYWORD, 'value': 'var'},
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},

	# OPERATORS

	{
		'input': "x + 6;",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '+'},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "x * 6;",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '*'},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "x == 6;",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '=='},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "x < 6;",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '<'},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "x > 6;",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '>'},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "x + 5 == 6 * 3;",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
			{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '+'},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
			{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '=='},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
			{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '*'},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '3'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},

	# FUNCTIONS AND SEPARATORS

	{
		'input': "print('12345');",
		'expected': [
			{'type': Consts.TOKEN_TYPES.KEYWORD, 'value': 'print'},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '('},
			{'type': Consts.TOKEN_TYPES.STRING, 'value': '\'12345\''},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ')'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "func('12345', 3);",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'func'},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '('},
			{'type': Consts.TOKEN_TYPES.STRING, 'value': '\'12345\''},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ','},
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '3'},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ')'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "func({});",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'func'},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '('},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '{'},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '}'},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ')'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
	{
		'input': "func([]);",
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'func'},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '('},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '['},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ']'},
			{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ')'},
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
		]
	},
]

func test_lexer(params=use_parameters(test_params)):
	var results = lexer.run(params['input'])
	assert_tokens(results['tokens'], params['expected'])
