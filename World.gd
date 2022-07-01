extends Node2D

var __tileScene = preload("res://Tile.tscn")
var __actorScene = preload("res://Actor.tscn")

var tiles = []
var actors = []

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
		
func create_and_place_actor(actor_name, character_type, grid_position):
	var __actor = __actorScene.instance()
	__actor.setup(actor_name, character_type, grid_position)
	actors.push_back(__actor)
	tiles[grid_position.x][grid_position.y].set_actor(__actor)

func move_actor(actor_name, grid_position):
	var __actor
	for actor in actors:
		if actor.actor_name == actor_name:
			__actor = actor
			break
			
	if __actor:
		var __current_position = __actor.grid_position
		tiles[__current_position.x][__current_position.y].set_actor(null)
		__actor.grid_position = grid_position
		tiles[grid_position.x][grid_position.y].set_actor(__actor)
	
func highlight(grid_position):
	tiles[grid_position.x][grid_position.y].highlight()

func get_tile_info(grid_position):
	return tiles[grid_position.x][grid_position.y].get_tile_info()
