extends TileMapLayer
class_name RoadTileMapLayer

## TileMapLayer-based road system for GoCars
## Uses the new 5x5 tileset (144x144 per tile)
##
## Tile Layout (row/column):
## r0/c0=road no connection       r0/c1=road E          r0/c2=road EW         r0/c3=road W          r0/c4=spawn parking S
## r1/c0=road S                   r1/c1=road SE         r1/c2=road SEW        r1/c3=road SW         r1/c4=spawn parking N
## r2/c0=road SN                  r2/c1=road SNE        r2/c2=road SNEW       r2/c3=road SNW        r2/c4=dest parking S
## r3/c0=road N                   r3/c1=road NE         r3/c2=road NEW        r3/c3=road NW         r3/c4=dest parking N
## r4/c0=spawn parking E          r4/c1=spawn parking W r4/c2=dest parking E  r4/c3=dest parking W  r4/c4=None

# Tile constants
const TILE_SIZE: float = 144.0
const HALF_TILE: float = 72.0
const LANE_OFFSET: float = 25.0

# Tile type enums for clarity
enum TileType {
	ROAD_NONE,           # No connections (isolated road)
	ROAD_E,              # East connection
	ROAD_EW,             # East-West
	ROAD_W,              # West connection
	SPAWN_PARKING_S,     # Spawn parking connecting south
	ROAD_S,              # South connection
	ROAD_SE,             # South-East
	ROAD_SEW,            # South-East-West
	ROAD_SW,             # South-West
	SPAWN_PARKING_N,     # Spawn parking connecting north
	ROAD_SN,             # South-North
	ROAD_SNE,            # South-North-East
	ROAD_SNEW,           # All four directions
	ROAD_SNW,            # South-North-West
	DEST_PARKING_S,      # Destination parking connecting south
	ROAD_N,              # North connection
	ROAD_NE,             # North-East
	ROAD_NEW,            # North-East-West
	ROAD_NW,             # North-West
	DEST_PARKING_N,      # Destination parking connecting north
	SPAWN_PARKING_E,     # Spawn parking connecting east
	SPAWN_PARKING_W,     # Spawn parking connecting west
	DEST_PARKING_E,      # Destination parking connecting east
	DEST_PARKING_W,      # Destination parking connecting west
	NONE                 # Empty/no tile
}

# Mapping from tile atlas coords to TileType
const TILE_COORDS_TO_TYPE: Dictionary = {
	Vector2i(0, 0): TileType.ROAD_NONE,
	Vector2i(1, 0): TileType.ROAD_E,
	Vector2i(2, 0): TileType.ROAD_EW,
	Vector2i(3, 0): TileType.ROAD_W,
	Vector2i(4, 0): TileType.SPAWN_PARKING_S,
	Vector2i(0, 1): TileType.ROAD_S,
	Vector2i(1, 1): TileType.ROAD_SE,
	Vector2i(2, 1): TileType.ROAD_SEW,
	Vector2i(3, 1): TileType.ROAD_SW,
	Vector2i(4, 1): TileType.SPAWN_PARKING_N,
	Vector2i(0, 2): TileType.ROAD_SN,
	Vector2i(1, 2): TileType.ROAD_SNE,
	Vector2i(2, 2): TileType.ROAD_SNEW,
	Vector2i(3, 2): TileType.ROAD_SNW,
	Vector2i(4, 2): TileType.DEST_PARKING_S,
	Vector2i(0, 3): TileType.ROAD_N,
	Vector2i(1, 3): TileType.ROAD_NE,
	Vector2i(2, 3): TileType.ROAD_NEW,
	Vector2i(3, 3): TileType.ROAD_NW,
	Vector2i(4, 3): TileType.DEST_PARKING_N,
	Vector2i(0, 4): TileType.SPAWN_PARKING_E,
	Vector2i(1, 4): TileType.SPAWN_PARKING_W,
	Vector2i(2, 4): TileType.DEST_PARKING_E,
	Vector2i(3, 4): TileType.DEST_PARKING_W,
	Vector2i(4, 4): TileType.NONE
}

