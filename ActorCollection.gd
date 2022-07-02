var actors = []

var __actorScene = preload("res://Actor.tscn")

func __actor_serializer(actor):
	return {
		'name': actor.actor_name,
		'class': actor.character_type,
		'grid_position': [actor.grid_position.x, actor.grid_position.y],
		'is_enemy': actor.is_enemy
	}

func create_actor(actor_name, character_type, grid_position, is_enemy):
	var __actor = __actorScene.instance()
	__actor.setup(actor_name, character_type, grid_position, is_enemy)
	actors.push_back(__actor)
	return __actor

func get_actor_by_name(actor_name):
	for actor in actors:
		if actor.actor_name == actor_name:
			return __actor_serializer(actor)

func get_actors():
	var all = []
	for actor in actors:
		all.push_back(__actor_serializer(actor))

	return all

func get_player_actors():
	var player_actors = []
	for actor in actors:
		if not actor.is_enemy:
			player_actors.push_back(__actor_serializer(actor))
	return player_actors

func get_enemy_actors():
	var enemies = []
	for actor in actors:
		if actor.is_enemy:
			enemies.push_back(__actor_serializer(actor))
	return enemies
