extends "res://addons/gut/test.gd"

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

const parserScript = preload("res://interpreter/Parser.gd")
var parser

const interpreterScript = preload("res://interpreter/Interpreter.gd")
var interpreter

var world

func before_each():
	world = double("res://World.gd").new()
	lexer = lexerScript.new()
	parser = parserScript.new()
	interpreter = interpreterScript.new(world)

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

func assert_scopes(scopes, expected_scopes, identifier):
	for i in range(scopes.size()):
		__assert_scopes_recursive(scopes.get_scope(i), expected_scopes[i], identifier)

func __assert_scopes_recursive(scope, expected_scope, identifier):
	if typeof(scope) == TYPE_OBJECT:
		for key in scope.get_variable_names():
			if typeof(scope.find_variable(key)) == TYPE_OBJECT or typeof(scope.find_variable(key)) == TYPE_DICTIONARY:
				__assert_scopes_recursive(scope.find_variable(key), expected_scope[key], identifier)
			else:
				assert_eq(scope.find_variable(key), expected_scope[key], identifier + ': key does not match, expected ' + str(key) + ': ' + str(expected_scope[key]) + ', got ' + str(key) + ': ' + str(scope.find_variable(key)))
	else:
		for key in scope.keys():
			if typeof(scope[key]) == TYPE_OBJECT or typeof(scope[key]) == TYPE_DICTIONARY:
				__assert_scopes_recursive(scope[key], expected_scope[key], identifier)
			else:
				assert_eq(scope[key], expected_scope[key], identifier + ': key does not match, expected ' + str(key) + ': ' + str(expected_scope[key]) + ', got ' + str(key) + ': ' + str(scope[key]))


func test_interpreter(params=use_parameters(test_params)):
	var lexer_results = lexer.run(params['input'])
	var instructions = parser.run(lexer_results['tokens'])
	var scopes = interpreter.run(instructions)
	assert_scopes(scopes, params['expected'], params['identifier'])

# FUNCTIONS AND SEPARATORS

func test_supports_builtins_and_parenthesis():
	var lexer_results = lexer.run("highlight(5, 5);")
	var instructions = parser.run(lexer_results['tokens'])
	var scopes = interpreter.run(instructions)
	assert_called(world, 'highlight', [Vector2(5, 5)])

# CONDITIONALS AND LOOPS

func test_supports_if_statements():
	var lexer_results = lexer.run("if (false) { highlight(1, 2); }")
	var instructions = parser.run(lexer_results['tokens'])
	var scopes = interpreter.run(instructions)
	assert_not_called(world, 'highlight')


