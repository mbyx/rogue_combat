@tool extends Node2D
class_name Cursor

## The in-game cursor controlled by the player.
##
## This node is drawn via the TileMapLayer however possesses it's own
## position that is used to lerp between cells at different intervals.

@export_group("Dependencies")
@export var Map: BattleMap
@export var UILayer: TileMapLayer
@export var Camera: Camera2D

@export_group("Attributes")
@export var CURSOR_DEADZONE: float = 0.25
@export var MOVEMENT_SPEED: float = 150.0
@export var CURSOR_COORD: Vector2i = Vector2i(3, 2)
@export var CURSOR_SOURCE_ID: int = 1

@onready var TILE_SIZE: Vector2 = UILayer.tile_set.tile_size

func handle_input(delta: float) -> void:
	var direction = Input.get_vector("Cursor_Left", "Cursor_Right", "Cursor_Up", "Cursor_Down", CURSOR_DEADZONE)
	var target_position = position + Vector2(direction.x * TILE_SIZE.x, direction.y * TILE_SIZE.y)

	if position != target_position:
		position = position.move_toward(target_position, delta * MOVEMENT_SPEED)
		position = position.clamp(
			Vector2(Camera.limit_left, Camera.limit_top),
			Vector2(Camera.limit_right - TILE_SIZE.x, Camera.limit_bottom - TILE_SIZE.y)
		)
		Camera._move_deadzone_with_follow_target()

	if Input.is_action_pressed("Move_To_Map_Center"):
		position = Vector2.ZERO
		Camera._move_deadzone_with_follow_target()
		Camera.position = UILayer.map_to_local(UILayer.local_to_map(position)) - TILE_SIZE / 2


func _ready() -> void:
	# Start out with an integer multiple of tile size to prevent bugs.
	position = position.snapped(TILE_SIZE)

func _process(delta: float) -> void:
	# Unset the cell at that position before calculating new position and resetting it.
	# TODO: Instead of having a UI Layer simply make the UI part of the cell element.
	# maybe via scene collections.
	UILayer.set_cell(UILayer.local_to_map(position), CURSOR_SOURCE_ID)
	handle_input(delta)
	UILayer.set_cell(UILayer.local_to_map(position), CURSOR_SOURCE_ID, CURSOR_COORD)
	print(Map.get_terrain_type_at(position))
