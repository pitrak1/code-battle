extends Node2D

var __tileScene = preload("res://Tile.tscn")

var tiles = []
var characters = []

func setup(level):
	var window_dimensions = self.get_viewport_rect().size
	var dimensions = len(level)
	
	var start_y = (window_dimensions.y - dimensions * Consts.TILE_ROW_HEIGHT) / 2
	var start_x = (window_dimensions.x / 2) - ((dimensions - 1) * 0.25 * Consts.TILE_DIAMETER)
	
	var start_position = Vector2(start_x, start_y)
	var currentPosition = start_position
	
	for i in range(dimensions):
		tiles.push_back([])
		for j in range(dimensions):
			var tile = level[i][j]
			if tile != null:
				var obj = __tileScene.instance()
				self.add_child(obj)
				obj.setup(tile)
				obj.position = currentPosition
				tiles[i].push_back(obj)
			else:
				tiles[i].push_back(null)
			currentPosition += Vector2(Consts.TILE_DIAMETER, 0)
		currentPosition = Vector2(
			start_position.x - Consts.TILE_DIAMETER * 0.5 * (i + 1), 
			start_position.y + Consts.TILE_ROW_HEIGHT * (i + 1)
		)
		
func place_character(character_type, x, y):
	characters.push_back({'type': character_type})
	tiles[x][y].set_character(character_type)

