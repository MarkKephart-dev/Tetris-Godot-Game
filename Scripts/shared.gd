extends Node

enum Tetromino { I, O, T, J, L, S, Z }

# Centralized cell layout
const cells := {
	"I": [Vector2(-1, 0), Vector2(0, 0), Vector2(1, 0), Vector2(2, 0)],
	"J": [Vector2(-1, 1), Vector2(-1, 0), Vector2(0,0), Vector2(1, 0)],
	"L": [Vector2(1,1), Vector2(-1, 0), Vector2(0,0), Vector2(1,0)],
	"O": [Vector2(0,1), Vector2(1,1), Vector2(0,0), Vector2(1,0)],
	"S": [Vector2(0,1), Vector2(1,1), Vector2(-1, 0), Vector2(0,0)],
	"T": [Vector2(0,1), Vector2(-1, 0), Vector2(0,0), Vector2(1,0)],
	"Z": [Vector2(-1, 1), Vector2(0, 1), Vector2(0,0), Vector2(1, 0)]
}

func get_type_name(index: int) -> String:
	return Tetromino.keys()[index]

func get_type_enum(tetromino_name: String) -> int:
	return Tetromino[tetromino_name]

func get_cells(name: String) -> Array:
	return cells.get(name, [])

func get_piece_data(name: String) -> Resource:
	return data.get(name)
	
var wall_kicks_i = [
	[Vector2(0,0), Vector2(-2,0), Vector2(1,0), Vector2(-2,-1), Vector2(1,2)],
	[Vector2(0,0), Vector2(2,0), Vector2(-1, 0), Vector2(2,1), Vector2(-1, -2)],
	[Vector2(0,0), Vector2(-1, 0), Vector2(2,0), Vector2(-1,2), Vector2(2, -1)],
	[Vector2(0,0), Vector2(1,0), Vector2(-2, 0), Vector2(1, -2), Vector2(-2, 1)],
	[Vector2(0,0), Vector2(2,0), Vector2(-1, 0), Vector2(2,1), Vector2(-1, -2)],
	[Vector2(0,0), Vector2(-2,0), Vector2(1, 0), Vector2(-2, -1), Vector2(1, 2)],
	[Vector2(0,0), Vector2(1,0), Vector2(-2,0), Vector2(1, -2), Vector2(-2,1)],
	[Vector2(0,0), Vector2(-1, 0), Vector2(2, 0), Vector2(-1,2), Vector2(2, -1)]
]

var wall_kicks_jlostz = [
	[Vector2(0,0), Vector2(-1,0), Vector2(-1,1), Vector2(0,-2), Vector2(-1, -2)],
	[Vector2(0,0), Vector2(1,0), Vector2(1, -1), Vector2(0,2), Vector2(1, 2)],
	[Vector2(0,0), Vector2(1, 0), Vector2(1,-1), Vector2(0,2), Vector2(1, 2)],
	[Vector2(0,0), Vector2(-1,0), Vector2(-1, 1), Vector2(0, -2), Vector2(-1, -2)],
	[Vector2(0,0), Vector2(1,0), Vector2(1, 1), Vector2(0,-2), Vector2(1, -2)],
	[Vector2(0,0), Vector2(-1,0), Vector2(-1, -1), Vector2(0, 2), Vector2(-1, 2)],
	[Vector2(0,0), Vector2(-1,0), Vector2(-1,-1), Vector2(0, 2), Vector2(-1, 2)],
	[Vector2(0,0), Vector2(1, 0), Vector2(1, 1), Vector2(0,-2), Vector2(1, -2)]
]

# Preloaded piece resources (textures, spawn pos, etc.)
var data := {
	"I": preload("res://Resources/i_piece_data.tres"),
	"J": preload("res://Resources/j_piece_data.tres"),
	"L": preload("res://Resources/l_piece_data.tres"),
	"O": preload("res://Resources/o_piece_data.tres"),
	"S": preload("res://Resources/s_piece_data.tres"),
	"T": preload("res://Resources/t_piece_data.tres"),
	"Z": preload("res://Resources/z_piece_data.tres")
}

var clockwise_rotation_matrix = [Vector2(0, -1), Vector2(1, 0)]
var counter_clockwise_rotation_matrix = [Vector2(0,1), Vector2(-1, 0)]
