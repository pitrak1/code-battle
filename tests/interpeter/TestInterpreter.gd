extends "res://addons/gut/test.gd"

const helpersScript = preload("res://Helpers.gd")
var helpers

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

func before_all():
	helpers = helpersScript.new()

func after_all():
	helpers.free()

var test_params = [
	{
		'identifier': 'declaration',
		'input': "var x;",
		'expected': [
			{'x': null},
		]
	},
	{
		'identifier': 'number assignment',
		'input': "var x = 5;",
		'expected': [
			{'x': 5},
		]
	},
	{
		'identifier': 'single quote string assignment',
		'input': "var x = 'test1';",
		'expected': [
			{'x': "test1"},
		]
	},
	{
		'identifier': 'double quote string assignment',
		'input': "var x = \"test1\";",
		'expected': [
			{'x': "test1"},
		]
	},
	{
		'identifier': 'boolean assignment',
		'input': "var x = true;",
		'expected': [
			{'x': true},
		]
	},
	{
		'identifier': 'variable assignment',
		'input': "var x = 5; var y = x;",
		'expected': [
			{'x': 5, 'y': 5}
		]
	},
	{
		'identifier': 'expression assignment',
		'input': "var x = 5; var y = x + 6;",
		'expected': [
			{'x': 5, 'y': 11}
		]
	},
	{
		'identifier': 'array assignment',
		'input': "var x = [1, 2, 3]; var y = [x, 'asdf', 6];",
		'expected': [
			{'x': [1, 2, 3], 'y': [[1, 2, 3], 'asdf', 6]}
		]
	},
	{
		'identifier': 'addition',
		'input': "var x = 5 + 6;",
		'expected': [
			{'x': 11}
		]
	},
	{
		'identifier': 'multiplication',
		'input':"var x = 5 * 6;",
		'expected': [
			{'x': 30}
		]
	},
	{
		'identifier': 'equality',
		'input':"var x = 4 == 6;",
		'expected': [
			{'x': false}
		]
	},
	{
		'identifier': 'less than',
		'input': "var x = 4 < 6;",
		'expected': [
			{'x': true}
		]
	},
	{
		'identifier': 'greater than',
		'input': "var x = 4 > 6;",
		'expected': [
			{'x': false}
		]
	},
	{
		'identifier': 'equality with expressions',
		'input': "var x = 7 + 5 == 6 * 2;",
		'expected': [
			{'x': true}
		]
	},
	{
		'identifier': 'indexing arrays',
		'input': "var x = [1, 2, 3]; var y = x[2];",
		'expected': [
			{'x': [1, 2, 3], 'y': 3}
		]
	},
	{
		'identifier': 'indexing string keyed object',
		'input': "var x = {'x': 1234, 'y': 2345}; var y = x['y'];",
		'expected': [
			{'x': {'x': 1234, 'y': 2345}, 'y': 2345}
		]
	},
	{
		'identifier': 'indexing number keyed object',
		'input': "var x = {3: 1234, 5: 2345}; var y = x[3];",
		'expected': [
			{'x': {3: 1234, 5: 2345}, 'y': 1234}
		]
	},
	{
		'identifier': 'indexing object using variable',
		'input': "var x = {'i': 1234, 'j': 2345}; var y = 'j'; var z = x[y];",
		'expected': [
			{'x': {'i': 1234, 'j': 2345}, 'y': 'j', 'z': 2345}
		]
	},
]

func test_interpreter(params=use_parameters(test_params)):
	var lexer_results = lexer.run(params['input'])
	var instructions = parser.run(lexer_results['tokens'])
	var scopes = interpreter.run(instructions)
	helpers.assert_scopes(scopes, params['expected'], params['identifier'])

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


