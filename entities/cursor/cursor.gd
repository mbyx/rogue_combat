@tool extends Node2D

@export var Map: BattleMap
@export var UILayer: TileMapLayer
@export var Camera: PhantomCamera2D

@onready var TILE_SIZE: Vector2i = UILayer.tile_set.tile_size
const MOVEMENT_SPEED: float = 200.0

func handle_input(delta: float) -> void:
	var dir_x = Input.get_action_strength("Cursor_Right") - Input.get_action_strength("Cursor_Left")
	var dir_y = Input.get_action_strength("Cursor_Down") - Input.get_action_strength("Cursor_Up")

	var target_position = position + Vector2(dir_x * TILE_SIZE.x, dir_y * TILE_SIZE.y)

	if position != target_position:
		position = position.move_toward(target_position, delta * MOVEMENT_SPEED)

func _ready() -> void:
	position = position.snapped(TILE_SIZE)

func _process(delta: float) -> void:
	position = position.clamp(
		Vector2(Camera.limit_left, Camera.limit_top),
		Vector2(Camera.limit_right - TILE_SIZE.x, Camera.limit_bottom - TILE_SIZE.y)
	)

	UILayer.set_cell(UILayer.local_to_map(position), 1)
	handle_input(delta)

	position = position.clamp(
		Vector2(Camera.limit_left, Camera.limit_top),
		Vector2(Camera.limit_right - TILE_SIZE.x, Camera.limit_bottom - TILE_SIZE.y)
	)
	UILayer.set_cell(UILayer.local_to_map(position), 1, Vector2(3, 2))
	
	print(position)
