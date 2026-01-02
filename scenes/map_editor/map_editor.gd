extends Node2D
class_name MapEditor

## Map Editor for creating GoCars levels
## Allows painting with Grass (1) and Road (2) terrains
## Uses 64x64 debug tileset with diagonal corner connection rules

signal tile_placed(position: Vector2i, terrain_type: int)
signal terrain_selected(terrain_type: int)

# Terrain type constants
enum TerrainType {
	NONE = 0,
	GRASS = 1,
	ROAD = 2
}

# Direction vectors for checking cardinal neighbors
const DIRECTIONS = {
	"north": Vector2i(0, -1),
	"south": Vector2i(0, 1),
	"east": Vector2i(1, 0),
	"west": Vector2i(-1, 0)
}

# Diagonal direction vectors for checking corner neighbors
const DIAGONALS = {
	"north_west": Vector2i(-1, -1),
	"north_east": Vector2i(1, -1),
	"south_west": Vector2i(-1, 1),
	"south_east": Vector2i(1, 1)
}

# Current selected terrain for painting
var current_terrain: TerrainType = TerrainType.ROAD

# References
@onready var tile_map: TileMap = $TileMap
@onready var camera: Camera2D = $Camera2D
@onready var card_container: HBoxContainer = $UI/CardContainer
@onready var grass_card: Button = $UI/CardContainer/GrassCard
@onready var road_card: Button = $UI/CardContainer/RoadCard

# Camera settings
const CAMERA_SPEED: float = 400.0
const ZOOM_SPEED: float = 0.1
const MIN_ZOOM: float = 0.25
const MAX_ZOOM: float = 3.0

# TileSet source ID (atlas)
const SOURCE_ID: int = 0
const TILE_SIZE: int = 64

# Mouse state
var is_painting: bool = false


func _ready() -> void:
	# Connect card button signals
	grass_card.pressed.connect(_on_grass_card_pressed)
	road_card.pressed.connect(_on_road_card_pressed)

	# Set initial selection visual
	_update_card_selection()


func _process(delta: float) -> void:
	_handle_camera_movement(delta)


func _handle_camera_movement(delta: float) -> void:
	var move_direction = Vector2.ZERO

	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		move_direction.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		move_direction.y += 1
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		move_direction.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		move_direction.x += 1

	if move_direction != Vector2.ZERO:
		move_direction = move_direction.normalized()
		# Adjust speed based on zoom level (faster when zoomed out)
		var adjusted_speed = CAMERA_SPEED / camera.zoom.x
		camera.position += move_direction * adjusted_speed * delta


func _input(event: InputEvent) -> void:
	# Handle zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_camera(ZOOM_SPEED)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_camera(-ZOOM_SPEED)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			is_painting = event.pressed
			if is_painting:
				_paint_at_mouse_position()
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			# Right click to erase (set to grass)
			_erase_at_mouse_position()

	elif event is InputEventMouseMotion and is_painting:
		_paint_at_mouse_position()


func _zoom_camera(zoom_change: float) -> void:
	var new_zoom = camera.zoom.x + zoom_change
	new_zoom = clamp(new_zoom, MIN_ZOOM, MAX_ZOOM)
	camera.zoom = Vector2(new_zoom, new_zoom)


func _paint_at_mouse_position() -> void:
	var mouse_pos = get_global_mouse_position()
	var tile_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))

	_set_tile(tile_pos, current_terrain)


func _erase_at_mouse_position() -> void:
	var mouse_pos = get_global_mouse_position()
	var tile_pos = tile_map.local_to_map(tile_map.to_local(mouse_pos))

	# Erase by setting to grass
	tile_map.set_cell(0, tile_pos, SOURCE_ID, Vector2i(0, 0))

	# Update this tile and all adjacent tiles
	_update_tile_and_neighbors(tile_pos)


func _set_tile(pos: Vector2i, terrain_type: TerrainType) -> void:
	match terrain_type:
		TerrainType.NONE:
			tile_map.erase_cell(0, pos)
		TerrainType.GRASS:
			# Place grass and update it properly
			tile_map.set_cell(0, pos, SOURCE_ID, Vector2i(0, 0))
			_update_tile_and_neighbors(pos)
		TerrainType.ROAD:
			# Place road and update connections
			_place_road(pos)

	tile_placed.emit(pos, terrain_type)


func _place_road(pos: Vector2i) -> void:
	# Place a road tile at position and update all affected tiles
	# First, temporarily mark this as a road by setting column 1 (basic road south connection)
	tile_map.set_cell(0, pos, SOURCE_ID, Vector2i(1, 0))

	# Update this tile and all neighbors
	_update_tile_and_neighbors(pos)


func _update_tile_and_neighbors(pos: Vector2i) -> void:
	# Update the tile at pos and all its cardinal and diagonal neighbors
	_update_tile(pos)

	# Update cardinal neighbors
	for dir_name in DIRECTIONS:
		var neighbor_pos = pos + DIRECTIONS[dir_name]
		_update_tile(neighbor_pos)

	# Update diagonal neighbors
	for diag_name in DIAGONALS:
		var neighbor_pos = pos + DIAGONALS[diag_name]
		_update_tile(neighbor_pos)


func _update_tile(pos: Vector2i) -> void:
	# Update a single tile based on its terrain type and neighbors
	var terrain = get_terrain_at(pos)

	if terrain == TerrainType.GRASS:
		_update_grass_tile(pos)
	elif terrain == TerrainType.ROAD:
		_update_road_tile(pos)


