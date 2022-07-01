var lexer = preload("res://interpreter/Lexer.gd")
var parser = preload("res://interpreter/Parser.gd")
var interpreter = preload("res://interpreter/Interpreter.gd")
var Utilities = preload("res://interpreter/Utilities.gd")

var __world
var __lexer
var __parser
var __interpreter

func _init(world):
	__world = world
	__lexer = lexer.new()
	__parser = parser.new()
	__interpreter = interpreter.new(world)

func run(filename):
	var file = File.new()
	file.open(filename, File.READ)
	var contents = file.get_as_text()
	file.close()

	var results = __lexer.run(contents)
	if results['status'] != 'success':
		print("ERROR")
	Utilities.print_lexer_results(results)

	var instructions = __parser.run(results['tokens'])
	Utilities.print_parser_results(instructions)


	var scopes = __interpreter.run(instructions)	
	scopes.print_scopes()

	print('DONE')
