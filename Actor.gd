extends Node2D

var __paladin_sprite = preload("res://assets/paladin.png")
var __priest_sprite = preload("res://assets/priest.png")
var __rogue_sprite = preload("res://assets/rogue.png")
var __warrior_sprite = preload("res://assets/warrior.png")

var __character_sprites

var actor_name
var __character_type
var grid_position

func setup(__actor_name, character_type, __grid_position):
	actor_name = __actor_name
	__character_type = character_type
	grid_position = __grid_position
	
	if not __character_sprites:
		__character_sprites = {
			Consts.CHARACTERS.PALADIN: __paladin_sprite,
			Consts.CHARACTERS.PRIEST: __priest_sprite,
			Consts.CHARACTERS.ROGUE: __rogue_sprite,
			Consts.CHARACTERS.WARRIOR: __warrior_sprite,
		}
	
	if character_type != null:
		$Sprite.show()
		$Sprite.texture = __character_sprites[character_type]
	else:
		$Sprite.hide()
