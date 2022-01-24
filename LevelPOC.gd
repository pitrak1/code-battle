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
	
	
func _input(event):
	if event is InputEventKey and event.pressed and event.scancode == KEY_ENTER:
		__parser.parse($LineEdit.get_text())
	
