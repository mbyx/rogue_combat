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
@export var UILayer: TileMapLayer

# NOTE: Terrains that can only be specified via the Foreground must always
# have a larger integer value than the largest terrain type specified via
# the Background.
enum TerrainType {
	PLAINS    = 0,
	WATER     = 1,
	ROAD      = 2,
	MOUNTAINS = 3,
	FOREST    = 4
}

@export_group("Attributes")
## A list of resources whose indices correspond to the terrain type.
@export var terrain_data: Array[Resource]

## Get the terrain type of the tile at that position.
##
## The method will check the terrain type of both the foreground and background
## layers, but return only one, prioritising the foreground layer.
func get_terrain_type_at(coords: Vector2i) -> TerrainType:
	var bg_type: int = TerrainBGLayer \
		.get_cell_tile_data(coords) \
		.get_custom_data("Terrain Type")
	var fg_type: int = TerrainFGLayer \
		.get_cell_tile_data(coords) \
		.get_custom_data("Terrain Type")

	# Assuming the foreground terrains start after the background terrains.
	return TerrainType.get(max(bg_type, fg_type))

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
