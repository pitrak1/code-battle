extends "res://addons/gut/test.gd"

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

const parserScript = preload("res://interpreter/Parser.gd")
var parser

const keys = ['type', 'operator', 'left', 'right', 'value', 'function', 'args']

func before_each():
	lexer = lexerScript.new()
	parser = parserScript.new()
	
func assert_instructions(instructions, expected_instructions):
	assert_eq(instructions.size(), expected_instructions.size(), 'Instructions is length ' + str(instructions.size()) + ', expected ' + str(expected_instructions.size()))
	for i in range(instructions.size()):
		__assert_instruction(instructions[i], expected_instructions[i])

func __assert_instruction(instruction, expected_instruction):
	assert_true('type' in expected_instruction.keys())
	assert_eq(instruction['type'], expected_instruction['type'])
	
	for key in keys:
		if instruction.get(key):
			assert_true(key in expected_instruction.keys())
			if key == 'args':
				for i in range(instruction['args'].size()):
					__assert_instruction(instruction['args'][i], expected_instruction['args'][i])
			elif key == 'left' or key == 'right':
				__assert_instruction(instruction[key], expected_instruction[key])
			elif key == 'expression':
				__assert_instruction(instruction['expression'], expected_instruction['expression'])
			elif key == 'instructions':
				for i in range(instruction['instructions'].size()):
					__assert_instruction(instruction['instructions'][i], expected_instruction['instructions'][i])
			elif key == 'value':
				if typeof(instruction['value']) == TYPE_ARRAY:
					assert_eq(instruction['value'].size(), expected_instruction['value'].size())
					if instruction['type'] == Consts.INSTRUCTION_TYPES.ARRAY:
						for i in range(instruction['value'].size()):
							__assert_instruction(instruction['value'][i], expected_instruction['value'][i])
					elif instruction['type'] == Consts.INSTRUCTION_TYPES.OBJECT:
						for i in range(instruction['value'].size()):
							__assert_instruction(instruction['value'][i]['key'], expected_instruction['value'][i]['key'])
							__assert_instruction(instruction['value'][i]['value'], expected_instruction['value'][i]['value'])
				else:
					assert_eq(instruction[key], expected_instruction[key])
			

var test_params = [

	# DECLARATION AND ASSIGNMENT

	{
		'input': "var x;",
		'expected': [
			{'type': Consts.INSTRUCTION_TYPES.DECLARATION, 'value': 'x'},
		]
	},
	{
		'input': "x = 5;",
		'expected': [{
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
		}]
	},
	{
		'input': "x = 'test1';",
		'expected': [{
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
		}]
	},
	{
		'input': "x = \"test1\";",
		'expected': [{
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
		}]
	},
	{
		'input': "x = true;",
		'expected': [{
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
		}]
	},
	{
		'input': "x = y;",
		'expected': [{
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
		}]
	},
	{
		'input': "x = y + 5;",
		'expected': [{
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
		}]
	},
	{
		'input': "var x = 5;",
		'expected': [{
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
		}]
	},
	{
		'input':"var x = [1, 2, 3];",
		'expected': [{
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
		}]
	},
	{
		'input':"var x = [1 + 2, 2 * 3, 3];",
		'expected': [{
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
		}]
	},
	{
		'input': 'var x = {"x": 1234, "y": 2345};',
		'expected': [{
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
		}]
	},
	{
		'input': 'var x = {555: 1234, 666: 2345};',
		'expected': [{
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
		}]
	},
	{
		'input': 'var x = {x: 1234, y: 2345};',
		'expected': [{
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
		}]
	},
	{
		'input': 'var x = {x: 1234 + 1, y: 2345 * 2};',
		'expected': [{
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
		}]
	},

	# OPERATORS

	{
		'input': "x + 6;",
		'expected': [{
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
		}]
	},
	{
		'input': "x * 6;",
		'expected': [{
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
		}]
	},
	{
		'input': "x == 6;",
		'expected': [{
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
		}]
	},
	{
		'input': "x < 6;",
		'expected': [{
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
		}]
	},
	{
		'input': "x > 6;",
		'expected': [{
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
		}]
	},
	{
		'input': "x + 5 == 6 * 3;",
		'expected': [{
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
		}]
	},
	{
		'input': 'var x = {"test": 1 + 2};',
		'expected': [{
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
							'value': 'test'
						}, 
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
					},
				]
			}
		}]
	},

	# FUNCTIONS AND SEPARATORS

	{
		'input': "print('12345');",
		'expected': [{
			'type': Consts.INSTRUCTION_TYPES.BUILTIN, 
			'function': 'print',
			'args': [{
				'type': Consts.INSTRUCTION_TYPES.STRING,
				'value': "12345"
			}]
		}]
	},
	{
		'input': "highlight(5, 6);",
		'expected': [{
			'type': Consts.INSTRUCTION_TYPES.BUILTIN, 
			'function': 'highlight',
			'args': [{
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 5
			},{
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 6
			}]
		}]
	},
	{
		'input': "x[5];",
		'expected': [{
			'type': Consts.INSTRUCTION_TYPES.INDEX, 
			'value': 'x',
			'index': {
				'type': Consts.INSTRUCTION_TYPES.NUMBER,
				'value': 5
			}
		}]
	},
	{
		'input': "x[5 + 6];",
		'expected': [{
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
		}]
	},

	# CONDITIONALS AND LOOPS

	{
		'input': "if (true) { print('asdf'); }",
		'expected': [{
			'type': Consts.INSTRUCTION_TYPES.IF, 
			'expression': {
				'type': Consts.INSTRUCTION_TYPES.BOOLEAN,
				'value': true
			},
			'instructions': [{
				'type': Consts.INSTRUCTION_TYPES.BUILTIN, 
				'function': 'print',
				'args': [{
					'type': Consts.INSTRUCTION_TYPES.STRING,
					'value': 'asdf'
				}]
			}]
		}]
	},
]

func test_parser(params=use_parameters(test_params)):
	var tokens_results = lexer.run(params['input'])
	var instructions = parser.run(tokens_results['tokens'])
	assert_instructions(instructions, params['expected'])

func test_parser_mine():
	var tokens_results = lexer.run('import "test2.btl";')
	var instructions = parser.run(tokens_results['tokens'])
	var expected = [{
		'type': Consts.INSTRUCTION_TYPES.IMPORT, 
		'value': 'test2.btl',
	}]
	assert_instructions(instructions, expected)
