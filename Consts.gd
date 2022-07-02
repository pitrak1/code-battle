extends Node2D

enum {HIGH, LOW, MIDDLE, ROCK, TREE, WATER}

const TILE_STRINGS = [
	'HIGH',
	'LOW',
	'MIDDLE',
	'ROCK',
	'TREE',
	'WATER'
]

const TILE_SPRITE_OFFSETS = [
	-30,
	0,
	-10,
	0,
	0,
	0,
]
const TILE_HIGHLIGHT_OFFSET = -18

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

enum CHARACTERS {PALADIN, PRIEST, ROGUE, WARRIOR}

const CHARACTER_DATA = [
	{
		'sprite': 'res://assets/paladin.png'
	},
	{
		'sprite': 'res://assets/priest.png'
	},
	{
		'sprite': 'res://assets/rogue.png'
	},
	{
		'sprite': 'res://assets/warrior.png'
	}
]

# INTERPRETER CONSTS

const QUOTES = ['\'', '"']
const WHITESPACE = ['\t', '\n', ' ']
const DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
const LETTERS = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
const KEYWORDS = ['var', 'if', 'while', 'function', 'return', 'import', 'export', 'class']
const BUILTINS = ['print', 'highlight', 'get_tile_info', 'get_actor_by_name', 'get_actor_by_grid_position', 'get_actors', 'get_player_actors', 'get_enemy_actors']
const SEPARATORS = ['(', ')', '{', '}', ',', '[', ']', ':']
const OPERATORS = ['==', '<', '>', '+', '*']
const BOOLEANS = ['true', 'false']

enum TOKEN_TYPES {
	NUMBER,
	STRING,
	BOOLEAN,
	KEYWORD,
	BUILTIN,
	IDENTIFIER,
	ASSIGNMENT,
	SEPARATOR,
	OPERATOR,
	SEMICOLON,
	WHITESPACE,
	COMMENT,
	ERROR
}

const TOKEN_TYPE_STRINGS = [
	'NUMBER',
	'STRING',
	'BOOLEAN',
	'KEYWORD',
	'BUILTIN',
	'IDENTIFIER',
	'ASSIGNMENT',
	'SEPARATOR',
	'OPERATOR',
	'SEMICOLON',
	'WHITESPACE',
	'COMMENT',
	'ERROR'
]

enum INSTRUCTION_TYPES {
	ASSIGNMENT,
	DECLARATION,
	BUILTIN,
	OPERATION,
	VARIABLE,
	NUMBER,
	STRING,
	BOOLEAN,
	IF,
	WHILE,
	ARRAY,
	INDEX,
	OBJECT,
	IMPORT,
	FUNCTION,
	CALL,
	RETURN,
	CLASS
}

const INSTRUCTION_TYPE_STRINGS = [
	'ASSIGNMENT',
	'DECLARATION',
	'BUILTIN',
	'OPERATION',
	'VARIABLE',
	'NUMBER',
	'STRING',
	'BOOLEAN',
	'IF',
	'WHILE',
	'ARRAY',
	'INDEX',
	'OBJECT',
	'IMPORT',
	'FUNCTION',
	'CALL',
	'RETURN', 
	'CLASS'
]
