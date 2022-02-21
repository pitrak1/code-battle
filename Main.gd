extends Node2D

var worldScene = preload("res://World.tscn")
var lexer = preload("res://interpreter/Lexer.gd")
var parser = preload("res://interpreter/Parser.gd")
var interpreter = preload("res://interpreter/Interpreter.gd")
var Utilities = preload("res://interpreter/Utilities.gd")

var __lexer
var __parser
var __interpreter

func _ready():
	var world = worldScene.instance()
	add_child(world)
	world.setup(Consts.LEVEL_1)
	world.create_and_place_actor("Paladin Boy", Consts.CHARACTERS.PALADIN, Vector2(3, 4))
	world.move_actor("Paladin Boy", Vector2(5, 8))
	world.highlight(Vector2(5, 8))
	
	$UI.setup(self)
	
	var file = File.new()
	file.open("C:/Users/pitra/Desktop/test.btl", File.READ)
	var contents = file.get_as_text()
	file.close()
	
	__lexer = lexer.new()
	var results = __lexer.run(contents)
	
	if results['status'] != 'success':
		print("ERROR")

	Utilities.print_lexer_results(results)

	__parser = parser.new()
	var instructions = __parser.run(results['tokens'])

	__parser.print_ast(instructions)

	__interpreter = interpreter.new()
	__interpreter.connect("call_print", self, "handle_print")
	__interpreter.connect("call_highlight", self, "handle_highlight")
	var scopes = __interpreter.run(instructions)
	
	__interpreter.print_scopes(scopes)

	print("DONE")
	
func _on_restart():
	print('restart')
	
func _on_next():
	print('next')
	
func _on_select_file(path):
	$UI.set_file(path)
	
func handle_print(args):
	print(args[0])
	
func handle_highlight(args):
	print('got here ' + str(args[0]) + str(args[1]))
	
