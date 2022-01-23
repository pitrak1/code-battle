extends StaticBody2D

var __highSprite = preload("res://assets/high.png")
var __lowSprite = preload("res://assets/low.png")
var __middleSprite = preload("res://assets/middle.png")
var __rockSprite = preload("res://assets/rock.png")
var __treeSprite = preload("res://assets/tree.png")
var __waterSprite = preload("res://assets/water.png")

var __sprites
var __mouse_in = false


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
	self.connect("mouse_entered", self, "_on_StaticBody2D_mouse_entered")
	self.connect("mouse_exited", self, "_on_StaticBody2D_mouse_exited")
	
func _on_StaticBody2D_mouse_entered():
	__mouse_in = true
	
func _on_StaticBody2D_mouse_exited():
	__mouse_in = false
	
func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		if __mouse_in:
			$HighlightSprite.show()
		else:
			$HighlightSprite.hide()
			
