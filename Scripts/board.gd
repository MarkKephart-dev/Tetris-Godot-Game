extends Node

class_name Board

signal tetromino_locked
signal game_over

const ROW_COUNT = 20
const COLUMN_COUNT = 10
var next_tetromino
var tetrominos: Array[Tetromino] = []
@export var tetromino_scene: PackedScene
@onready var panel_container: PanelContainer = $"../PanelContainer"
@onready var line_scene = preload("res://Scenes/line.tscn")

func spawn_tetromino(type: int, is_next_piece, spawn_position):
	var name = Shared.get_type_name(type)
	var tetromino_data = Shared.data[name]
	var tetromino = tetromino_scene.instantiate() as Tetromino
	
	tetromino.tetromino_data = tetromino_data
	tetromino.is_next_piece = is_next_piece
	
	if is_next_piece == false:
		var other_pieces = get_all_pieces()
		tetromino.position = tetromino_data.spawn_position
		tetromino.other_tetromino_pieces = other_pieces
		tetromino.lock_tetromino.connect(on_tetromino_locked)
		add_child(tetromino)
	else:
		tetromino.scale = Vector2(0.5, 0.5)
		panel_container.add_child(tetromino)
		tetromino.set_position(spawn_position)
		next_tetromino = tetromino
		
func on_tetromino_locked(tetromino: Tetromino):
	next_tetromino.queue_free()
	tetrominos.append(tetromino)
	add_tetromino_to_lines(tetromino)
	remove_full_lines()
	tetromino_locked.emit()
	check_game_over()
	
func check_game_over():
	for piece in get_all_pieces():
		var y_location = piece.global_position.y
		if y_location == -456:
			print("should be game over.")
			game_over.emit()
		
func add_tetromino_to_lines(tetromino: Tetromino):
	var tetromino_pieces = tetromino.get_children().filter(func (c): return c is Piece)
	
	for piece in tetromino_pieces:
		var y_position = piece.global_position.y
		var line_for_piece_exists = false
		
		for line in get_lines():
			if line.global_position.y == y_position:
				piece.reparent(line)
				line_for_piece_exists = true
				
		if !line_for_piece_exists:
			var piece_line = line_scene.instantiate() as Line
			piece_line.global_position = Vector2(0, y_position)
			add_child(piece_line)
			piece.reparent(piece_line)
		
func get_lines():
	return get_children().filter(func (c): return c is Line)

func remove_full_lines():
	for line in get_lines():
		if line.is_line_full(COLUMN_COUNT):
			move_lines_down(line.global_position.y)
			line.free()

func move_lines_down(y_position):
	for line in get_lines():
		if line.global_position.y < y_position:
			line.global_position.y += 48

func get_all_pieces():
	var pieces = []
	for line in get_lines():
		pieces.append_array(line.get_children())
	return pieces
