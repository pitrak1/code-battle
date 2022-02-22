extends "res://addons/gut/test.gd"

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

const parserScript = preload("res://interpreter/Parser.gd")
var parser

const interpreterScript = preload("res://interpreter/Interpreter.gd")
var interpreter

func before_each():
	lexer = lexerScript.new()
	parser = parserScript.new()
	interpreter = interpreterScript.new()
	
func assert_scopes(scopes, expected_scopes):
	for i in range(scopes.size()):
		for key in scopes[i].keys():
			assert_eq(scopes[i][key], expected_scopes[i][key])

var test_params = [
	
	# DECLARATION AND ASSIGNMENT

	{
		'input': "var x;",
		'expected': [
			{'x': null},
		]
	},
	{
		'input': "var x = 5;",
		'expected': [
			{'x': 5},
		]
	},
	{
		'input': "var x = 'test1';",
		'expected': [
			{'x': "test1"},
		]
	},
	{
		'input': "var x = \"test1\";",
		'expected': [
			{'x': "test1"},
		]
	},
	{
		'input': "var x = true;",
		'expected': [
			{'x': true},
		]
	},
	{
		'input': "var x = 5; var y = x;",
		'expected': [
			{'x': 5, 'y': 5}
		]
	},
	{
		'input': "var x = 5; var y = x + 6;",
		'expected': [
			{'x': 5, 'y': 11}
		]
	},
	{
		'input': "var x = [1, 2, 3]; var y = [x, 'asdf', 6];",
		'expected': [
			{'x': [1, 2, 3], 'y': [[1, 2, 3], 'asdf', 6]}
		]
	},

	# OPERATORS

	{
		'input': "var x = 5 + 6;",
		'expected': [
			{'x': 11}
		]
	},
	{
		'input':"var x = 5 * 6;",
		'expected': [
			{'x': 30}
		]
	},
	{
		'input':"var x = 4 == 6;",
		'expected': [
			{'x': false}
		]
	},
	{
		'input': "var x = 4 < 6;",
		'expected': [
			{'x': true}
		]
	},
	{
		'input': "var x = 4 > 6;",
		'expected': [
			{'x': false}
		]
	},
	{
		'input': "var x = 7 + 5 == 6 * 2;",
		'expected': [
			{'x': true}
		]
	},

	# FUNCTIONS AND SEPARATORS

	{
		'input': "var x = [1, 2, 3]; var y = x[2];",
		'expected': [
			{'x': [1, 2, 3], 'y': 3}
		]
	},
]

func test_interpreter(params=use_parameters(test_params)):
	var lexer_results = lexer.run(params['input'])
	var instructions = parser.run(lexer_results['tokens'])
	var scopes = interpreter.run(instructions)
	assert_scopes(scopes, params['expected'])

# FUNCTIONS AND SEPARATORS

func test_supports_builtins_and_parenthesis():
	watch_signals(interpreter)
	var lexer_results = lexer.run("print('12345');")
	var instructions = parser.run(lexer_results['tokens'])
	var scopes = interpreter.run(instructions)
	assert_signal_emitted_with_parameters(interpreter, 'call_print', [['12345']])
	
# CONDITIONALS AND LOOPS

func test_supports_if_statements():
	watch_signals(interpreter)
	var lexer_results = lexer.run("if (false) { print('12345'); }")
	var instructions = parser.run(lexer_results['tokens'])
	var scopes = interpreter.run(instructions)
	assert_signal_not_emitted(interpreter, 'call_print')
