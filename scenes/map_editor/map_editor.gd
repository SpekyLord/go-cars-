extends Node2D
class_name MapEditor

## Map Editor for creating GoCars levels
## Allows painting with Grass (1), Road (2), and House (3) terrains
## Houses only connect to ONE road - the first adjacent road found

signal tile_placed(position: Vector2i, terrain_type: int)
signal terrain_selected(terrain_type: int)

# Terrain type constants
enum TerrainType {
	NONE = 0,
	GRASS = 1,
	ROAD = 2,
	HOUSE = 3
}

# Direction vectors for checking neighbors
const DIRECTIONS = {
	"north": Vector2i(0, -1),
	"south": Vector2i(0, 1),
	"east": Vector2i(1, 0),
	"west": Vector2i(-1, 0)
}

# Track house connections: house_pos -> connected_direction
var house_connections: Dictionary = {}

# Current selected terrain for painting
var current_terrain: TerrainType = TerrainType.ROAD

# References
@onready var tile_map: TileMap = $TileMap
@onready var card_container: HBoxContainer = $UI/CardContainer
@onready var grass_card: Button = $UI/CardContainer/GrassCard
@onready var road_card: Button = $UI/CardContainer/RoadCard
@onready var house_card: Button = $UI/CardContainer/HouseCard

# TileSet source ID (atlas)
const SOURCE_ID: int = 0

# Tile Atlas Coordinates mapping (column, row) -> Vector2i(x, y)
# Based on your tileset layout:
const TILES = {
	# Row 0
	"grass": Vector2i(0, 0),           # c1/r1 - Grass
	"road_isolated": Vector2i(1, 0),   # c2/r1 - Road (no connections)
	"road_e": Vector2i(2, 0),          # c3/r1 - Road east
	"road_ew": Vector2i(3, 0),         # c4/r1 - Road east+west
	"road_w": Vector2i(4, 0),          # c5/r1 - Road west

	# Row 1
	"road_nesw": Vector2i(0, 1),       # c1/r2 - Road all 4 directions
	"road_es": Vector2i(1, 1),         # c2/r2 - Road east+south
	"road_ws": Vector2i(2, 1),         # c3/r2 - Road west+south
	"road_ens": Vector2i(3, 1),        # c4/r2 - Road east+north+south
	"road_ews": Vector2i(4, 1),        # c5/r2 - Road east+west+south

	# Row 2
	"road_s": Vector2i(0, 2),          # c1/r3 - Road south
	"road_en": Vector2i(1, 2),         # c2/r3 - Road east+north
	"road_wn": Vector2i(2, 2),         # c3/r3 - Road west+north
	"road_ewn": Vector2i(3, 2),        # c4/r3 - Road east+west+north
	"road_wns": Vector2i(4, 2),        # c5/r3 - Road west+north+south

	# Row 3
	"road_ns": Vector2i(0, 3),         # c1/r4 - Road north+south
	"house_n": Vector2i(1, 3),         # c2/r4 - House connects north
	"house_s": Vector2i(2, 3),         # c3/r4 - House connects south
	"house_isolated": Vector2i(3, 3),  # c4/r4 - House (no connection)
	# c5/r4 = None (4, 3)

	# Row 4
	"road_n": Vector2i(0, 4),          # c1/r5 - Road north
	"house_w": Vector2i(1, 4),         # c2/r5 - House connects west
	"house_e": Vector2i(2, 4),         # c3/r5 - House connects east
	# c4/r5 = None (3, 4)
	# c5/r5 = None (4, 4)
}

# Mouse state
var is_painting: bool = false


func _ready() -> void:
	# Connect card button signals
	grass_card.pressed.connect(_on_grass_card_pressed)
	road_card.pressed.connect(_on_road_card_pressed)
	house_card.pressed.connect(_on_house_card_pressed)

	# Set initial selection visual
	_update_card_selection()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_painting = event.pressed
			if is_painting:
				_paint_at_mouse_position()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Right click to erase (set to grass)
			_erase_at_mouse_position()

	elif event is InputEventMouseMotion and is_painting:
		_paint_at_mouse_position()


func _paint_at_mouse_position() -> void:
	var mouse_pos = get_global_mouse_position()
	var tile_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))

	_set_tile(tile_pos, current_terrain)


func _erase_at_mouse_position() -> void:
	var mouse_pos = get_global_mouse_position()
	var tile_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))

	# Check if we're erasing a road that a house is connected to
	var old_terrain = get_terrain_at(tile_pos)
	if old_terrain == TerrainType.ROAD:
		_handle_road_removal(tile_pos)
	elif old_terrain == TerrainType.HOUSE:
		# Remove house from connections tracking
		house_connections.erase(tile_pos)

	# Erase by setting to grass
	_set_tile_direct(tile_pos, TerrainType.GRASS)

	# Update adjacent roads after erasing
	_update_adjacent_roads(tile_pos)


