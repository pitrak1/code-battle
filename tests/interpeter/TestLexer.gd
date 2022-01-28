extends "res://addons/gut/test.gd"

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

func before_each():
	lexer = lexerScript.new()
	
func assert_tokens(tokens, expected_tokens):
	assert_eq(tokens.size(), expected_tokens.size())
	for i in range(tokens.size()):
		assert_eq(tokens[i].type, expected_tokens[i]['type'])
		assert_eq(tokens[i].value, expected_tokens[i]['value'])

func test_supports_declaration():
	var tokens = lexer.run("var x;")
	var expected_tokens = [
		{'type': Consts.TOKEN_TYPES.KEYWORD, 'value': 'var'},
		{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'x'},
		{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'},
	]
	assert_tokens(tokens, expected_tokens)
	
