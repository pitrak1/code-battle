extends StaticBody2D

var __highSprite = preload("res://assets/high.png")
var __lowSprite = preload("res://assets/low.png")
var __middleSprite = preload("res://assets/middle.png")
var __rockSprite = preload("res://assets/rock.png")
var __treeSprite = preload("res://assets/tree.png")
var __waterSprite = preload("res://assets/water.png")

var __sprites

func _ready():
	__sprites = {
		Consts.HIGH: __highSprite,
		Consts.LOW: __lowSprite,
		Consts.MIDDLE: __middleSprite,
		Consts.ROCK: __rockSprite,
		Consts.TREE: __treeSprite,
		Consts.WATER: __waterSprite,
	}

func setup(tileType):
	$Sprite.texture = __sprites[tileType]
			
