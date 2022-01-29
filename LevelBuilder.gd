extends Node2D

var __tileScene = preload("res://Tile.tscn")

func run(parent, level):
	var window_dimensions = parent.get_viewport_rect().size
	var dimensions = len(level)
	
	var start_y = (window_dimensions.y - dimensions * Consts.TILE_ROW_HEIGHT) / 2
	var start_x = (window_dimensions.x / 2) - ((dimensions - 1) * 0.25 * Consts.TILE_DIAMETER)
	
	var start_position = Vector2(start_x, start_y)
	var currentPosition = start_position
	
	var tiles = []
	
	for i in range(dimensions):
		tiles.push_back([])
		for j in range(dimensions):
			var tile = level[i][j]
			if tile != null:
				var obj = __tileScene.instance()
				parent.add_child(obj)
				obj.setup(tile)
				obj.position = currentPosition
				tiles[i].push_back(obj)
			currentPosition += Vector2(Consts.TILE_DIAMETER, 0)
		currentPosition = Vector2(
			start_position.x - Consts.TILE_DIAMETER * 0.5 * (i + 1), 
			start_position.y + Consts.TILE_ROW_HEIGHT * (i + 1)
		)
		
	return tiles

	

