extends Node

## GameData Autoload
## Manages persistent game data like best times for levels

const SAVE_FILE_PATH = "user://gocars_save.json"

# Best times for each level (level_id -> time in seconds)
var best_times: Dictionary = {}

# Level completion status
var completed_levels: Dictionary = {}


func _ready() -> void:
	load_data()


## Save best time for a level (only if better than existing)
func save_best_time(level_id: String, time: float) -> bool:
	var is_new_best = false

	if not best_times.has(level_id) or time < best_times[level_id]:
		best_times[level_id] = time
		is_new_best = true
		save_data()

	return is_new_best


## Get best time for a level (returns -1 if no time recorded)
func get_best_time(level_id: String) -> float:
	return best_times.get(level_id, -1.0)


## Check if level has a recorded best time
func has_best_time(level_id: String) -> bool:
	return best_times.has(level_id)


## Mark level as completed
func mark_level_completed(level_id: String) -> void:
	completed_levels[level_id] = true
	save_data()


## Check if level is completed
func is_level_completed(level_id: String) -> bool:
	return completed_levels.get(level_id, false)


## Format time as MM:SS.ms
func format_time(time: float) -> String:
	if time < 0:
		return "--:--.--"
	var minutes = int(time / 60)
	var seconds = int(time) % 60
	var milliseconds = int((time - int(time)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]


## Save data to file
func save_data() -> void:
	var data = {
		"best_times": best_times,
		"completed_levels": completed_levels
	}

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))
		file.close()


## Load data from file
func load_data() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return

	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_text = file.get_as_text()
		file.close()

		var json = JSON.new()
		var error = json.parse(json_text)
		if error == OK:
			var data = json.data
			if data is Dictionary:
				best_times = data.get("best_times", {})
				completed_levels = data.get("completed_levels", {})


## Clear all saved data
func clear_data() -> void:
	best_times.clear()
	completed_levels.clear()
	save_data()
