extends Node2D
class_name MapEditor

## Map Editor for creating GoCars levels using RoadTile instances
##
## Road Tool Mode:
## - Toggle Road Tool button to enable road editing
## - Hover shows 50% opacity preview
## - Click empty space: place isolated road
## - Click existing road, drag to neighbor: place and connect
## - Hold-drag: chain-place roads with connections
## - Right-click: delete road

signal tile_placed(position: Vector2i, is_road: bool)
signal road_tool_toggled(enabled: bool)

# Direction vectors for checking all 8 neighbors (1 step)
const DIRECTIONS = {
	"top_left": Vector2i(-1, -1),
	"top": Vector2i(0, -1),
	"top_right": Vector2i(1, -1),
	"left": Vector2i(-1, 0),
	"right": Vector2i(1, 0),
	"bottom_left": Vector2i(-1, 1),
	"bottom": Vector2i(0, 1),
	"bottom_right": Vector2i(1, 1)
}

# Extended direction vectors for 2-step neighbors
const EXTENDED_DIRECTIONS = {
	"top_top": Vector2i(0, -2),
	"bottom_bottom": Vector2i(0, 2),
	"left_left": Vector2i(-2, 0),
	"right_right": Vector2i(2, 0),
	"top_left_top_left": Vector2i(-2, -2),
	"top_right_top_right": Vector2i(2, -2),
	"bottom_left_bottom_left": Vector2i(-2, 2),
	"bottom_right_bottom_right": Vector2i(2, 2)
}

# References
var road_tiles_container: Node2D
var camera: Camera2D
var road_tool_button: Button

# Preload the RoadTile scene
var road_tile_scene: PackedScene = preload("res://scenes/map_editor/road_tile.tscn")

# Dictionary to track placed road tiles by grid position
var road_tiles: Dictionary = {}  # Vector2i -> RoadTile instance

# Preview tile (50% opacity)
var preview_tile: RoadTile = null
var preview_position: Vector2i = Vector2i(-9999, -9999)

# Road tool state
var road_tool_enabled: bool = true
var is_placing: bool = false
var is_erasing: bool = false
var last_placed_pos: Vector2i = Vector2i(-9999, -9999)  # Track last position for chain placement

# Camera settings
const CAMERA_SPEED: float = 400.0
const ZOOM_SPEED: float = 0.1
const MIN_ZOOM: float = 0.25
const MAX_ZOOM: float = 3.0

# Tile size for positioning
const TILE_SIZE: int = 48


func _ready() -> void:
	road_tiles_container = $RoadTiles
	camera = $Camera2D

	# Get road tool button if it exists
	road_tool_button = get_node_or_null("UI/TopBar/RoadToolButton")
	if road_tool_button:
		road_tool_button.toggled.connect(_on_road_tool_toggled)
		road_tool_button.button_pressed = road_tool_enabled

	# Get clear button if it exists
	var clear_button = get_node_or_null("UI/TopBar/ClearButton")
	if clear_button:
		clear_button.pressed.connect(clear_map)

	# Create preview tile
	_create_preview_tile()


func _create_preview_tile() -> void:
	preview_tile = road_tile_scene.instantiate()
	preview_tile.set_preview(true)
	preview_tile.visible = false
	add_child(preview_tile)


func _process(delta: float) -> void:
	_handle_camera_movement(delta)
	_update_preview()


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
		var adjusted_speed = CAMERA_SPEED / camera.zoom.x
		camera.position += move_direction * adjusted_speed * delta