func _update_grass_tile(pos: Vector2i) -> void:
	# Grass tiles use column 0, with row based on diagonal road neighbors
	var row = _calculate_row_for_diagonals(pos)
	tile_map.set_cell(0, pos, SOURCE_ID, Vector2i(0, row))


func _update_road_tile(pos: Vector2i) -> void:
	# Determine column based on cardinal road connections
	var column = _calculate_column_for_connections(pos)
	# Determine row based on diagonal road neighbors
	var row = _calculate_row_for_diagonals(pos)

	tile_map.set_cell(0, pos, SOURCE_ID, Vector2i(column, row))


func _calculate_column_for_connections(pos: Vector2i) -> int:
	# Check cardinal directions for road connections
	var has_south = get_terrain_at(pos + DIRECTIONS["south"]) == TerrainType.ROAD
	var has_north = get_terrain_at(pos + DIRECTIONS["north"]) == TerrainType.ROAD
	var has_east = get_terrain_at(pos + DIRECTIONS["east"]) == TerrainType.ROAD
	var has_west = get_terrain_at(pos + DIRECTIONS["west"]) == TerrainType.ROAD

	# Column mapping based on connection pattern:
	# c1 (0) - Grass (handled separately)
	# c2 (1) - Road (isolated, no connections)
	# c3 (2) - Road C South
	# c4 (3) - Road C North
	# c5 (4) - Road C East
	# c6 (5) - Road C West
	# c7 (6) - Road C South and North
	# c8 (7) - Road C East and West
	# c9 (8) - Road C South and East
	# c10 (9) - Road C South and West
	# c11 (10) - Road C North and East
	# c12 (11) - Road C North and West
	# c13 (12) - Road C South and North and East
	# c14 (13) - Road C South and East and West
	# c15 (14) - Road C North and East and West
	# c16 (15) - Road C South and North and West
	# c17 (16) - Road C South and North and East and West

	if has_south and has_north and has_east and has_west:
		return 16  # c17 - All four
	elif has_south and has_north and has_west:
		return 15  # c16 - S+N+W
	elif has_north and has_east and has_west:
		return 14  # c15 - N+E+W
	elif has_south and has_east and has_west:
		return 13  # c14 - S+E+W
	elif has_south and has_north and has_east:
		return 12  # c13 - S+N+E
	elif has_north and has_west:
		return 11  # c12 - N+W
	elif has_north and has_east:
		return 10  # c11 - N+E
	elif has_south and has_west:
		return 9   # c10 - S+W
	elif has_south and has_east:
		return 8   # c9 - S+E
	elif has_east and has_west:
		return 7   # c8 - E+W
	elif has_south and has_north:
		return 6   # c7 - S+N
	elif has_west:
		return 5   # c6 - W
	elif has_east:
		return 4   # c5 - E
	elif has_north:
		return 3   # c4 - N
	elif has_south:
		return 2   # c3 - S
	else:
		return 1   # c2 - Isolated road (no connections)


func _calculate_row_for_diagonals(pos: Vector2i) -> int:
	# Check diagonal positions for roads
	var has_nw = get_terrain_at(pos + DIAGONALS["north_west"]) == TerrainType.ROAD
	var has_ne = get_terrain_at(pos + DIAGONALS["north_east"]) == TerrainType.ROAD
	var has_sw = get_terrain_at(pos + DIAGONALS["south_west"]) == TerrainType.ROAD
	var has_se = get_terrain_at(pos + DIAGONALS["south_east"]) == TerrainType.ROAD

	# Row mapping - check from r16 to r1 (most specific first)
	# r16 (15) - All four diagonals
	if has_nw and has_ne and has_sw and has_se:
		return 15
	# r15 (14) - NW + SW + SE
	if has_nw and has_sw and has_se:
		return 14
	# r14 (13) - NE + SW + SE
	if has_ne and has_sw and has_se:
		return 13
	# r13 (12) - NW + NE + SE
	if has_nw and has_ne and has_se:
		return 12
	# r12 (11) - NW + NE + SW
	if has_nw and has_ne and has_sw:
		return 11
	# r11 (10) - SW + NE
	if has_sw and has_ne:
		return 10
	# r10 (9) - NW + SE
	if has_nw and has_se:
		return 9
	# r9 (8) - SW + SE
	if has_sw and has_se:
		return 8
	# r8 (7) - NE + SE
	if has_ne and has_se:
		return 7
	# r7 (6) - NE + NW
	if has_ne and has_nw:
		return 6
	# r6 (5) - NW + SW
	if has_nw and has_sw:
		return 5
	# r5 (4) - SE only
	if has_se:
		return 4
	# r4 (3) - SW only
	if has_sw:
		return 3
	# r3 (2) - NE only
	if has_ne:
		return 2
	# r2 (1) - NW only
	if has_nw:
		return 1
	# r1 (0) - No diagonal roads
	return 0


# Card button handlers
func _on_grass_card_pressed() -> void:
	current_terrain = TerrainType.GRASS
	_update_card_selection()
	terrain_selected.emit(TerrainType.GRASS)


func _on_road_card_pressed() -> void:
	current_terrain = TerrainType.ROAD
	_update_card_selection()
	terrain_selected.emit(TerrainType.ROAD)


func _update_card_selection() -> void:
	# Reset all cards to default style
	_set_card_selected(grass_card, false)
	_set_card_selected(road_card, false)

	# Highlight selected card
	match current_terrain:
		TerrainType.GRASS:
			_set_card_selected(grass_card, true)
		TerrainType.ROAD:
			_set_card_selected(road_card, true)


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

	# Column 0 is grass, columns 1-15 are road variants
	if atlas_coords.x == 0:
		return TerrainType.GRASS
	else:
		return TerrainType.ROAD
