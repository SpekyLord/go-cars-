extends RefCounted
class_name RoadTileProxy

## A proxy class that wraps RoadTileMapLayer to provide the same interface as RoadTile
## This allows the Vehicle code to work with both the old RoadTile system and new TileMap system
##
## Usage: var proxy = RoadTileProxy.new(road_layer, grid_pos)
##        var exits = proxy.get_available_exits(entry_dir)
##        var path = proxy.get_guideline_path(entry_dir, exit_dir)

var _road_layer: RoadTileMapLayer
var _grid_pos: Vector2i


func _init(road_layer: RoadTileMapLayer, grid_pos: Vector2i) -> void:
	_road_layer = road_layer
	_grid_pos = grid_pos


## Get available exit directions when entering from a given direction
func get_available_exits(entry_dir: String) -> Array:
	if _road_layer == null:
		return []
	return _road_layer.get_available_exits(_grid_pos, entry_dir)


## Get the waypoint path for a specific entry -> exit traversal
## Returns world positions (not relative to tile)
func get_guideline_path(entry_dir: String, exit_dir: String) -> Array:
	if _road_layer == null:
		return []
	return _road_layer.get_guideline_path(_grid_pos, entry_dir, exit_dir)


## Check if this tile has a connection in the given direction
func has_connection(direction: String) -> bool:
	if _road_layer == null:
		return false
	return _road_layer.has_connection(_grid_pos, direction)


## Get the grid position of this tile
func get_grid_pos() -> Vector2i:
	return _grid_pos


## Get the world position (center) of this tile
func get_world_pos() -> Vector2:
	if _road_layer == null:
		return Vector2.ZERO
	return _road_layer.get_world_pos_from_grid(_grid_pos)


## Static helper: get opposite direction
static func get_opposite_direction(direction: String) -> String:
	return RoadTileMapLayer.get_opposite_direction(direction)


## Static helper: get direction to the left
static func get_left_of(entry: String) -> String:
	return RoadTileMapLayer.get_left_of(entry)


## Static helper: get direction to the right
static func get_right_of(entry: String) -> String:
	return RoadTileMapLayer.get_right_of(entry)