# Mapping from TileType to connections (directions the tile connects to)
const TILE_CONNECTIONS: Dictionary = {
	TileType.ROAD_NONE: [],
	TileType.ROAD_E: ["right"],
	TileType.ROAD_EW: ["left", "right"],
	TileType.ROAD_W: ["left"],
	TileType.SPAWN_PARKING_S: ["bottom"],
	TileType.ROAD_S: ["bottom"],
	TileType.ROAD_SE: ["bottom", "right"],
	TileType.ROAD_SEW: ["bottom", "left", "right"],
	TileType.ROAD_SW: ["bottom", "left"],
	TileType.SPAWN_PARKING_N: ["top"],
	TileType.ROAD_SN: ["top", "bottom"],
	TileType.ROAD_SNE: ["top", "bottom", "right"],
	TileType.ROAD_SNEW: ["top", "bottom", "left", "right"],
	TileType.ROAD_SNW: ["top", "bottom", "left"],
	TileType.DEST_PARKING_S: ["bottom"],
	TileType.ROAD_N: ["top"],
	TileType.ROAD_NE: ["top", "right"],
	TileType.ROAD_NEW: ["top", "left", "right"],
	TileType.ROAD_NW: ["top", "left"],
	TileType.DEST_PARKING_N: ["top"],
	TileType.SPAWN_PARKING_E: ["right"],
	TileType.SPAWN_PARKING_W: ["left"],
	TileType.DEST_PARKING_E: ["right"],
	TileType.DEST_PARKING_W: ["left"],
	TileType.NONE: []
}

# Cached spawn and destination positions
var spawn_positions: Array[Vector2i] = []  # Grid positions of spawn parking tiles
var destination_positions: Array[Vector2i] = []  # Grid positions of destination parking tiles

# Path cache - recalculated when needed
var _paths_dirty: bool = true
var _cached_paths: Dictionary = {}  # Key: grid_pos, Value: Dictionary of entry->exit->path

# Signals
signal paths_updated


func _ready() -> void:
	_scan_for_parking_tiles()


## Scan the tilemap for spawn and destination parking tiles
func _scan_for_parking_tiles() -> void:
	spawn_positions.clear()
	destination_positions.clear()

	var used_cells = get_used_cells()
	for cell_pos in used_cells:
		var tile_type = get_tile_type_at(cell_pos)

		# Check for spawn parking tiles
		if tile_type in [TileType.SPAWN_PARKING_S, TileType.SPAWN_PARKING_N,
						 TileType.SPAWN_PARKING_E, TileType.SPAWN_PARKING_W]:
			spawn_positions.append(cell_pos)

		# Check for destination parking tiles
		elif tile_type in [TileType.DEST_PARKING_S, TileType.DEST_PARKING_N,
						   TileType.DEST_PARKING_E, TileType.DEST_PARKING_W]:
			destination_positions.append(cell_pos)

	print("Found %d spawn positions and %d destination positions" % [spawn_positions.size(), destination_positions.size()])


## Get the TileType at a grid position
func get_tile_type_at(grid_pos: Vector2i) -> TileType:
	var atlas_coords = get_cell_atlas_coords(grid_pos)
	if atlas_coords == Vector2i(-1, -1):
		return TileType.NONE
	return TILE_COORDS_TO_TYPE.get(atlas_coords, TileType.NONE)


## Get connections for a tile at grid position
func get_connections_at(grid_pos: Vector2i) -> Array:
	var tile_type = get_tile_type_at(grid_pos)
	return TILE_CONNECTIONS.get(tile_type, [])


## Check if there's a road at the given grid position
func has_road_at(grid_pos: Vector2i) -> bool:
	var tile_type = get_tile_type_at(grid_pos)
	return tile_type != TileType.NONE


## Check if tile at grid_pos has a connection in the given direction
func has_connection(grid_pos: Vector2i, direction: String) -> bool:
	var connections = get_connections_at(grid_pos)
	return direction in connections


