extends Node2D

var __high_sprite = preload("res://assets/high.png")
var __low_sprite = preload("res://assets/low.png")
var __middle_sprite = preload("res://assets/middle.png")
var __rock_sprite = preload("res://assets/rock.png")
var __tree_sprite = preload("res://assets/tree.png")
var __water_sprite = preload("res://assets/water.png")

var __tile_sprites

var __paladin_sprite = preload("res://assets/paladin.png")
var __priest_sprite = preload("res://assets/priest.png")
var __rogue_sprite = preload("res://assets/rogue.png")
var __warrior_sprite = preload("res://assets/warrior.png")

var __character_sprites

func _ready():
	__tile_sprites = {
		Consts.HIGH: __high_sprite,
		Consts.LOW: __low_sprite,
		Consts.MIDDLE: __middle_sprite,
		Consts.ROCK: __rock_sprite,
		Consts.TREE: __tree_sprite,
		Consts.WATER: __water_sprite,
	}
	
	__character_sprites = {
		Consts.CHARACTERS.PALADIN: __paladin_sprite,
		Consts.CHARACTERS.PRIEST: __priest_sprite,
		Consts.CHARACTERS.ROGUE: __rogue_sprite,
		Consts.CHARACTERS.WARRIOR: __warrior_sprite,
	}

func setup(tile_type):
	$Sprite.texture = __tile_sprites[tile_type]
	
func set_actor(character_type):
	if character_type != null:
		$ActorSprite.show()
		$ActorSprite.texture = __character_sprites[character_type]
	else:
		$ActorSprite.hide()
	
func highlight():
	$HighlightSprite.show()
			
