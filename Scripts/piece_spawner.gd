extends Node

@export_enum("I", "O", "T", "J", "L", "S", "Z") var tetromino_type: int
@onready var board = $"../Board" as Board
@onready var ui: CanvasLayer = $"../UI" as UI
var is_game_over = false

var current_tetromino
var next_tetromino
var tetromino_bag: Array = []

func _ready():
	refill_bag()
	current_tetromino = get_next_tetromino()
	next_tetromino = get_next_tetromino()
	board.spawn_tetromino(current_tetromino, false, null)
	board.spawn_tetromino(next_tetromino, true, Vector2(100, 50))
	board.tetromino_locked.connect(on_tetromino_locked)
	board.game_over.connect(on_game_over)
	
func refill_bag():
	tetromino_bag.clear()
	tetromino_bag = Shared.Tetromino.values().map(func(v): return int(v))
	tetromino_bag.shuffle()

func get_next_tetromino() -> int:
	if tetromino_bag.is_empty():
		refill_bag()
	return tetromino_bag.pop_front()
	
func on_tetromino_locked():
	if is_game_over:
		return
	current_tetromino = next_tetromino
	next_tetromino = get_next_tetromino()
	board.spawn_tetromino(current_tetromino, false, null)
	board.spawn_tetromino(next_tetromino, true, Vector2(100, 50))

func on_game_over():
	is_game_over = true
	ui.show_game_over()
