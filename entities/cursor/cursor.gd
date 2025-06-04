@tool extends Node2D
class_name Cursor

## The in-game cursor controlled by the player.
##
## This node is drawn via the TileMapLayer however possesses it's own
## position that is used to lerp between cells at different intervals.

@export_group("Dependencies")
@export var Map: BattleMap
@export var UILayer: TileMapLayer
@export var ArrowLayer: TileMapLayer
@export var UnitLayer: TileMapLayer
@export var Camera: Camera2D
@export var Player: AnimationPlayer

@export_group("Attributes")
@export var CURSOR_DEADZONE: float = 0.25
@export var MOVEMENT_SPEED: float = 150.0
@export var CURSOR_COORD: Vector2i = Vector2i(3, 2)
@export var CURSOR_SOURCE_ID: int = 1

@onready var TILE_SIZE: Vector2 = UILayer.tile_set.tile_size

var astar: AStarGrid2D

class Selection:
	var position: Vector2i = Vector2.ZERO
	var is_selected: bool = false

var selection: Selection = Selection.new()
var path = []

func handle_input(delta: float) -> void:
	var direction = Input.get_vector("Cursor_Left", "Cursor_Right", "Cursor_Up", "Cursor_Down", CURSOR_DEADZONE)
	var target_position = position + Vector2(direction.x * TILE_SIZE.x, direction.y * TILE_SIZE.y)

	if position != target_position:
		if not selection.is_selected:
			position = position.move_toward(target_position, delta * MOVEMENT_SPEED)
			position = position.clamp(
				Vector2(Camera.limit_left, Camera.limit_top),
				Vector2(Camera.limit_right - TILE_SIZE.x, Camera.limit_bottom - TILE_SIZE.y)
			)
			Camera._move_deadzone_with_follow_target()
			$AnimationTree.set("parameters/conditions/idle", false);
			$AnimationTree.set("parameters/conditions/in_motion", true);
		elif Vector2i(UILayer.map_to_local(UILayer.local_to_map(target_position))) in generate_unit_square(selection.position):
			position = position.move_toward(target_position, delta * MOVEMENT_SPEED)
			position = position.clamp(
				Vector2(Camera.limit_left, Camera.limit_top),
				Vector2(Camera.limit_right - TILE_SIZE.x, Camera.limit_bottom - TILE_SIZE.y)
			)
			Camera._move_deadzone_with_follow_target()
			$AnimationTree.set("parameters/conditions/idle", false);
			$AnimationTree.set("parameters/conditions/in_motion", true);

	else:
		$AnimationTree.set("parameters/conditions/in_motion", false);
		$AnimationTree.set("parameters/conditions/idle", true);

	if selection.is_selected:
		var origin_tile = Vector2((selection.position.x - 8) / TILE_SIZE.x, (selection.position.y - 8) / TILE_SIZE.y)
		var current_tile = Vector2((UILayer.map_to_local(UILayer.local_to_map(position)).x - 8) / TILE_SIZE.x, (UILayer.map_to_local(UILayer.local_to_map(position)).y - 8)/TILE_SIZE.y)
		# necessary to prevent path from displaying outside mvoement square
		# BUG: it prevents display of that path, but doesn't fix it, so path looks broken
		var area := generate_unit_square(selection.position)
		
		astar.set_point_solid(origin_tile, false)
		astar.set_point_solid(current_tile, false)

		for square in area:
			astar.set_point_solid(Vector2i(square.x - 8, square.y - 8) / TILE_SIZE.x, false)
		path = Array(astar.get_point_path(origin_tile, current_tile))
		
		for i in range(path.size()):
			path[i] = path[i] / TILE_SIZE.x;
		ArrowLayer.clear()
		ArrowLayer.set_cells_terrain_path(path, 0, 0)
		#ArrowLayer.set_cell(path[0], 1, Vector2i(4, 1))

	if Input.is_action_pressed("Move_To_Map_Center"):
		position = Vector2.ZERO
		Camera._move_deadzone_with_follow_target()
		Camera.position = UILayer.map_to_local(UILayer.local_to_map(position)) - TILE_SIZE / 2

	if Input.is_action_just_pressed("Confirm"):
		if Map.get_unit_type_at(position) != Enums.Unit.Type.Null:
			for v in generate_movement_square(selection.position, 3):
				UILayer.set_cell(UILayer.local_to_map(v), -1, Vector2i(-1, -1))
			selection.position = UILayer.map_to_local(UILayer.local_to_map(position))
			selection.is_selected = true
		elif selection.is_selected:
			var pos = UILayer.map_to_local(UILayer.local_to_map(position))
			for v in generate_movement_square(selection.position, 3):
				if v.x == pos.x and v.y == pos.y:
					var coords = UnitLayer.get_cell_atlas_coords(UnitLayer.local_to_map(selection.position))
					UnitLayer.set_cell(UnitLayer.local_to_map(v), 0, coords)
					Map.AttributeLayer.set_cell(Map.AttributeLayer.local_to_map(v), 1, Map.AttributeLayer.get_cell_atlas_coords(Map.AttributeLayer.local_to_map(selection.position)))
					Map.AttributeLayer.set_cell(Map.AttributeLayer.local_to_map(selection.position), -1, Vector2i(-1, -1))
					UnitLayer.set_cell(UnitLayer.local_to_map(selection.position), -1, Vector2i(-1, -1))
					selection.is_selected = false
				UILayer.set_cell(UILayer.local_to_map(v), -1, Vector2i(-1, -1))
	
	if Input.is_action_pressed("Cancel"):
		selection.is_selected = false

