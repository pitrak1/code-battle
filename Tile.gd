extends Node2D

var __high_sprite = preload("res://assets/high.png")
var __low_sprite = preload("res://assets/low.png")
var __middle_sprite = preload("res://assets/middle.png")
var __rock_sprite = preload("res://assets/rock.png")
var __tree_sprite = preload("res://assets/tree.png")
var __water_sprite = preload("res://assets/water.png")

var __tile_sprites

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
	$Sprite.texture = __tile_sprites[tile_type]
	
func set_actor(actor):
	add_child(actor)
	
func highlight():
	$HighlightSprite.show()
			
