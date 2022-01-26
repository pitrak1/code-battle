extends Node2D

var levelBuilderScript = preload("res://LevelBuilder.gd")
var lexer = preload("res://interpreter/Lexer.gd")
var parser = preload("res://interpreter/Parser.gd")

var tileScene = preload("res://Tile.tscn")

var __lexer
var __parser

func _ready():
	var __levelBuilder = levelBuilderScript.new()
	__levelBuilder.run(self, Consts.LEVEL_1)
	
	$UI.setup(self)
	
	__lexer = lexer.new()
	var tokens = __lexer.run("/Users/nickpitrak/Desktop/test.btl")

	__parser = parser.new()
	var instructions = __parser.run(tokens)

	__parser.print_ast(instructions)

	print("DONE")
	
func _on_restart():
	print('restart')
	
func _on_next():
	print('next')
	
func _on_select_file(path):
#	__lexer = lexer.new()
#	var tokens = __lexer.run(path)
#
#	__parser = parser.new()
#	var instructions = __parser.run(tokens)
#
#	__parser.print_ast(instructions)
#
#	print(path)

	$UI.set_file(path)
	
