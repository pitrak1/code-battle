extends Node2D

var __paladin_sprite = preload("res://assets/paladin.png")
var __priest_sprite = preload("res://assets/priest.png")
var __rogue_sprite = preload("res://assets/rogue.png")
var __warrior_sprite = preload("res://assets/warrior.png")

var __character_sprites

func _ready():
	__character_sprites = {
		Consts.CHARACTERS.PALADIN: __paladin_sprite,
		Consts.CHARACTERS.PRIEST: __priest_sprite,
		Consts.CHARACTERS.ROGUE: __rogue_sprite,
		Consts.CHARACTERS.WARRIOR: __warrior_sprite,
	}

func set_character(character_type):
	if character_type != null:
		$Sprite.show()
		$Sprite.texture = __character_sprites[character_type]
	else:
		$Sprite.hide()