func _update_preview() -> void:
	if not road_tool_enabled or not preview_tile:
		if preview_tile:
			preview_tile.visible = false
		return

	var mouse_pos = get_global_mouse_position()
	var tile_pos = _world_to_tile(mouse_pos)

	# Don't show preview if there's already a road there (unless we're connecting)
	if road_tiles.has(tile_pos):
		preview_tile.visible = false
		return

	# Update preview position
	preview_tile.position = _tile_to_world(tile_pos)
	preview_tile.visible = true
	preview_position = tile_pos

	# Calculate what connections the preview would have
	var preview_connections = {}
	for dir in DIRECTIONS:
		preview_connections[dir] = false

	# If we're dragging from a previous position, show connection to it
	if is_placing and last_placed_pos != Vector2i(-9999, -9999):
		var dir_to_last = _get_direction_between(tile_pos, last_placed_pos)
		if dir_to_last != "":
			preview_connections[dir_to_last] = true

	# Calculate extended connections for preview
	var extended = _calculate_extended_connections(tile_pos, preview_connections)
	preview_tile.set_all_connections(preview_connections, extended)


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_camera(ZOOM_SPEED)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_camera(-ZOOM_SPEED)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_placing = true
				is_erasing = false
				_handle_place_start()
			else:
				is_placing = false
				last_placed_pos = Vector2i(-9999, -9999)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				is_erasing = true
				is_placing = false
				_erase_at_mouse_position()
			else:
				is_erasing = false

	elif event is InputEventMouseMotion:
		if is_placing and road_tool_enabled:
			_handle_place_drag()
		elif is_erasing and road_tool_enabled:
			_erase_at_mouse_position()


func _handle_place_start() -> void:
	if not road_tool_enabled:
		return

	var mouse_pos = get_global_mouse_position()
	var tile_pos = _world_to_tile(mouse_pos)

	if road_tiles.has(tile_pos):
		# Clicked on existing road - start chain from here
		last_placed_pos = tile_pos
	else:
		# Clicked on empty space - place new isolated road
		_place_road(tile_pos)
		last_placed_pos = tile_pos


func _handle_place_drag() -> void:
	var mouse_pos = get_global_mouse_position()
	var tile_pos = _world_to_tile(mouse_pos)

	# Skip if same position as last
	if tile_pos == last_placed_pos:
		return

	# Check if this is a neighbor of the last position
	var dir_from_last = _get_direction_between(last_placed_pos, tile_pos)

	if road_tiles.has(tile_pos):
		# Dragged onto existing road - connect them if neighbors
		if dir_from_last != "" and last_placed_pos != Vector2i(-9999, -9999):
			_connect_tiles(last_placed_pos, tile_pos, dir_from_last)
		last_placed_pos = tile_pos
	else:
		# Dragged onto empty space
		if dir_from_last != "" and last_placed_pos != Vector2i(-9999, -9999):
			# Place new road and connect to last
			_place_road(tile_pos)
			_connect_tiles(last_placed_pos, tile_pos, dir_from_last)
		else:
			# Not a neighbor, place isolated
			_place_road(tile_pos)
		last_placed_pos = tile_pos


func _zoom_camera(zoom_change: float) -> void:
	var new_zoom = camera.zoom.x + zoom_change
	new_zoom = clamp(new_zoom, MIN_ZOOM, MAX_ZOOM)
	camera.zoom = Vector2(new_zoom, new_zoom)


func _world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(floor(world_pos.x / TILE_SIZE), floor(world_pos.y / TILE_SIZE))


func _tile_to_world(tile_pos: Vector2i) -> Vector2:
	return Vector2(tile_pos.x * TILE_SIZE, tile_pos.y * TILE_SIZE)


func _get_direction_between(from_pos: Vector2i, to_pos: Vector2i) -> String:
	var diff = to_pos - from_pos
	for dir_name in DIRECTIONS:
		if DIRECTIONS[dir_name] == diff:
			return dir_name
	return ""  # Not neighbors


func _place_road(pos: Vector2i) -> void:
	# Don't place if already exists
	if road_tiles.has(pos):
		return

	# Create new RoadTile instance
	var road_tile = road_tile_scene.instantiate()
	road_tile.position = _tile_to_world(pos)
	road_tiles_container.add_child(road_tile)
	road_tiles[pos] = road_tile

	# No auto-connections - tile starts isolated
	tile_placed.emit(pos, true)


func _connect_tiles(pos_a: Vector2i, pos_b: Vector2i, direction: String) -> void:
	# Connect two tiles bidirectionally
	var tile_a = road_tiles.get(pos_a)
	var tile_b = road_tiles.get(pos_b)

	if tile_a and tile_b:
		var opposite = RoadTile.get_opposite_direction(direction)
		tile_a.add_connection(direction)
		tile_b.add_connection(opposite)

		# Update extended connections for both tiles and their neighbors
		_update_extended_connections(pos_a)
		_update_extended_connections(pos_b)

		# Update 2-step neighbors that might be affected
		for dir_name in EXTENDED_DIRECTIONS:
			var neighbor_pos = pos_a + EXTENDED_DIRECTIONS[dir_name]
			_update_extended_connections(neighbor_pos)
			neighbor_pos = pos_b + EXTENDED_DIRECTIONS[dir_name]
			_update_extended_connections(neighbor_pos)


