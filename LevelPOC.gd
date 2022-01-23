extends Node2D

var levelBuilderScript = preload("res://LevelBuilder.gd")

func _ready():
	var __levelBuilder = levelBuilderScript.new()
	__levelBuilder.run(self, Consts.LEVEL_1)
	
