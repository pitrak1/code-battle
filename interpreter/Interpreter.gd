var lexer = preload("res://interpreter/Lexer.gd")
var parser = preload("res://interpreter/Parser.gd")
var ScopeStack = preload("res://interpreter/ScopeStack.gd")

var world

func _init(__world):
	world = __world

func run(__instructions):
	var scopes = ScopeStack.new()

	while len(__instructions):
		var instruction = __instructions.pop_front()
		__interpret_instruction(instruction, scopes)

	return scopes

func __interpret_instruction(instruction, scopes, left_side = false):
	match (instruction.type):
		Consts.INSTRUCTION_TYPES.ASSIGNMENT:
			return __handle_assignment(instruction, scopes)
		Consts.INSTRUCTION_TYPES.DECLARATION:
			return __handle_declaration(instruction, scopes)
		Consts.INSTRUCTION_TYPES.NUMBER:
			return __handle_number(instruction, scopes)
		Consts.INSTRUCTION_TYPES.VARIABLE:
			return __handle_variable(instruction, scopes, left_side)
		Consts.INSTRUCTION_TYPES.STRING:
			return instruction.value
		Consts.INSTRUCTION_TYPES.BOOLEAN:
			return instruction.value
		Consts.INSTRUCTION_TYPES.OPERATION:
			return __handle_operation(instruction, scopes)
		Consts.INSTRUCTION_TYPES.BUILTIN:
			return __handle_builtin(instruction, scopes)
		Consts.INSTRUCTION_TYPES.IF:
			return __handle_if(instruction, scopes)
		Consts.INSTRUCTION_TYPES.WHILE:
			return __handle_while(instruction, scopes)
		Consts.INSTRUCTION_TYPES.ARRAY:
			return __handle_array(instruction, scopes)
		Consts.INSTRUCTION_TYPES.INDEX:
			return __handle_index(instruction, scopes)
		Consts.INSTRUCTION_TYPES.OBJECT:
			return __handle_object(instruction, scopes)
		Consts.INSTRUCTION_TYPES.IMPORT:
			return __handle_import(instruction, scopes)
		Consts.INSTRUCTION_TYPES.FUNCTION:
			return __handle_function_definition(instruction, scopes)
		Consts.INSTRUCTION_TYPES.CALL:
			return __handle_function_call(instruction, scopes)
		Consts.INSTRUCTION_TYPES.RETURN:
			return __handle_return(instruction, scopes)
		Consts.INSTRUCTION_TYPES.CLASS:
			return __handle_class(instruction, scopes)

func __handle_function_call(instruction, scopes):
	var function_def = scopes.find_variable(instruction.function)
	assert(function_def)

	scopes.create_new_scope()
	assert(len(function_def.args) == len(instruction.args))
	var arg_index = 0
	while arg_index < len(function_def.args):
		scopes.add_local_variable(function_def.args[arg_index].value, __interpret_instruction(instruction.args[arg_index], scopes))
		arg_index += 1

	for inst in function_def.instructions:
		__interpret_instruction(inst, scopes)

	var return_value = scopes.find_variable('return')
	scopes.destroy_scope()
	return return_value

func __handle_assignment(instruction, scopes):
	var value = __interpret_instruction(instruction.right, scopes)
	var scope_info = __interpret_instruction(instruction.left, scopes, true)
	scopes.add_variable(scope_info['exported'], scope_info.key, value)

func __handle_declaration(instruction, scopes):
	scopes.add_variable(instruction.exported, instruction.value, null)
	return {'key': instruction.value, 'exported': instruction.exported}

func __handle_function_definition(instruction, scopes):
	return instruction;

func __handle_number(instruction, scopes):
	return int(float(instruction.value))

func __handle_variable(instruction, scopes, left_side):
	if left_side:
		return {'key': instruction.value, 'exported': false}
	else:
		return scopes.find_variable(instruction.value)

