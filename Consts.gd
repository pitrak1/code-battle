extends Node2D

enum {HIGH, LOW, MIDDLE, ROCK, TREE, WATER}

const TILE_DIAMETER = 55
const TILE_ROW_HEIGHT = 40

const START_POSITION = Vector2(330, 110)

const LEVEL_1 = [
	[null, 	null, 	HIGH, 	MIDDLE, 	LOW, 	LOW, 	null, 	null, 	null],
	[null, 	ROCK, 	HIGH, 	LOW, 	LOW, 	LOW, 	LOW, 	null, 	null],
	[HIGH, 	HIGH, 	ROCK, 	LOW, 	WATER, 	TREE, 	LOW, 	LOW, 	null],
	[MIDDLE,	LOW, 	LOW, 	LOW, 	LOW, 	WATER, 	TREE, 	LOW, 	LOW],
	[LOW, 	LOW, 	WATER, 	LOW, 	TREE, 	LOW, 	WATER, 	LOW, 	LOW],
	[LOW, 	LOW, 	TREE, 	WATER, 	LOW, 	LOW, 	LOW, 	LOW, 	MIDDLE],
	[null, 	LOW, 	LOW, 	TREE, 	WATER, 	LOW, 	ROCK, 	HIGH, 	HIGH],
	[null, 	null, 	LOW, 	LOW, 	LOW, 	LOW, 	HIGH, 	ROCK, 	null],
	[null, 	null, 	null, 	LOW, 	LOW, 	MIDDLE, 	HIGH, 	null, 	null]
]

const LEVEL_2 = [
	[LOW]
]
