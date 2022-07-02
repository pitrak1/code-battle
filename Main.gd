extends Node2D

var worldScene = preload("res://World.tscn")
var runner = preload("res://interpreter/Runner.gd")

func _ready():
	var world = worldScene.instance()
	add_child(world)
	world.setup(Consts.LEVEL_1)
	world.create_and_place_actor("Paladin Boy", Consts.CHARACTERS.PALADIN, Vector2(6, 2), false)
	world.create_and_place_actor("Warrior Girl", Consts.CHARACTERS.WARRIOR, Vector2(2, 6), true)
	# world.move_actor("Paladin Boy", Vector2(5, 8))
	# world.highlight(Vector2(5, 8))

	$UI.setup(self)

	var __runner = runner.new(world)
	__runner.run("C://Users/pitra/Documents/Github/code-battle/showcase.btl")

func _on_restart():
	print('restart')

func _on_next():
	print('next')

func _on_select_file(path):
	$UI.set_file(path)

