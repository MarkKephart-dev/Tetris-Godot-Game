extends Node2D

class_name Tetromino

signal lock_tetromino(tetromino: Tetromino)

var bounds = {
	"min_x": -216,
	"max_x": 216,
	"max_y": 457
}

var rotation_index = 0
var wall_kicks
var tetromino_data
var tetromino_cells
var is_next_piece
var is_locked = false
var pieces = []
var other_tetromino_pieces = []
var ghost_tetromino

# Define actions
var repeat_action = ""
var repeat_delay = 0.15  # Delay before repeat starts
var repeat_rate = 0.05   # Speed of repeated input

@onready var timer: Timer = $MoveDownTimer
@onready var input_timer: Timer = $InputTimer
@onready var piece_scene = preload("res://Scenes/piece.tscn")
@onready var ghost_tetromino_scene = preload("res://Scenes/ghost_tetromino.tscn")

func _ready():
	tetromino_cells = Shared.cells[Shared.get_type_name(tetromino_data.tetromino_type)].duplicate()
	if not input_timer.timeout.is_connected(_on_input_timer_timeout):
		input_timer.timeout.connect(_on_input_timer_timeout)
	
	for cell in tetromino_cells:
		var piece = piece_scene.instantiate() as Piece
		pieces.append(piece)
		add_child(piece)
		piece.set_texture(tetromino_data.piece_texture)
		piece.position = cell * piece.get_size()
		
	if is_next_piece == false:
		position = tetromino_data.spawn_position
		wall_kicks = Shared.wall_kicks_i if tetromino_data.tetromino_type == Shared.Tetromino.I else Shared.wall_kicks_jlostz
		ghost_tetromino = ghost_tetromino_scene.instantiate() as GhostTetromino
		ghost_tetromino.tetromino_data = tetromino_data
		get_tree().root.add_child.call_deferred(ghost_tetromino)
		hard_drop_ghost.call_deferred()
	else:
		timer.stop()
		set_process(false)
		set_process_input(false)

func _process(_delta):
	if is_locked:
		return
		
	if Input.is_action_just_pressed("left"):
		perform_move("left")
		start_repeat("left")
	elif Input.is_action_just_pressed("right"):
		perform_move("right")
		start_repeat("right")
	elif Input.is_action_just_pressed("down"):
		perform_move("down")
		start_repeat("down")
	
	# Stop repeating when key released
	if repeat_action != "" and Input.is_action_just_released(repeat_action):
		stop_repeat()
		
func start_repeat(action: String):
	repeat_action = action
	input_timer.wait_time = repeat_delay
	input_timer.start()

func stop_repeat():
	repeat_action = ""
	input_timer.stop()
 
func perform_move(action: String):
	match action:
		"left":
			move(Vector2.LEFT)
		"right":
			move(Vector2.RIGHT)
		"down":
			move(Vector2.DOWN)
			
func hard_drop_ghost():
	var final_hard_drop_position
	var ghost_position_update = calculate_global_position(Vector2.DOWN, global_position)
	
	while ghost_position_update != null:
		ghost_position_update = calculate_global_position(Vector2.DOWN, ghost_position_update)
		if ghost_position_update != null:
			final_hard_drop_position = ghost_position_update
			
		if final_hard_drop_position != null:
			var children = get_children().filter(func (c): return c is Piece)
			
			var pieces_position = []
			
			for i in children.size():
				var piece_position = children[i].position
				pieces_position.append(piece_position)

			ghost_tetromino.set_ghost_tetromino(final_hard_drop_position, pieces_position)

	return final_hard_drop_position

func _input(_event):
	if is_locked:
		return
		
	if Input.is_action_just_pressed("hard_drop"):
		hard_drop()
	elif Input.is_action_just_pressed("rotate_left"):
		rotate_tetromino(-1)
	elif Input.is_action_just_pressed("rotate_right"):
		rotate_tetromino(1)

func move(direction: Vector2) -> bool:
	var new_position = calculate_global_position(direction, global_position)
	if new_position:
		global_position = new_position
		if direction != Vector2.DOWN:
			hard_drop_ghost.call_deferred()
		return true
	return false
	
func calculate_global_position(direction: Vector2, starting_global_position: Vector2):
	if is_colliding_with_other_tetrominos(direction, starting_global_position):
		return null
	if !is_within_game_bounds(direction, starting_global_position):
		return null
	return starting_global_position + direction * pieces[0].get_size().x

func is_within_game_bounds(direction: Vector2, starting_global_position: Vector2) -> bool:
	for piece in pieces:
		var new_position = piece.position + starting_global_position + direction * piece.get_size()
		if new_position.x < bounds.get("min_x") || new_position.x > bounds.get("max_x") || new_position.y >= bounds.get("max_y"):
			return false
	return true

func is_colliding_with_other_tetrominos(direction: Vector2, starting_global_position: Vector2):
	for tetromino_piece in other_tetromino_pieces:
		for piece in pieces:
			if starting_global_position + piece.position + direction * piece.get_size().x == tetromino_piece.global_position:
				return true
	return false

func rotate_tetromino(direction: int):
	var original_rotation_index = rotation_index
	if tetromino_data.tetromino_type == Shared.Tetromino.O:
		return
		
	apply_rotation(direction)
	
	rotation_index = wrap(rotation_index + direction, 0, 4)
	
	if !test_wall_kicks(rotation_index, direction):
		rotation_index = original_rotation_index
		apply_rotation(-direction)
		
	hard_drop_ghost.call_deferred()

@warning_ignore("shadowed_variable")
func test_wall_kicks(rotation_index: int, rotation_direction: int):
	var wall_kick_index = get_wall_kick_index(rotation_index, rotation_direction)
	
	for i in wall_kicks[0].size():
		var translation = wall_kicks[wall_kick_index][i]
		if move(translation):
			return true
	return false

@warning_ignore("shadowed_variable")
func get_wall_kick_index(rotation_index: int, rotation_direction):
	var wall_kick_index = rotation_index * 2
	if rotation_direction < 0:
		wall_kick_index -= 1
		
	return wrap(wall_kick_index, 0 , wall_kicks.size())

func apply_rotation(direction: int):
	var rotation_matrix = Shared.clockwise_rotation_matrix if direction == 1 else Shared.counter_clockwise_rotation_matrix
	
	for i in tetromino_cells.size():
		var cell = tetromino_cells[i]
		
		var rotated = rotation_matrix[0] * cell.x + rotation_matrix[1] * cell.y
		tetromino_cells[i] = Vector2(round(rotated.x), round(rotated.y))
	
	for i in pieces.size():
		var piece = pieces[i]
		piece.position = tetromino_cells[i] * piece.get_size()

func hard_drop():
	while(move(Vector2.DOWN)):
		continue
	lock()

func lock():
	is_locked = true
	timer.stop()
	input_timer.stop()
	stop_repeat()
	lock_tetromino.emit(self)
	set_process_input(false)
	ghost_tetromino.queue_free()

func _on_timer_timeout() -> void:
	var should_lock = !move(Vector2.DOWN)
	if should_lock:
		lock()

func _on_input_timer_timeout() -> void:
	if is_locked || !Input.is_action_pressed(repeat_action):
		stop_repeat()
		return
	
	perform_move(repeat_action)
	input_timer.wait_time = repeat_rate  # After first delay, switch to faster repeat
