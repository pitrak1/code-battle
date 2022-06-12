extends "res://addons/gut/test.gd"

const helpersScript = preload("res://Helpers.gd")
var helpers

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

func before_all():
	helpers = helpersScript.new()

func after_all():
	helpers.free()

func before_each():
	lexer = lexerScript.new()

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

func test_lexer(params=use_parameters(test_params)):
	var results = lexer.run(params['input'])
	helpers.assert_tokens(results['tokens'], params['expected'], params['identifier'])

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

func test_lexer_collection(params=use_parameters(test_params_collection)):
	var collection = helpers.shuffle_collection(params['collection'])
	var input = helpers.generate_collection_input(collection)
	var results = lexer.run(input)
	helpers.assert_collection(results['tokens'], collection, params['type'], params['identifier'])
	