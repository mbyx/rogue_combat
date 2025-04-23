extends Node2D
class_name BattleMap


## Represents the in-game 'map' on which terrain, units, buildings, and UI
## elements are visible. Each layer is made such that they easily stack on top
## of each other in a sensible manner.
## 
## Terrain Data must be provided in the same order as the Terrain Type enum
## which will specify in the form of a resource, the properties associated with
## each terrain.
## 
## The terrain type is calculated by prioritising the terrain type of
## the foreground.

@export_group("Dependencies")
@export var TerrainBGLayer: TileMapLayer
@export var TerrainFGLayer: TileMapLayer
@export var BuildingLayer: TileMapLayer
@export var UnitLayer: TileMapLayer
@export var AttributeLayer: TileMapLayer
@export var UILayer: TileMapLayer

# NOTE: Terrains that can only be specified via the Foreground or above must always
# have a larger integer value than the largest terrain type specified via
# the Background.
# TODO: Fix tileset assets to actually use cut down tiles instead of master asset list.
enum TerrainType {
	NULL      = -1,
	PLAINS    = 0,
	WATER     = 1,
	ROAD      = 2,
	MOUNTAIN  = 3,
	FOREST    = 4,
	BUILDING  = 5,
}

enum UnitType {
	NULL      = -1,
	MECH = 0,
	INFANTRY = 1,
	SUBMARINE = 2,
	CRUISER = 3,
	LANDER = 4,
	TRANSPORT_COPTER = 5,
	BATTLE_COPTER = 6,
	BOMBER = 7,
	ANTI_AIR = 8,
	TANK = 9,
	APC = 10,
	CARGO_TRUCK_FULL = 11,
	CARGO_TRUCK_EMPTY = 12
}

enum FlagColor {
	NULL   = -1,
	GRAY   = 0,
	GREEN  = 1,
	BLUE   = 2,
	RED    = 3,
	ORANGE = 4
}

const VALUE_TO_TERRAIN: Dictionary = { 
	-1: TerrainType.NULL,
										0 : TerrainType.PLAINS, 1 : TerrainType.WATER,
									   2 : TerrainType.ROAD, 3 : TerrainType.MOUNTAIN,
									   4 : TerrainType.FOREST, 5 : TerrainType.BUILDING }

const VALUE_TO_COLOR: Dictionary = {
	-1: FlagColor.NULL,
	0: FlagColor.GRAY, 1: FlagColor.GREEN,
	2: FlagColor.BLUE, 3: FlagColor.RED, 4: FlagColor.ORANGE
}

const VALUE_TO_UNIT: Dictionary = {
	-1: UnitType.NULL,
	0: UnitType.MECH, 1: UnitType.INFANTRY,
	2: UnitType.SUBMARINE, 3: UnitType.CRUISER,
	4: UnitType.LANDER, 5: UnitType.TRANSPORT_COPTER,
	6: UnitType.BATTLE_COPTER, 7: UnitType.BOMBER,
	8: UnitType.ANTI_AIR, 9: UnitType.TANK,
	10: UnitType.APC, 11: UnitType.CARGO_TRUCK_FULL,
	12: UnitType.CARGO_TRUCK_EMPTY,
}

@export_group("Attributes")
## A list of resources whose indices correspond to the terrain type.
@export var terrain_data: Array[Resource]
@export var unit_data: Array[Resource]

## Get the terrain type of the tile at that position.
##
## The method will check the terrain type of both the foreground and background
## layers, but return only one, prioritising the foreground layer.
## NOTE: This method takes the position as the argument.
func get_terrain_type_at(pos: Vector2) -> TerrainType:
	var bg_type: int = -1
	var fg_type: int = -1
	var building_type: int = -1

	var bg_data: TileData = TerrainBGLayer \
		.get_cell_tile_data(TerrainBGLayer.local_to_map(pos))
	if bg_data:
		bg_type = bg_data.get_custom_data("Terrain Type")

	var fg_data: TileData = TerrainFGLayer \
		.get_cell_tile_data(TerrainFGLayer.local_to_map(pos))
	if fg_data:
		bg_type = fg_data.get_custom_data("Terrain Type")

	var building_data: TileData = BuildingLayer \
		.get_cell_tile_data(BuildingLayer.local_to_map(pos))
	if building_data:
		building_type = building_data.get_custom_data("Terrain Type")

	# Assuming the foreground terrains start after the background terrains.
	return VALUE_TO_TERRAIN[max(bg_type, fg_type, building_type)]

func get_flag_color_at(pos: Vector2) -> FlagColor:
	var unit_color: int = -1

	var layer_data: TileData = UnitLayer \
		.get_cell_tile_data(UnitLayer.local_to_map(pos))
	if layer_data:
		unit_color = layer_data.get_custom_data("Flag Color")

	return VALUE_TO_COLOR[unit_color]

func get_unit_type_at(pos: Vector2) -> UnitType:
	var unit_type: int = -1

	var layer_data: TileData = UnitLayer \
		.get_cell_tile_data(UnitLayer.local_to_map(pos))
	if layer_data:
		unit_type = layer_data.get_custom_data("Unit Type")

	return VALUE_TO_UNIT[unit_type]

## Get the terrain data of the tile at that position.
##
## The terrain data represents the properties of the terrain, such as how much
## cover it provides, height, etc.
##
## Returns the resource that represents the terrain data or null if it can't
## figure out the terrain type.
func get_terrain_data_at(coords: Vector2i) -> Resource:
	var type: TerrainType = get_terrain_type_at(coords)
	if terrain_data.size() < type:
		return null
	return terrain_data[type]

func get_unit_data_at(coords: Vector2i) -> Resource:
	var type: UnitType = get_unit_type_at(coords)
	if unit_data.size() < type:
		return null
	return unit_data[type]
