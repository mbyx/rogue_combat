@tool extends Node2D

@export var Map: BattleMap
@export var UILayer: TileMapLayer
@export var Camera: Camera2D

@onready var TILE_SIZE: Vector2i = UILayer.tile_set.tile_size
const MOVEMENT_SPEED: float = 250.0

func handle_input(delta: float) -> void:
	var dir_x = Input.get_action_strength("Cursor_Right") - Input.get_action_strength("Cursor_Left")
	var dir_y = Input.get_action_strength("Cursor_Down") - Input.get_action_strength("Cursor_Up")

	var target_position = position + Vector2(dir_x * TILE_SIZE.x, dir_y * TILE_SIZE.y)

	if position != target_position:
		position = position.move_toward(target_position, delta * MOVEMENT_SPEED)

func _ready() -> void:
	position = position.snapped(TILE_SIZE)

func _process(delta: float) -> void:
	UILayer.set_cell(UILayer.local_to_map(position), 1)
	handle_input(delta)
	UILayer.set_cell(UILayer.local_to_map(position), 1, Vector2(3, 2))