func __handle_operation(instruction, scopes):
	var operand_2 = __interpret_instruction(instruction.right, scopes)
	var operand_1 = __interpret_instruction(instruction.left, scopes)
	if instruction.operator == '+':
		return operand_1 + operand_2
	elif instruction.operator == '*':
		return operand_1 * operand_2
	elif instruction.operator == '==':
		return operand_1 == operand_2
	elif instruction.operator == '<':
		return operand_1 < operand_2
	elif instruction.operator == '>':
		return operand_1 > operand_2

func __handle_builtin(instruction, scopes):
	var args = []
	for arg in instruction.args:
		args.push_back(__interpret_instruction(arg, scopes))
	var function_name = instruction.function

	if (function_name == 'get_tile_info'):
		assert(len(args), 2)
		return Consts.TILE_STRINGS[world.get_tile_info(Vector2(args[0], args[1]))]
	elif (function_name == 'print'):
		assert(len(args), 1)
		print(args[0])
	elif (function_name == 'highlight'):
		assert(len(args), 2)
		world.highlight(Vector2(args[0], args[1]))
	elif (function_name == 'get_actor_by_name'):
		assert(len(args), 1)
		return world.get_actor_by_name(args[0])
	elif (function_name == 'get_actor_by_grid_position'):
		assert(len(args), 2)
		return world.get_actor_by_grid_position(Vector2(args[0], args[1]))
	elif (function_name == 'get_actors'):
		return world.get_actors()
	elif (function_name == 'get_player_actors'):
		return world.get_player_actors()
	elif (function_name == 'get_enemy_actors'):
		return world.get_enemy_actors()
	elif (function_name == 'get_shortest_path'):
		return world.get_shortest_path(Vector2(args[0], args[1]), Vector2(args[2], args[3]))
	elif (function_name == 'move_actor_to_adjacent_tile'):
		return world.move_actor_to_adjacent_tile(args[0], Vector2(args[1], args[2]))

func __handle_if(instruction, scopes):
	var expression = __interpret_instruction(instruction.expression, scopes)
	if (expression):
		scopes.create_new_scope()
		for inst in instruction.instructions:
			__interpret_instruction(inst, scopes)
		scopes.destroy_scope()

func __handle_while(instruction, scopes):
	var expression = __interpret_instruction(instruction.expression, scopes)
	scopes.create_new_scope()
	while (expression):
		for inst in instruction.instructions:
			__interpret_instruction(inst, scopes)
		expression = __interpret_instruction(instruction.expression, scopes)
	scopes.destroy_scope()

func __handle_array(instruction, scopes):
	var results = []
	for inst in instruction.value:
		results.push_back(__interpret_instruction(inst, scopes))
	return results

func __handle_index(instruction, scopes):
	var variable = scopes.find_variable(instruction.value)
	var index = __interpret_instruction(instruction.index, scopes)
	return variable[index]

func __handle_object(instruction, scopes):
	var result = {}
	for pair in instruction.value:
		var key = __interpret_instruction(pair.key, scopes)
		var value = __interpret_instruction(pair.value, scopes)
		result[key] = value
	return result

func __handle_import(instruction, scopes):
	var file = File.new()
	file.open(instruction.value, File.READ)
	var contents = file.get_as_text()
	file.close()

	var __lexer = lexer.new()
	var results = __lexer.run(contents)
	if results['status'] != 'success':
		print("ERROR")

	var __parser = parser.new()
	var __instructions = __parser.run(results['tokens'])

	var interpreter = load("res://interpreter/Intrepreter.gd")
	var __intrepreter = interpreter.new()
	var __scopes = __intrepreter.run(__instructions)

	return __scopes.get_scope(0)

func __handle_return(instruction, scopes):
	scopes.add_local_variable('return', __interpret_instruction(instruction.value, scopes))

func __handle_class(instruction, scopes):
	scopes.create_new_scope()
	for inst in instruction.instructions:
		__interpret_instruction(inst, scopes)
	var class_scope = scopes.get_current_scope()
	scopes.destroy_scope()
	return class_scope
