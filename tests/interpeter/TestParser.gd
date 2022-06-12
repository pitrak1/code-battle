extends "res://addons/gut/test.gd"

const helpersScript = preload("res://Helpers.gd")
var helpers

const lexerScript = preload("res://interpreter/Lexer.gd")
var lexer

const parserScript = preload("res://interpreter/Parser.gd")
var parser

func before_all():
	helpers = helpersScript.new()

func after_all():
	helpers.free()

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
		'input': "function test_function (asdf, asdf2) { print('asdf'); }",
		'expected': [{
			'type': Consts.INSTRUCTION_TYPES.FUNCTION,
			'value': 'test_function',
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

func test_parser(params=use_parameters(test_params)):
	var tokens_results = lexer.run(params['input'])
	var instructions = parser.run(tokens_results['tokens'])
	helpers.assert_instructions(instructions, params['expected'], params['identifier'])

