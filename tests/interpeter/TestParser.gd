extends "res://addons/gut/test.gd"

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

const parserScript = preload("res://interpreter/Parser.gd")
var parser

func before_each():
	lexer = lexerScript.new()
	parser = parserScript.new()

var test_params = [
	{
		'identifier': 'non block braces',
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
		'identifier': 'if block',
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
	{
		'identifier': 'while block',
		'input': "while (true) { print('asdf'); }",
		'expected': [{
			'type': Consts.INSTRUCTION_TYPES.WHILE,
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
	{
		'identifier': 'function definition with arguments',
		'input': "function (asdf, asdf2) { print('asdf'); }",
		'expected': [{
			'type': Consts.INSTRUCTION_TYPES.FUNCTION,
			'args': [
				{
					'type': Consts.INSTRUCTION_TYPES.VARIABLE,
					'value': 'asdf'
				},
				{
					'type': Consts.INSTRUCTION_TYPES.VARIABLE,
					'value': 'asdf2'
				}
			],
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


const keys = ['operator', 'left', 'right', 'value', 'function', 'args']

func assert_instructions(instructions, expected_instructions, identifier):
	assert_eq(instructions.size(), expected_instructions.size(), identifier + ': Instructions is length ' + str(instructions.size()) + ', expected ' + str(expected_instructions.size()))
	for i in range(instructions.size()):
		assert_instruction(instructions[i], expected_instructions[i], identifier)


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
				elif typeof(instruction['value']) == TYPE_OBJECT:
					assert_instruction(instruction['value'], expected_instruction['value'], identifier)
				else:
					assert_eq(instruction[key], expected_instruction[key], identifier + ': values do not match, expected: ' + str(expected_instruction[key]) + ', actual: ' + str(instruction[key]))

func test_parser(params=use_parameters(test_params)):
	var tokens_results = lexer.run(params['input'])
	var instructions = parser.run(tokens_results['tokens'])
	assert_instructions(instructions, params['expected'], params['identifier'])