## Check if there's a road at world position
func is_road_at_position(world_pos: Vector2) -> bool:
	var grid_pos = local_to_map(world_pos)
	return has_road_at(grid_pos)


## Get available exit directions when entering from a given direction
func get_available_exits(grid_pos: Vector2i, entry_dir: String) -> Array:
	var connections = get_connections_at(grid_pos)
	var exits: Array = []

	for dir in connections:
		if dir != entry_dir:  # Can't exit where you entered
			exits.append(dir)

	return exits


## Get spawn positions with their spawn direction
## Returns array of dictionaries: {position: Vector2, direction: Vector2, rotation: float, entry_dir: String}
## Lane offset follows right-hand traffic (cars drive on RIGHT side of road)
func get_spawn_data() -> Array:
	var spawn_data: Array = []

	for spawn_pos in spawn_positions:
		var tile_type = get_tile_type_at(spawn_pos)
		var world_pos = map_to_local(spawn_pos)
		var data = {}

		# Right-hand traffic lane offsets:
		# Facing South (down): right side is West (-X)
		# Facing North (up): right side is East (+X)
		# Facing East (right): right side is South (+Y)
		# Facing West (left): right side is North (-Y)

		match tile_type:
			TileType.SPAWN_PARKING_S:
				# Car exits through SOUTH (bottom), faces DOWN
				# Right-hand traffic: offset to the left (-X) when facing down
				data["position"] = world_pos + Vector2(-LANE_OFFSET, 0)
				data["direction"] = Vector2.DOWN
				data["rotation"] = PI  # 180 degrees - facing down
				data["entry_dir"] = "top"  # Will enter next tile from top
			TileType.SPAWN_PARKING_N:
				# Car exits through NORTH (top), faces UP
				# Right-hand traffic: offset to the right (+X) when facing up
				data["position"] = world_pos + Vector2(LANE_OFFSET, 0)
				data["direction"] = Vector2.UP
				data["rotation"] = 0.0  # 0 degrees - facing up
				data["entry_dir"] = "bottom"
			TileType.SPAWN_PARKING_E:
				# Car exits through EAST (right), faces RIGHT
				# Right-hand traffic: offset down (+Y) when facing right
				data["position"] = world_pos + Vector2(0, LANE_OFFSET)
				data["direction"] = Vector2.RIGHT
				data["rotation"] = PI / 2  # 90 degrees - facing right
				data["entry_dir"] = "left"
			TileType.SPAWN_PARKING_W:
				# Car exits through WEST (left), faces LEFT
				# Right-hand traffic: offset up (-Y) when facing left
				data["position"] = world_pos + Vector2(0, -LANE_OFFSET)
				data["direction"] = Vector2.LEFT
				data["rotation"] = -PI / 2  # -90 degrees - facing left
				data["entry_dir"] = "right"

		data["grid_pos"] = spawn_pos
		spawn_data.append(data)

	return spawn_data


## Get destination positions with their entry direction
## Returns array of dictionaries: {position: Vector2, entry_dir: String, grid_pos: Vector2i}
## Lane offset follows right-hand traffic (cars drive on RIGHT side of road)
func get_destination_data() -> Array:
	var dest_data: Array = []

	for dest_pos in destination_positions:
		var tile_type = get_tile_type_at(dest_pos)
		var world_pos = map_to_local(dest_pos)
		var data = {}

		# Right-hand traffic lane offsets for destination:
		# Car entering from South (traveling North): was on right side (+X)
		# Car entering from North (traveling South): was on right side (-X)
		# Car entering from East (traveling West): was on right side (-Y)
		# Car entering from West (traveling East): was on right side (+Y)

		match tile_type:
			TileType.DEST_PARKING_S:
				# Car enters through SOUTH connection (traveling North into parking)
				# Car was on right side of road when traveling North: +X offset
				data["position"] = world_pos + Vector2(LANE_OFFSET, 0)
				data["entry_dir"] = "bottom"
			TileType.DEST_PARKING_N:
				# Car enters through NORTH connection (traveling South into parking)
				# Car was on right side of road when traveling South: -X offset
				data["position"] = world_pos + Vector2(-LANE_OFFSET, 0)
				data["entry_dir"] = "top"
			TileType.DEST_PARKING_E:
				# Car enters through EAST connection (traveling West into parking)
				# Car was on right side of road when traveling West: -Y offset
				data["position"] = world_pos + Vector2(0, -LANE_OFFSET)
				data["entry_dir"] = "right"
			TileType.DEST_PARKING_W:
				# Car enters through WEST connection (traveling East into parking)
				# Car was on right side of road when traveling East: +Y offset
				data["position"] = world_pos + Vector2(0, LANE_OFFSET)
				data["entry_dir"] = "left"

		data["grid_pos"] = dest_pos
		dest_data.append(data)

	return dest_data


