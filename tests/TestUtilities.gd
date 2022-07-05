extends "res://addons/gut/test.gd"

const Utilities = preload("res://Utilities.gd")

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

func before_each():
	lexer = lexerScript.new()

var parse_end_until_matching_separator_params = [
	{
		'identifier': 'basic square brackets',
		'input': "[5 + 6]",
		'additional_values': [','],
		'expected': [
			[
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
				{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '+'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'}
			]
		]
	},
	{
		'identifier': 'basic square brackets with separators',
		'input': "[5 + 6, 1 * 2]",
		'additional_values': [','],
		'expected': [
			[
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
				{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '+'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'}
			],
			[
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '1'},
				{'type': Consts.TOKEN_TYPES.OPERATOR, 'value': '*'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '2'}
			]
		]
	},
	{
		'identifier': 'square brackets with square brackets',
		'input': "[[3, 4, [5]]]",
		'additional_values': [','],
		'expected': [
			[
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '['},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '3'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ','},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '4'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ','},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '['},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ']'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ']'}
			]
		]
	},
	{
		'identifier': 'square brackets with square brackets and separators',
		'input': "[[3, 4, [5]], [6]]",
		'additional_values': [','],
		'expected': [
			[
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '['},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '3'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ','},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '4'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ','},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '['},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ']'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ']'}
			],
			[
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '['},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ']'}
			]
		]
	},
	{
		'identifier': 'basic curly braces',
		'input': "{5: 6}",
		'additional_values': [','],
		'expected': [
			[
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ':'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'}
			]
		]
	},
	{
		'identifier': 'basic curly braces with separators',
		'input': "{5: 6, 1: 2}",
		'additional_values': [','],
		'expected': [
			[
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ':'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'}
			],
			[
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '1'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ':'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '2'}
			]
		]
	},
	{
		'identifier': 'basic curly braces with curly braces',
		'input': "{1: {4: {5: 6}}}",
		'additional_values': [','],
		'expected': [
			[
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '1'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ':'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '{'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '4'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ':'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '{'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ':'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '}'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '}'}
			]
		]
	},
	{
		'identifier': 'basic curly braces with curly braces and separators',
		'input': "{1: {4: {5: 6}}, 2: 3}",
		'additional_values': [','],
		'expected': [
			[
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '1'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ':'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '{'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '4'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ':'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '{'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '5'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ':'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '6'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '}'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': '}'}
			],
			[
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '2'},
				{'type': Consts.TOKEN_TYPES.SEPARATOR, 'value': ':'},
				{'type': Consts.TOKEN_TYPES.NUMBER, 'value': '3'}
			]
		]
	},
]

func assert_tokens(tokens, expected_tokens, identifier):
	assert_eq(tokens.size(), expected_tokens.size(), identifier + ': Tokens is length ' + str(tokens.size()) + ', expected ' + str(expected_tokens.size()))
	for i in range(tokens.size()):
		assert_eq(tokens[i].type, expected_tokens[i]['type'], identifier + ': Token ' + str(i) + ' is of type ' + Consts.TOKEN_TYPE_STRINGS[tokens[i].type] + ', expected ' + Consts.TOKEN_TYPE_STRINGS[expected_tokens[i]['type']])
		assert_eq(tokens[i].value, expected_tokens[i]['value'], identifier + ': Token ' + str(i) + ' has value ' + tokens[i].value + ', expected ' + expected_tokens[i]['value'])

func test_parse_end_until_matching_separator(params=use_parameters(parse_end_until_matching_separator_params)):
	var lexer_results = lexer.run(params['input'])
	var results = Utilities.parse_end_until_matching_separator(lexer_results['tokens'], params['additional_values'])
	assert_eq(results['entries'].size(), params['expected'].size())
	for i in range(results['entries'].size()):
		assert_tokens(results['entries'][i], params['expected'][i], params['identifier'])
