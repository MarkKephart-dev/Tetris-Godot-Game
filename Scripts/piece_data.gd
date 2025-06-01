extends Resource

class_name PieceData

const TETROMINO_NAMES = ["I", "O", "T", "J", "L", "S", "Z"]

@export var piece_texture: Texture
@export_enum("I", "O", "T", "J", "L", "S", "Z") var tetromino_type: int
@export var spawn_position: Vector2

# Access tetromino key and enum value from shared.gd
func get_tetromino_key() -> String:
	return Shared.get_type_name(tetromino_type)

func get_tetromino_enum():
	return Shared.Tetromino[get_tetromino_key()]
