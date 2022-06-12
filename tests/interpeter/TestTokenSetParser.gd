extends "res://addons/gut/test.gd"

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

const tokenSetParserScript = preload("res://interpreter/TokenSetParser.gd")
var tokenSetParser

var Utilities = preload("res://interpreter/Utilities.gd")

const keys = ['operator', 'left', 'right', 'value', 'function', 'args']

func before_each():
	lexer = lexerScript.new()
	tokenSetParser = tokenSetParserScript.new()

func assert_instruction(instruction, expected_instruction, identifier):
	assert_true('type' in expected_instruction.keys())
	assert_eq(instruction['type'], expected_instruction['type'], identifier + ': key type does not match, expected: ' + Consts.INSTRUCTION_TYPE_STRINGS[expected_instruction['type']] + ', actual: ' + Consts.INSTRUCTION_TYPE_STRINGS[instruction['type']])

	for key in keys:
		if instruction.get(key):
			assert_true(key in expected_instruction.keys(), identifier + ': unexpected key ' + key)
			if key == 'args':
				for i in range(instruction['args'].size()):
					assert_instruction(instruction['args'][i], expected_instruction['args'][i], identifier)
			elif key == 'left' or key == 'right':
				assert_instruction(instruction[key], expected_instruction[key], identifier)
			elif key == 'expression':
				assert_instruction(instruction['expression'], expected_instruction['expression'], identifier)
			elif key == 'instructions':
				for i in range(instruction['instructions'].size()):
					assert_instruction(instruction['instructions'][i], expected_instruction['instructions'][i], identifier)
			elif key == 'value':
				if typeof(instruction['value']) == TYPE_ARRAY:
					assert_eq(instruction['value'].size(), expected_instruction['value'].size(), identifier + ': array sizes do not match, expected: ' + str(expected_instruction['value'].size()) + ', actual: ' + str(instruction['value'].size()))
					if instruction['type'] == Consts.INSTRUCTION_TYPES.ARRAY:
						for i in range(instruction['value'].size()):
							assert_instruction(instruction['value'][i], expected_instruction['value'][i], identifier)
					elif instruction['type'] == Consts.INSTRUCTION_TYPES.OBJECT:
						for i in range(instruction['value'].size()):
							assert_instruction(instruction['value'][i]['key'], expected_instruction['value'][i]['key'], identifier)
							assert_instruction(instruction['value'][i]['value'], expected_instruction['value'][i]['value'], identifier)
				else:
					assert_eq(instruction[key], expected_instruction[key], identifier + ': values do not match, expected: ' + str(expected_instruction[key]) + ', actual: ' + str(instruction[key]))