func _set_tile(pos: Vector2i, terrain_type: TerrainType) -> void:
	match terrain_type:
		TerrainType.NONE:
			tile_map.erase_cell(0, pos)
		TerrainType.GRASS:
			_set_tile_direct(pos, TerrainType.GRASS)
		TerrainType.ROAD:
			_place_road(pos)
		TerrainType.HOUSE:
			_place_house(pos)

	tile_placed.emit(pos, terrain_type)


func _set_tile_direct(pos: Vector2i, terrain_type: TerrainType) -> void:
	# Direct tile placement - no auto-connect, just place the tile
	match terrain_type:
		TerrainType.NONE:
			tile_map.erase_cell(0, pos)
		TerrainType.GRASS:
			tile_map.set_cell(0, pos, SOURCE_ID, TILES["grass"])
		TerrainType.ROAD:
			tile_map.set_cell(0, pos, SOURCE_ID, TILES["road_isolated"])
		TerrainType.HOUSE:
			tile_map.set_cell(0, pos, SOURCE_ID, TILES["house_isolated"])


func _place_road(pos: Vector2i) -> void:
	# Determine which directions have ROADS (not houses) to connect to
	var connections = {
		"north": false,
		"south": false,
		"east": false,
		"west": false
	}

	for dir_name in DIRECTIONS:
		var neighbor_pos = pos + DIRECTIONS[dir_name]
		var neighbor_terrain = get_terrain_at(neighbor_pos)

		# Only connect to actual roads, NOT houses
		if neighbor_terrain == TerrainType.ROAD:
			connections[dir_name] = true

	# Manually set the road tile based on connections (ignoring houses)
	_set_road_tile_manual(pos, connections)

	# Now check if any adjacent ISOLATED houses (3,3) need to connect to this road
	for dir_name in DIRECTIONS:
		var neighbor_pos = pos + DIRECTIONS[dir_name]

		# Only connect to isolated houses (3,3 tile)
		if _is_isolated_house(neighbor_pos):
			# Connect this isolated house to the road
			var opposite_dir = _get_opposite_direction(dir_name)
			house_connections[neighbor_pos] = opposite_dir
			_update_house_tile(neighbor_pos, opposite_dir)

	# Update adjacent roads to connect properly (NOT houses)
	_update_adjacent_roads(pos)


func _is_isolated_house(pos: Vector2i) -> bool:
	# Check if the tile at pos is an isolated house
	var atlas_coords = tile_map.get_cell_atlas_coords(0, pos)
	return atlas_coords == TILES["house_isolated"]


func _set_road_tile_manual(pos: Vector2i, connections: Dictionary) -> void:
	# Manually select the correct road tile based on connections
	# This ignores houses - roads only connect to other roads visually
	var n = connections["north"]
	var s = connections["south"]
	var e = connections["east"]
	var w = connections["west"]

	var tile_key: String

	# Match connection pattern to tile key
	if n and s and e and w:
		tile_key = "road_nesw"      # 4-way intersection
	elif e and n and s:
		tile_key = "road_ens"       # T: east+north+south
	elif w and n and s:
		tile_key = "road_wns"       # T: west+north+south
	elif e and w and n:
		tile_key = "road_ewn"       # T: east+west+north
	elif e and w and s:
		tile_key = "road_ews"       # T: east+west+south
	elif n and s:
		tile_key = "road_ns"        # Vertical
	elif e and w:
		tile_key = "road_ew"        # Horizontal
	elif e and n:
		tile_key = "road_en"        # Corner: east+north
	elif w and n:
		tile_key = "road_wn"        # Corner: west+north
	elif e and s:
		tile_key = "road_es"        # Corner: east+south
	elif w and s:
		tile_key = "road_ws"        # Corner: west+south
	elif n:
		tile_key = "road_n"         # Dead end: north
	elif s:
		tile_key = "road_s"         # Dead end: south
	elif e:
		tile_key = "road_e"         # Dead end: east
	elif w:
		tile_key = "road_w"         # Dead end: west
	else:
		tile_key = "road_isolated"  # No connections

	tile_map.set_cell(0, pos, SOURCE_ID, TILES[tile_key])


func _place_house(pos: Vector2i) -> void:
	# Always place isolated house first
	tile_map.set_cell(0, pos, SOURCE_ID, TILES["house_isolated"])

	# Find first adjacent road to connect to
	var connected_dir = ""

	for dir_name in DIRECTIONS:
		var neighbor_pos = pos + DIRECTIONS[dir_name]
		var neighbor_terrain = get_terrain_at(neighbor_pos)

		if neighbor_terrain == TerrainType.ROAD:
			connected_dir = dir_name
			break  # Only connect to first road found

	# If there's an adjacent road, connect to it
	if connected_dir != "":
		house_connections[pos] = connected_dir
		_update_house_tile(pos, connected_dir)
	else:
		# No road nearby - keep as isolated house
		house_connections[pos] = ""
		# Already placed as isolated, no need to update


func _update_house_tile(pos: Vector2i, connection_dir: String) -> void:
	# Set house tile based on which direction it connects
	var tile_key: String

	match connection_dir:
		"north":
			tile_key = "house_n"
		"south":
			tile_key = "house_s"
		"west":
			tile_key = "house_w"
		"east":
			tile_key = "house_e"
		_:  # No connection - isolated house
			tile_key = "house_isolated"

	tile_map.set_cell(0, pos, SOURCE_ID, TILES[tile_key])


