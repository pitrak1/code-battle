extends Node2D

var levelBuilderScript = preload("res://LevelBuilder.gd")
var commandLineParserScript = preload("res://CommandLineParser.gd")

var tileScene = preload("res://Tile.tscn")

var __parser

func _ready():
	var __levelBuilder = levelBuilderScript.new()
	__levelBuilder.run(self, Consts.LEVEL_1)
	
	__parser = commandLineParserScript.new()
	__parser.setup()
	
	$UI.setup(self)
	
func _on_restart():
	print('restart')
	
func _on_next():
	print('next')
	
func _on_select_file(path):
	print(path)
	
