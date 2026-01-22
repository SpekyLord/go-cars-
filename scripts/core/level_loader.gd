extends Node
class_name LevelLoader

## Automatically loads level scenes from the levelmaps folder
## Levels are detected by scanning for .tscn files in scenes/levelmaps/
## Level order is determined by filename (alphabetical/numerical)

const LEVELS_PATH: String = "res://scenes/levelmaps/"

# Cached list of level paths
var _level_paths: Array[String] = []
var _levels_loaded: bool = false


## Get all available level paths (scans folder if not cached)
func get_level_paths() -> Array[String]:
	if not _levels_loaded:
		_scan_levels_folder()
	return _level_paths


## Get the number of available levels
func get_level_count() -> int:
	if not _levels_loaded:
		_scan_levels_folder()
	return _level_paths.size()


## Get level path by index (0-based)
func get_level_path(index: int) -> String:
	if not _levels_loaded:
		_scan_levels_folder()
	if index >= 0 and index < _level_paths.size():
		return _level_paths[index]
	return ""


## Get level name from path (filename without extension)
func get_level_name(index: int) -> String:
	var path = get_level_path(index)
	if path.is_empty():
		return ""
	return path.get_file().get_basename()


## Load and instantiate a level scene by index
func load_level(index: int) -> Node:
	var path = get_level_path(index)
	if path.is_empty():
		push_error("Level index %d not found" % index)
		return null

	var scene = load(path)
	if scene == null:
		push_error("Failed to load level scene: %s" % path)
		return null

	return scene.instantiate()


## Load and instantiate a level scene by name
func load_level_by_name(level_name: String) -> Node:
	if not _levels_loaded:
		_scan_levels_folder()

	for path in _level_paths:
		if path.get_file().get_basename() == level_name:
			var scene = load(path)
			if scene:
				return scene.instantiate()
	return null


## Scan the levelmaps folder for .tscn files
func _scan_levels_folder() -> void:
	_level_paths.clear()

	var dir = DirAccess.open(LEVELS_PATH)
	if dir == null:
		push_warning("Could not open levels folder: %s" % LEVELS_PATH)
		_levels_loaded = true
		return

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			_level_paths.append(LEVELS_PATH + file_name)
		file_name = dir.get_next()

	dir.list_dir_end()

	# Sort alphabetically/numerically
	_level_paths.sort()
	_levels_loaded = true

	print("LevelLoader: Found %d levels" % _level_paths.size())
	for path in _level_paths:
		print("  - %s" % path)


## Force rescan of levels folder
func refresh() -> void:
	_levels_loaded = false
	_scan_levels_folder()


## Check if a level exists by name
func level_exists(level_name: String) -> bool:
	if not _levels_loaded:
		_scan_levels_folder()

	for path in _level_paths:
		if path.get_file().get_basename() == level_name:
			return true
	return false