func generate_movement_square(center: Vector2i, size: int) -> Array[Vector2i]:
	var arr: Array[Vector2i] = []
	for dx in range(-size, size + 1):
		for dy in range(-size + abs(dx), size - abs(dx) + 1):
			arr.append(center + Vector2i(dx * TILE_SIZE.x, dy * TILE_SIZE.y))
	return arr

func generate_unit_square(center: Vector2i) -> Array[Vector2i]:
	var arr: Array[Vector2i] = []

	var unit_type = Map.get_unit_type_at(selection.position)
	var unit_data = Map.get_unit_data_at(selection.position)
	for v in generate_movement_square(selection.position, 3):
		var terrain: Resource = Map.get_terrain_data_at(v)
		if unit_type != - 1 and terrain.movement[unit_type] != -1:
			arr.push_back(v)
	
	return arr

func _ready() -> void:
	# Start out with an integer multiple of tile size to prevent bugs.
	#$Sprite2D.global_position = $Sprite2D.global_position.snapped(TILE_SIZE / 2)
	Player.play("idle")
	astar = AStarGrid2D.new()
	astar.region = Rect2i(-2048, -2048, 4096, 4096)
	astar.cell_size = TILE_SIZE
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()
	astar.fill_solid_region(astar.region, true)
	

func _process(delta: float) -> void:
	$Sprite2D.global_position = UILayer.map_to_local(UILayer.local_to_map(global_position))
	handle_input(delta)
 # https://forum.godotengine.org/t/how-do-you-use-autotiling-in-code-in-godot-4/1587/2
	if selection.is_selected:
		for v in generate_movement_square(selection.position, 3):
			var terrain: Resource = Map.get_terrain_data_at(v)
			var unit_type = Map.get_unit_type_at(selection.position)
			if unit_type != - 1 and terrain.movement[unit_type] != -1:
				pass
				UILayer.set_cell(UILayer.local_to_map(v), 1, Vector2i(3, 3))
	else:
		ArrowLayer.clear()
		for v in generate_movement_square(selection.position, 3):
			var terrain: Resource = Map.get_terrain_data_at(v)
			var unit_type = Map.get_unit_type_at(selection.position)
			if unit_type != - 1 and terrain.movement[unit_type] != -1:
				UILayer.set_cell(UILayer.local_to_map(v), -1, Vector2i(-1, -1))
