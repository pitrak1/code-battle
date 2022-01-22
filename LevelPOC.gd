extends Node2D

var levelBuilderScript = preload("res://LevelBuilder.gd")

var __level

func _ready():
	__level = [
		[Consts.LOW, Consts.LOW, Consts.LOW, Consts.LOW, null],
		[Consts.LOW, Consts.ROCK, Consts.LOW, Consts.ROCK, Consts.HIGH],
		[Consts.LOW, Consts.LOW, Consts.LOW, Consts.MIDDLE, Consts.LOW],
		[Consts.TREE, Consts.LOW, Consts.LOW, Consts.TREE,Consts. LOW],
		[null, Consts.WATER, Consts.LOW, Consts.MIDDLE, Consts.LOW]
	]
	
	var __levelBuilder = levelBuilderScript.new()
	__levelBuilder.run(self, __level)
	
