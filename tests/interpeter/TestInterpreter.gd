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

# DECLARATION AND ASSIGNMENT

func test_supports_declaration():
	var tokens = lexer.run("var x;")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': null},
	]
	assert_scopes(scopes, expected_scopes)

func test_supports_number_assignment():
	var tokens = lexer.run("var x = 5;")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': 5},
	]
	assert_scopes(scopes, expected_scopes)

func test_supports_single_quote_string_assignment():
	var tokens = lexer.run("var x = 'test1';")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': "test1"},
	]
	assert_scopes(scopes, expected_scopes)

func test_supports_double_quote_string_assignment():
	var tokens = lexer.run("var x = \"test1\";")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': "test1"},
	]
	assert_scopes(scopes, expected_scopes)

func test_supports_boolean_assignment():
	var tokens = lexer.run("var x = true;")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': true},
	]
	assert_scopes(scopes, expected_scopes)

func test_supports_identifier_assignment():
	var tokens = lexer.run("var x = 5; var y = x;")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': 5, 'y': 5}
	]
	assert_scopes(scopes, expected_scopes)

func test_supports_expression_assignment():
	var tokens = lexer.run("var x = 5; var y = x + 6;")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': 5, 'y': 11}
	]
	assert_scopes(scopes, expected_scopes)

# OPERATORS

func test_supports_addition_operator():
	var tokens = lexer.run("var x = 5 + 6;")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': 11}
	]
	assert_scopes(scopes, expected_scopes)

func test_supports_multiplication_operator():
	var tokens = lexer.run("var x = 5 * 6;")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': 30}
	]
	assert_scopes(scopes, expected_scopes)

func test_supports_equality_operator():
	var tokens = lexer.run("var x = 4 == 6;")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': false}
	]
	assert_scopes(scopes, expected_scopes)

func test_supports_mixed_operators():
	var tokens = lexer.run("var x = 7 + 5 == 6 * 2;")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	var expected_scopes = [
		{'x': true}
	]
	assert_scopes(scopes, expected_scopes)

# FUNCTIONS AND SEPARATORS

func test_supports_builtins_and_parenthesis():
	watch_signals(interpreter)
	var tokens = lexer.run("print('12345');")
	var instructions = parser.run(tokens)
	var scopes = interpreter.run(instructions)
	assert_signal_emitted_with_parameters(interpreter, 'call_print', [['12345']])