func _disconnect_tile(pos: Vector2i) -> void:
	# Remove all connections from a tile and update neighbors
	var tile = road_tiles.get(pos)
	if not tile:
		return

	# Remove connections from neighbors pointing to this tile
	for dir_name in DIRECTIONS:
		if tile.has_connection(dir_name):
			var neighbor_pos = pos + DIRECTIONS[dir_name]
			var neighbor = road_tiles.get(neighbor_pos)
			if neighbor:
				var opposite = RoadTile.get_opposite_direction(dir_name)
				neighbor.remove_connection(opposite)
				_update_extended_connections(neighbor_pos)


func _update_extended_connections(pos: Vector2i) -> void:
	var tile = road_tiles.get(pos)
	if not tile:
		return

	var extended = _calculate_extended_connections(pos, tile.connections)
	for dir in extended:
		tile.set_extended_connection(dir, extended[dir])


func _calculate_extended_connections(pos: Vector2i, connections: Dictionary) -> Dictionary:
	var extended = {}

	# For each extended direction, check if there's a chain of connections
	# top_top: need connection to top, and top tile has connection to its top
	for ext_dir in EXTENDED_DIRECTIONS:
		extended[ext_dir] = false

		# Parse the direction (e.g., "top_top" -> check "top" twice)
		var base_dir = ""
		match ext_dir:
			"top_top": base_dir = "top"
			"bottom_bottom": base_dir = "bottom"
			"left_left": base_dir = "left"
			"right_right": base_dir = "right"
			"top_left_top_left": base_dir = "top_left"
			"top_right_top_right": base_dir = "top_right"
			"bottom_left_bottom_left": base_dir = "bottom_left"
			"bottom_right_bottom_right": base_dir = "bottom_right"

		if base_dir == "":
			continue

		# Check if this tile is connected in base_dir
		if not connections.get(base_dir, false):
			continue

		# Check if the neighbor in base_dir is connected further in base_dir
		var neighbor_pos = pos + DIRECTIONS[base_dir]
		var neighbor = road_tiles.get(neighbor_pos)
		if neighbor and neighbor.has_connection(base_dir):
			extended[ext_dir] = true

	return extended


func _erase_at_mouse_position() -> void:
	if not road_tool_enabled:
		return

	var mouse_pos = get_global_mouse_position()
	var tile_pos = _world_to_tile(mouse_pos)
	_remove_road(tile_pos)


func _remove_road(pos: Vector2i) -> void:
	if not road_tiles.has(pos):
		return

	# Disconnect from all neighbors first
	_disconnect_tile(pos)

	# Remove the RoadTile instance
	var road_tile = road_tiles[pos]
	road_tile.queue_free()
	road_tiles.erase(pos)

	# Update extended connections for nearby tiles
	for dir_name in DIRECTIONS:
		var neighbor_pos = pos + DIRECTIONS[dir_name]
		_update_extended_connections(neighbor_pos)
	for dir_name in EXTENDED_DIRECTIONS:
		var neighbor_pos = pos + EXTENDED_DIRECTIONS[dir_name]
		_update_extended_connections(neighbor_pos)

	tile_placed.emit(pos, false)


func _on_road_tool_toggled(pressed: bool) -> void:
	road_tool_enabled = pressed
	if preview_tile:
		preview_tile.visible = false
	road_tool_toggled.emit(pressed)


func set_road_tool_enabled(enabled: bool) -> void:
	road_tool_enabled = enabled
	if road_tool_button:
		road_tool_button.button_pressed = enabled
	if preview_tile:
		preview_tile.visible = false


func clear_map() -> void:
	for pos in road_tiles:
		var road_tile = road_tiles[pos]
		road_tile.queue_free()
	road_tiles.clear()


func is_road_at(pos: Vector2i) -> bool:
	return road_tiles.has(pos)


func get_all_road_positions() -> Array[Vector2i]:
	var positions: Array[Vector2i] = []
	for pos in road_tiles:
		positions.append(pos)
	return positions
