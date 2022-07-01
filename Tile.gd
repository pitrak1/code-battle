extends Node2D

var __high_sprite = preload("res://assets/high.png")
var __low_sprite = preload("res://assets/low.png")
var __middle_sprite = preload("res://assets/middle.png")
var __rock_sprite = preload("res://assets/rock.png")
var __tree_sprite = preload("res://assets/tree.png")
var __water_sprite = preload("res://assets/water.png")

var __tile_sprites

var __tile_type
var __actor

func _ready():
	__tile_sprites = {
		Consts.HIGH: __high_sprite,
		Consts.LOW: __low_sprite,
		Consts.MIDDLE: __middle_sprite,
		Consts.ROCK: __rock_sprite,
		Consts.TREE: __tree_sprite,
		Consts.WATER: __water_sprite,
	}

func setup(tile_type):
	__tile_type = tile_type
	$Sprite.texture = __tile_sprites[tile_type]
	$HighlightSprite.position = Vector2(0, Consts.TILE_HIGHLIGHT_OFFSET + Consts.TILE_SPRITE_OFFSETS[tile_type])
	
func set_actor(actor):
	if __actor:
		remove_child(__actor)
		
	if actor:
		add_child(actor)
		actor.position = Vector2(0, Consts.TILE_SPRITE_OFFSETS[__tile_type])
		
	__actor = actor

func get_actor():
	return __actor;
	
func highlight():
	$HighlightSprite.show()

func get_tile_info():
	return __tile_type
			
