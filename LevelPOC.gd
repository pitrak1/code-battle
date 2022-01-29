extends Node2D

var levelBuilderScript = preload("res://LevelBuilder.gd")
var lexer = preload("res://interpreter/Lexer.gd")
var parser = preload("res://interpreter/Parser.gd")
var interpreter = preload("res://interpreter/Interpreter.gd")

var tileScene = preload("res://Tile.tscn")

var __lexer
var __parser
var __interpreter

func _ready():
	var __levelBuilder = levelBuilderScript.new()
	__levelBuilder.run(self, Consts.LEVEL_1)
	
	$UI.setup(self)
	
	var file = File.new()
	file.open("/Users/nickpitrak/Desktop/test.btl", File.READ)
	var contents = file.get_as_text()
	file.close()
	
	__lexer = lexer.new()
	var tokens = __lexer.run(contents)
	
#	__lexer.print_tokens()

	__parser = parser.new()
	var instructions = __parser.run(tokens)

	__parser.print_ast(instructions)

	__interpreter = interpreter.new()
	__interpreter.connect("call_print", self, "handle_print")
	__interpreter.connect("call_highlight", self, "handle_highlight")
	__interpreter.run(instructions)

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
	
