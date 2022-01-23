extends Node2D

var __tileScene = preload("res://Tile.tscn")

func run(parent, level):
	var currentPosition = Consts.START_POSITION
	var dimensions = len(level)
	
	for i in range(dimensions):
		for j in range(dimensions):
			var tile = level[i][j]
			if tile != null:
				var obj = __tileScene.instance()
				parent.add_child(obj)
				obj.setup(tile)
				obj.position = currentPosition
			currentPosition += Vector2(Consts.TILE_DIAMETER, 0)
		currentPosition = Vector2(
			Consts.START_POSITION.x - Consts.TILE_DIAMETER * 0.5 * (i + 1), 
			Consts.START_POSITION.y + Consts.TILE_ROW_HEIGHT * (i + 1)
		)

	

