extends "res://addons/gut/test.gd"

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

func assert_tokens(tokens, expected_tokens, identifier):
	assert_eq(tokens.size(), expected_tokens.size(), identifier + ': Tokens is length ' + str(tokens.size()) + ', expected ' + str(expected_tokens.size()))
	for i in range(tokens.size()):
		assert_eq(tokens[i].type, expected_tokens[i]['type'], identifier + ': Token ' + str(i) + ' is of type ' + Consts.TOKEN_TYPE_STRINGS[tokens[i].type] + ', expected ' + Consts.TOKEN_TYPE_STRINGS[expected_tokens[i]['type']])
		assert_eq(tokens[i].value, expected_tokens[i]['value'], identifier + ': Token ' + str(i) + ' has value ' + tokens[i].value + ', expected ' + expected_tokens[i]['value'])

func before_each():
	lexer = lexerScript.new()

func test_lexer(params=use_parameters(test_params)):
	var results = lexer.run(params['input'])
	assert_tokens(results['tokens'], params['expected'], params['identifier'])
	
var test_params = [
	{
		'identifier': 'single quote strings',
		'input': '\'testString\'',
		'expected': [
			{'type': Consts.TOKEN_TYPES.STRING, 'value': '\'testString\''},
		]
	},
	{
		'identifier': 'double quote strings',
		'input': '"testString"',
		'expected': [
			{'type': Consts.TOKEN_TYPES.STRING, 'value': '"testString"'},
		]
	},
	{
		'identifier': 'mixing quotation types',
		'input': '"testString" \'testString2\'',
		'expected': [
			{'type': Consts.TOKEN_TYPES.STRING, 'value': '"testString"'},
			{'type': Consts.TOKEN_TYPES.STRING, 'value': '\'testString2\''},
		]
	},
	{
		'identifier': 'numbers',
		'input': '123455',
		'expected': [
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '123455'},
		]
	},
	{
		'identifier': 'floating point numbers',
		'input': '123.455',
		'expected': [
			{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '123.455'},
		]
	},
	{
		'identifier': 'identifiers',
		'input': 'testing_1',
		'expected': [
			{'type': Consts.TOKEN_TYPES.IDENTIFIER, 'value': 'testing_1'}
		]
	},
	{
		'identifier': 'assignment',
		'input': '=',
		'expected': [
			{'type': Consts.TOKEN_TYPES.ASSIGNMENT, 'value': '='}
		]
	},
	{
		'identifier': 'semicolon',
		'input': ';',
		'expected': [
			{'type': Consts.TOKEN_TYPES.SEMICOLON, 'value': ';'}
		]
	},
	{
		'identifier': 'comment',
		'input': '//',
		'expected': []
	},
]

func shuffle_collection(collection):
	var result = collection.duplicate()
	result.shuffle()
	return result

func generate_collection_input(collection):
	var result = ''

	for i in range(collection.size()):
		result += collection[i] + ' '

	return result


func assert_collection(tokens, collection, type, identifier):
	assert_eq(tokens.size(), collection.size(), identifier + ': Tokens is length ' + str(tokens.size()) + ', expected ' + str(collection.size()))
	for i in range(tokens.size()):
		assert_eq(tokens[i].type, type, identifier + ': Token ' + str(i) + ' is of type ' + Consts.TOKEN_TYPE_STRINGS[tokens[i].type] + ', expected ' + Consts.TOKEN_TYPE_STRINGS[type])
		assert_eq(tokens[i].value, collection[i], identifier + ': Token ' + str(i) + ' has value ' + tokens[i].value + ', expected ' + collection[i])


func test_lexer_collection(params=use_parameters(test_params_collection)):
	var collection = shuffle_collection(params['collection'])
	var input = generate_collection_input(collection)
	var results = lexer.run(input)
	assert_collection(results['tokens'], collection, params['type'], params['identifier'])
	
var test_params_collection = [
	{	
		'identifier': 'digits',
		'collection': Consts.DIGITS,
		'type': Consts.TOKEN_TYPES.NUMBER
	},
	{	
		'identifier': 'letters',
		'collection': Consts.LETTERS,
		'type': Consts.TOKEN_TYPES.IDENTIFIER
	},
	{	
		'identifier': 'keywords',
		'collection': Consts.KEYWORDS,
		'type': Consts.TOKEN_TYPES.KEYWORD
	},
	{	
		'identifier': 'separators',
		'collection': Consts.SEPARATORS,
		'type': Consts.TOKEN_TYPES.SEPARATOR
	},
	{	
		'identifier': 'operators',
		'collection': Consts.OPERATORS,
		'type': Consts.TOKEN_TYPES.OPERATOR
	},
	{	
		'identifier': 'booleans',
		'collection': Consts.BOOLEANS,
		'type': Consts.TOKEN_TYPES.BOOLEAN
	},
]