var test_params = [
	{
		'identifier': 'declaration',
		'input': "var x",
		'expected': {'type': Consts.INSTRUCTION_TYPES.DECLARATION, 'value': 'x'},
	},
	{
		'identifier': 'number assignment',
		'input': "x = 5",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 5
			}
		}
	},
	{
		'identifier': 'single quote string assignment',
		'input': "x = 'test1'",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.STRING,
				'value': "test1"
			}
		}
	},
	{
		'identifier': 'double quote string assignment',
		'input': "x = \"test1\"",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.STRING,
				'value': "test1"
			}
		}
	},
	{
		'identifier': 'boolean assignment',
		'input': "x = true",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.BOOLEAN,
				'value': true
			}
		}
	},
	{
		'identifier': 'variable assignment',
		'input': "x = y",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': "y"
			}
		}
	},
	{
		'identifier': 'expression assignment',
		'input': "x = y + 5",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.OPERATION,
				'operator': "+",
				'left': {
					'type': Consts.INSTRUCTION_TYPES.VARIABLE,
					'value': 'y'
				},
				'right': {
					'type': Consts.INSTRUCTION_TYPES.NUMBER,
					'value': 5
				}
			}
		}
	},
	{
		'identifier': 'declaration with assignment',
		'input': "var x = 5",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.DECLARATION,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 5
			}
		}
	},
	{
		'identifier': 'array declaration with assignment',
		'input':"var x = [1, 2, 3]",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.DECLARATION,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.ARRAY,
				'value': [
					{'type': Consts.INSTRUCTION_TYPES.NUMBER, 'value': 1},
					{'type': Consts.INSTRUCTION_TYPES.NUMBER, 'value': 2},
					{'type': Consts.INSTRUCTION_TYPES.NUMBER, 'value': 3}
				]
			}
		}
	},
	{
		'identifier': 'array declaration with assignment and expressions',
		'input':"var x = [1 + 2, 2 * 3, 3]",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.DECLARATION,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.ARRAY,
				'value': [
					{
						'type': Consts.INSTRUCTION_TYPES.OPERATION,
						'operator': '+',
						'left': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 1
						},
						'right': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 2
						}
					},
					{
						'type': Consts.INSTRUCTION_TYPES.OPERATION,
						'operator': '*',
						'left': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 2
						},
						'right': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 3
						}
					},
					{'type': Consts.INSTRUCTION_TYPES.NUMBER, 'value': 3}
				]
			}
		}
	},
	{
		'identifier': 'object declaration with assignment with string keys',
		'input': 'var x = {"x": 1234, "y": 2345}',
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.DECLARATION,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.OBJECT,
				'value': [
					{
						'key': {
							'type': Consts.INSTRUCTION_TYPES.STRING,
							'value': 'x'
						},
						'value': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 1234
						}
					},
					{
						'key': {
							'type': Consts.INSTRUCTION_TYPES.STRING,
							'value': 'y'
						},
						'value': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 2345
						}
					},
				]
			}
		}
	},
	{
		'identifier': 'object declaration with assignment with number keys',
		'input': 'var x = {555: 1234, 666: 2345}',
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.DECLARATION,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.OBJECT,
				'value': [
					{
						'key': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 555
						},
						'value': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 1234
						}
					},
					{
						'key': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 666
						},
						'value': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 2345
						}
					},
				]
			}
		}
	},
	{
		'identifier': 'object declaration with assignment with variable keys',
		'input': 'var x = {x: 1234, y: 2345}',
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.DECLARATION,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.OBJECT,
				'value': [
					{
						'key': {
							'type': Consts.INSTRUCTION_TYPES.VARIABLE,
							'value': 'x'
						},
						'value': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 1234
						}
					},
					{
						'key': {
							'type': Consts.INSTRUCTION_TYPES.VARIABLE,
							'value': 'y'
						},
						'value': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 2345
						}
					},
				]
			}
		}
	},
	{
		'identifier': 'object declaration with assignment with expression values',
		'input': 'var x = {x: 1234 + 1, y: 2345 * 2}',
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.DECLARATION,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.OBJECT,
				'value': [
					{
						'key': {
							'type': Consts.INSTRUCTION_TYPES.VARIABLE,
							'value': 'x'
						},
						'value': {
							'type': Consts.INSTRUCTION_TYPES.OPERATION,
							'operator': '+',
							'left': {
								'type': Consts.INSTRUCTION_TYPES.NUMBER,
								'value': 1234
							},
							'right': {
								'type': Consts.INSTRUCTION_TYPES.NUMBER,
								'value': 1
							}
						}
					},
					{
						'key': {
							'type': Consts.INSTRUCTION_TYPES.VARIABLE,
							'value': 'y'
						},
						'value': {
							'type': Consts.INSTRUCTION_TYPES.OPERATION,
							'operator': '*',
							'left': {
								'type': Consts.INSTRUCTION_TYPES.NUMBER,
								'value': 2345
							},
							'right': {
								'type': Consts.INSTRUCTION_TYPES.NUMBER,
								'value': 2
							}
						}
					},
				]
			}
		}
	},
	{
		'identifier': 'addition',
		'input': "x + 6",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.OPERATION,
			'operator': '+',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 6
			}
		}
	},
	{
		'identifier': 'multiplication',
		'input': "x * 6",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.OPERATION,
			'operator': '*',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 6
			}
		}
	},
	{
		'identifier': 'equality',
		'input': "x == 6",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.OPERATION,
			'operator': '==',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 6
			}
		}
	},
	{
		'identifier': 'less than',
		'input': "x < 6",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.OPERATION,
			'operator': '<',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 6
			}
		}
	},
	{
		'identifier': 'greater than',
		'input': "x > 6",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.OPERATION,
			'operator': '>',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.VARIABLE,
				'value': 'x'
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 6
			}
		}
	},
	{
		'identifier': 'equality with expressions',
		'input': "x + 5 == 6 * 3",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.OPERATION,
			'operator': '==',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.OPERATION,
				'operator': '+',
				'left': {
					'type': Consts.INSTRUCTION_TYPES.VARIABLE,
					'value': 'x'
				},
				'right': {
					'type': Consts.INSTRUCTION_TYPES.NUMBER,
					'value': 5
				}
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.OPERATION,
				'operator': '*',
				'left': {
					'type': Consts.INSTRUCTION_TYPES.NUMBER,
					'value': 6
				},
				'right': {
					'type': Consts.INSTRUCTION_TYPES.NUMBER,
					'value': 3
				}
			}
		}
	},
	{
		'identifier': 'export with declaration and assignment',
		'input': 'export var x = 5',
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.ASSIGNMENT,
			'operator': '=',
			'left': {
				'type': Consts.INSTRUCTION_TYPES.DECLARATION,
				'value': 'x',
				'exported': true
			},
			'right': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 5
			}
		}
	},
	{
		'identifier': 'built in with single argument',
		'input': "print('12345')",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.BUILTIN,
			'function': 'print',
			'args': [{
				'type': Consts.INSTRUCTION_TYPES.STRING,
				'value': "12345"
			}]
		}
	},
	{
		'identifier': 'built in with multiple arguments',
		'input': "highlight(5, 6)",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.BUILTIN,
			'function': 'highlight',
			'args': [{
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 5
			},{
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 6
			}]
		}
	},
	{
		'identifier': 'array index',
		'input': "x[5]",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.INDEX,
			'value': 'x',
			'index': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 5
			}
		}
	},
	{
		'identifier': 'array index with expression',
		'input': "x[5 + 6]",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.INDEX,
			'value': 'x',
			'index': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': {
					'type': Consts.INSTRUCTION_TYPES.OPERATION,
						'operator': '+',
						'left': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 1
						},
						'right': {
							'type': Consts.INSTRUCTION_TYPES.NUMBER,
							'value': 2
						}
				}
			}
		}
	},
	{
		'identifier': 'function call with argument',
		'input': "test_function('asdf')",
		'expected': {
			'type': Consts.INSTRUCTION_TYPES.CALL,
			'function': 'test_function',
			'args': [{
				'type': Consts.INSTRUCTION_TYPES.STRING,
				'value': 'asdf'
			}]
		}
	},
]

func test_token_set_parser(params=use_parameters(test_params)):
	var tokens_results = lexer.run(params['input'])
	Utilities.print_lexer_results(tokens_results)
	var instruction = tokenSetParser.run(tokens_results['tokens'])
	assert_instruction(instruction, params['expected'], params['identifier'])