## Get the guideline path for traversing a tile from entry to exit
## Returns array of world positions (waypoints)
func get_guideline_path(grid_pos: Vector2i, entry_dir: String, exit_dir: String) -> Array:
	# Check if we have this path cached
	var cache_key = "%s_%s_%s" % [grid_pos, entry_dir, exit_dir]
	if _cached_paths.has(cache_key):
		return _cached_paths[cache_key]

	# Calculate the path
	var path = _calculate_path_waypoints(grid_pos, entry_dir, exit_dir)
	_cached_paths[cache_key] = path
	return path


## Calculate waypoint path from entry to exit direction
## Waypoints are in world coordinates
func _calculate_path_waypoints(grid_pos: Vector2i, entry_dir: String, exit_dir: String) -> Array:
	var points: Array = []
	var tile_center = Vector2(map_to_local(grid_pos))

	# Check if this is a straight path or a turn
	var is_straight = _get_axis(entry_dir) == _get_axis(exit_dir)

	if is_straight:
		# Straight path - both points have SAME lane offset
		var lane_offset = _get_straight_lane_offset(entry_dir, exit_dir)
		var entry_point = _get_edge_center(entry_dir, tile_center) + lane_offset
		var exit_point = _get_edge_center(exit_dir, tile_center) + lane_offset
		points.append(entry_point)
		points.append(exit_point)
	else:
		# Turn - need different lane offsets and a corner point
		var entry_point = _get_turn_edge_point(entry_dir, exit_dir, tile_center, true)
		var corner = _get_corner_point(entry_dir, exit_dir, tile_center)
		var exit_point = _get_turn_edge_point(entry_dir, exit_dir, tile_center, false)
		points.append(entry_point)
		points.append(corner)
		points.append(exit_point)

	return points


## Get the center of an edge (no lane offset)
func _get_edge_center(dir: String, tile_center: Vector2) -> Vector2:
	match dir:
		"top": return tile_center + Vector2(0, -HALF_TILE)
		"bottom": return tile_center + Vector2(0, HALF_TILE)
		"left": return tile_center + Vector2(-HALF_TILE, 0)
		"right": return tile_center + Vector2(HALF_TILE, 0)
	return tile_center


## Get lane offset for straight paths based on travel direction
func _get_straight_lane_offset(entry_dir: String, exit_dir: String) -> Vector2:
	# Right-hand driving: offset to the RIGHT of travel direction (90 clockwise)
	match entry_dir + "_" + exit_dir:
		"left_right":  # Traveling RIGHT -> right side is DOWN (+Y)
			return Vector2(0, LANE_OFFSET)
		"right_left":  # Traveling LEFT -> right side is UP (-Y)
			return Vector2(0, -LANE_OFFSET)
		"top_bottom":  # Traveling DOWN -> right side is LEFT (-X)
			return Vector2(-LANE_OFFSET, 0)
		"bottom_top":  # Traveling UP -> right side is RIGHT (+X)
			return Vector2(LANE_OFFSET, 0)
	return Vector2.ZERO