func _update_road_tile(pos: Vector2i) -> void:
	# Re-calculate road connections (only to other roads, not houses)
	var connections = {
		"north": false,
		"south": false,
		"east": false,
		"west": false
	}

	for dir_name in DIRECTIONS:
		var neighbor_pos = pos + DIRECTIONS[dir_name]
		var neighbor_terrain = get_terrain_at(neighbor_pos)

		# Only connect to actual roads, NOT houses
		if neighbor_terrain == TerrainType.ROAD:
			connections[dir_name] = true

	_set_road_tile_manual(pos, connections)


func _update_adjacent_roads(pos: Vector2i) -> void:
	# Update all adjacent road tiles
	for dir_name in DIRECTIONS:
		var neighbor_pos = pos + DIRECTIONS[dir_name]
		var neighbor_terrain = get_terrain_at(neighbor_pos)

		if neighbor_terrain == TerrainType.ROAD:
			_update_road_tile(neighbor_pos)


func _handle_road_removal(road_pos: Vector2i) -> void:
	# Check if any houses were connected to this road
	for dir_name in DIRECTIONS:
		var neighbor_pos = road_pos + DIRECTIONS[dir_name]

		if house_connections.has(neighbor_pos):
			var house_connection = house_connections[neighbor_pos]
			var opposite = _get_opposite_direction(dir_name)

			# Check if this house was connected to the removed road
			if house_connection == opposite:
				# House needs to find a new connection
				_reconnect_house(neighbor_pos)


func _reconnect_house(house_pos: Vector2i) -> void:
	# First, reset house to isolated
	tile_map.set_cell(0, house_pos, SOURCE_ID, TILES["house_isolated"])
	house_connections[house_pos] = ""

	# Find a new road to connect to
	var new_connection = ""

	for dir_name in DIRECTIONS:
		var neighbor_pos = house_pos + DIRECTIONS[dir_name]
		var neighbor_terrain = get_terrain_at(neighbor_pos)

		if neighbor_terrain == TerrainType.ROAD:
			new_connection = dir_name
			break

	# If found a new road, connect to it
	if new_connection != "":
		house_connections[house_pos] = new_connection
		_update_house_tile(house_pos, new_connection)


func _get_opposite_direction(dir: String) -> String:
	match dir:
		"north": return "south"
		"south": return "north"
		"east": return "west"
		"west": return "east"
	return ""


# Card button handlers
func _on_grass_card_pressed() -> void:
	current_terrain = TerrainType.GRASS
	_update_card_selection()
	terrain_selected.emit(TerrainType.GRASS)


func _on_road_card_pressed() -> void:
	current_terrain = TerrainType.ROAD
	_update_card_selection()
	terrain_selected.emit(TerrainType.ROAD)


func _on_house_card_pressed() -> void:
	current_terrain = TerrainType.HOUSE
	_update_card_selection()
	terrain_selected.emit(TerrainType.HOUSE)


func _update_card_selection() -> void:
	# Reset all cards to default style
	_set_card_selected(grass_card, false)
	_set_card_selected(road_card, false)
	_set_card_selected(house_card, false)

	# Highlight selected card
	match current_terrain:
		TerrainType.GRASS:
			_set_card_selected(grass_card, true)
		TerrainType.ROAD:
			_set_card_selected(road_card, true)
		TerrainType.HOUSE:
			_set_card_selected(house_card, true)


func _set_card_selected(card: Button, selected: bool) -> void:
	if selected:
		card.modulate = Color(1.2, 1.2, 1.2, 1.0)
		card.self_modulate = Color(0.8, 1.0, 0.8, 1.0)
	else:
		card.modulate = Color(1.0, 1.0, 1.0, 1.0)
		card.self_modulate = Color(1.0, 1.0, 1.0, 1.0)


# Utility: Clear the entire map
func clear_map() -> void:
	tile_map.clear()


# Utility: Fill area with grass
func fill_with_grass(width: int, height: int) -> void:
	for x in range(width):
		for y in range(height):
			_set_tile(Vector2i(x, y), TerrainType.GRASS)


# Get terrain type at position
func get_terrain_at(pos: Vector2i) -> TerrainType:
	var source_id = tile_map.get_cell_source_id(0, pos)
	if source_id == -1:
		return TerrainType.NONE

	var atlas_coords = tile_map.get_cell_atlas_coords(0, pos)

	# Check against TILES dictionary
	if atlas_coords == TILES["grass"]:
		return TerrainType.GRASS

	# Check if it's a house tile
	if atlas_coords == TILES["house_isolated"] or \
	   atlas_coords == TILES["house_n"] or \
	   atlas_coords == TILES["house_s"] or \
	   atlas_coords == TILES["house_e"] or \
	   atlas_coords == TILES["house_w"]:
		return TerrainType.HOUSE

	# Everything else in the tileset is a road
	return TerrainType.ROAD
