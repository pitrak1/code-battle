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

# INTERPRETER CONSTS

const QUOTES = ['\'', '"']
const WHITESPACE = ['\t', '\n', ' ']
const DIGITS = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
const LETTERS = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
const KEYWORDS = ['var', 'print', 'highlight', 'if']
const SEPARATORS = ['(', ')', '{', '}', ',']
const MATHEMATICAL_OPERATORS = ['+', '*']
const BOOLEAN_OPERATORS = ['==']

enum TOKEN_TYPES {
	NUMBER,
	STRING,
	BOOLEAN,
	KEYWORD,
	IDENTIFIER,
	ASSIGNMENT,
	SEPARATOR, 
	OPERATOR, 
	SEMICOLON
}

const TOKEN_TYPE_STRINGS = [
	'NUMBER',
	'STRING',
	'BOOLEAN',
	'KEYWORD',
	'IDENTIFIER',
	'ASSIGNMENT',
	'SEPARATOR',
	'OPERATOR',
	'SEMICOLON'
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
	IF
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
	'IF'
]