## Get edge point for turns (entry or exit)
func _get_turn_edge_point(entry_dir: String, exit_dir: String, tile_center: Vector2, is_entry: bool) -> Vector2:
	var edge = entry_dir if is_entry else exit_dir
	var edge_center = _get_edge_center(edge, tile_center)

	if is_entry:
		var offset = _get_entry_lane_offset(entry_dir)
		return edge_center + offset
	else:
		var offset = _get_exit_lane_offset(exit_dir)
		return edge_center + offset


## Get corner waypoint for turns
func _get_corner_point(entry_dir: String, exit_dir: String, tile_center: Vector2) -> Vector2:
	var entry_offset = _get_entry_lane_offset(entry_dir)
	var exit_offset = _get_exit_lane_offset(exit_dir)

	match entry_dir + "_" + exit_dir:
		# Entering horizontally, exiting vertically
		"left_top", "left_bottom", "right_top", "right_bottom":
			return tile_center + Vector2(exit_offset.x, entry_offset.y)
		# Entering vertically, exiting horizontally
		"top_left", "top_right", "bottom_left", "bottom_right":
			return tile_center + Vector2(entry_offset.x, exit_offset.y)

	return tile_center


## Get lane offset for entry direction
func _get_entry_lane_offset(entry_dir: String) -> Vector2:
	match entry_dir:
		"left":   return Vector2(0, LANE_OFFSET)
		"right":  return Vector2(0, -LANE_OFFSET)
		"top":    return Vector2(-LANE_OFFSET, 0)
		"bottom": return Vector2(LANE_OFFSET, 0)
	return Vector2.ZERO


## Get lane offset for exit direction
func _get_exit_lane_offset(exit_dir: String) -> Vector2:
	match exit_dir:
		"left":   return Vector2(0, -LANE_OFFSET)
		"right":  return Vector2(0, LANE_OFFSET)
		"top":    return Vector2(LANE_OFFSET, 0)
		"bottom": return Vector2(-LANE_OFFSET, 0)
	return Vector2.ZERO


## Get axis for a direction (0 = horizontal, 1 = vertical)
func _get_axis(dir: String) -> int:
	match dir:
		"left", "right": return 0
		"top", "bottom": return 1
	return -1


## Mark paths as dirty (clear cache)
func mark_paths_dirty() -> void:
	_paths_dirty = true
	_cached_paths.clear()


## Get opposite direction
static func get_opposite_direction(direction: String) -> String:
	match direction:
		"top": return "bottom"
		"bottom": return "top"
		"left": return "right"
		"right": return "left"
	return ""


## Get the direction to the left of the given entry direction
static func get_left_of(entry: String) -> String:
	match entry:
		"right": return "bottom"
		"left": return "top"
		"top": return "right"
		"bottom": return "left"
	return ""


## Get the direction to the right of the given entry direction
static func get_right_of(entry: String) -> String:
	match entry:
		"right": return "top"
		"left": return "bottom"
		"top": return "left"
		"bottom": return "right"
	return ""


## Check if the tile at grid_pos is a spawn parking tile
func is_spawn_tile(grid_pos: Vector2i) -> bool:
	var tile_type = get_tile_type_at(grid_pos)
	return tile_type in [TileType.SPAWN_PARKING_S, TileType.SPAWN_PARKING_N,
						 TileType.SPAWN_PARKING_E, TileType.SPAWN_PARKING_W]


## Check if the tile at grid_pos is a destination parking tile
func is_destination_tile(grid_pos: Vector2i) -> bool:
	var tile_type = get_tile_type_at(grid_pos)
	return tile_type in [TileType.DEST_PARKING_S, TileType.DEST_PARKING_N,
						 TileType.DEST_PARKING_E, TileType.DEST_PARKING_W]


## Get grid position from world position
func get_grid_pos_from_world(world_pos: Vector2) -> Vector2i:
	return local_to_map(world_pos)


## Get world position (center) from grid position
func get_world_pos_from_grid(grid_pos: Vector2i) -> Vector2:
	return map_to_local(grid_pos)


## Rescan parking tiles (call after modifying the tilemap)
func refresh_parking_tiles() -> void:
	_scan_for_parking_tiles()
	mark_paths_dirty()
