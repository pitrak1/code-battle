var actors = []

var __actorScene = preload("res://Actor.tscn")

func create_actor(actor_name, character_type, grid_position):
	var __actor = __actorScene.instance()
	__actor.setup(actor_name, character_type, grid_position)
	actors.push_back(__actor)
	return __actor

func get_actor_by_name(actor_name):
	for actor in actors:
		if actor.actor_name == actor_name:
			return actor

func get_actors():
	var names = []
	for actor in actors:
		names.push_back(actor.actor_name)

	return names