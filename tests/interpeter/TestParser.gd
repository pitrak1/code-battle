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
			elif key != 'left' and key != 'right':
				assert_eq(instruction[key], expected_instruction[key])
			elif key == 'expression':
				__assert_instruction(instruction['expression'], expected_instruction['expression'])
			elif key == 'instructions':
				for i in range(instruction['instructions'].size()):
					__assert_instruction(instruction['instructions'][i], expected_instruction['instructions'][i])
			else:
				__assert_instruction(instruction[key], expected_instruction[key])
			
			
# DECLARATION AND ASSIGNMENT

func test_supports_declaration():
	var tokens = lexer.run("var x;")
	var instructions = parser.run(tokens)
	var expected_instructions = [
		{'type': Consts.INSTRUCTION_TYPES.DECLARATION, 'value': 'x'},
	]
	assert_instructions(instructions, expected_instructions)

func test_supports_number_assignment():
	var tokens = lexer.run("x = 5;")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)

func test_supports_single_quote_string_assignment():
	var tokens = lexer.run("x = 'test1';")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)

func test_supports_double_quote_string_assignment():
	var tokens = lexer.run("x = \"test1\";")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)

func test_supports_boolean_assignment():
	var tokens = lexer.run("x = true;")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)

func test_supports_identifier_assignment():
	var tokens = lexer.run("x = y;")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)

func test_supports_expression_assignment():
	var tokens = lexer.run("x = y + 5;")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)

func test_supports_declaration_assignment():
	var tokens = lexer.run("var x = 5;")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)
	
# OPERATORS

func test_supports_addition_operator():
	var tokens = lexer.run("x + 6;")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)

func test_supports_multiplication_operator():
	var tokens = lexer.run("x * 6;")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)

func test_supports_equality_operator():
	var tokens = lexer.run("x == 6;")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)

func test_supports_mixed_operators():
	var tokens = lexer.run("x + 5 == 6 * 3;")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)

# FUNCTIONS AND SEPARATORS

func test_supports_builtins_and_parenthesis():
	var tokens = lexer.run("print('12345');")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
		'type': Consts.INSTRUCTION_TYPES.BUILTIN, 
		'function': 'print',
		'args': [{
			'type': Consts.INSTRUCTION_TYPES.STRING,
			'value': "12345"
		}]
	}]
	assert_instructions(instructions, expected_instructions)
	
func test_supports_multiple_arguments():
	var tokens = lexer.run("highlight(5, 6);")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)
	
# CONDITIONALS AND LOOPS

func test_supports_if_statements():
	var tokens = lexer.run("if (true) { print('asdf'); }")
	var instructions = parser.run(tokens)
	var expected_instructions = [{
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
	assert_instructions(instructions, expected_instructions)
