extends Node2D

var __tileScene = preload("res://Tile.tscn")
var __actorCollection = preload("res://ActorCollection.gd")

var tiles = []
var actors

func _ready():
	actors = __actorCollection.new()

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
				obj.setup(tile, Vector2(i, j))
				obj.position = currentPosition
				tiles[i].push_back(obj)
			else:
				tiles[i].push_back(null)
			currentPosition += Vector2(Consts.TILE_DIAMETER, 0)
		currentPosition = Vector2(
			start_position.x - Consts.TILE_DIAMETER * 0.5 * (i + 1), 
			start_position.y + Consts.TILE_ROW_HEIGHT * (i + 1)
		)
		
func create_and_place_actor(actor_name, character_type, grid_position, is_enemy):
	var __actor = actors.create_actor(actor_name, character_type, grid_position, is_enemy)
	tiles[grid_position.x][grid_position.y].set_actor(__actor)

func move_actor(actor_name, grid_position):
	var __actor = actors.get_actor_by_name(actor_name)
	
	if __actor:
		var __current_position = __actor.grid_position
		tiles[__current_position.x][__current_position.y].set_actor(null)
		__actor.grid_position = grid_position
		tiles[grid_position.x][grid_position.y].set_actor(__actor)
	
func highlight(grid_position):
	tiles[grid_position.x][grid_position.y].highlight()

func get_tile_info(grid_position):
	return tiles[grid_position.x][grid_position.y].get_tile_info()

func get_actor_by_grid_position(grid_position):
	return tiles[grid_position.x][grid_position.y].get_actor()

func get_actor_by_name(actor_name):
	return actors.get_actor_by_name(actor_name)

func get_actors():
	return actors.get_actors()

func get_player_actors():
	return actors.get_player_actors()

func get_enemy_actors():
	return actors.get_enemy_actors()

func is_passable(grid_position):
	if not tiles[grid_position.x][grid_position.y]:
		return false
	return tiles[grid_position.x][grid_position.y].is_passable()
