extends Node

## GameData Autoload
## Manages persistent game data like best times for levels

const SAVE_FILE_PATH = "user://gocars_save.json"

# Best times for each level (level_id -> time in seconds)
var best_times: Dictionary = {}

# Level completion status
var completed_levels: Dictionary = {}

# Tutorial completion status (level_name -> bool)
var completed_tutorials: Dictionary = {}

# Intro cutscene state (session-only, resets on game restart)
var has_played_intro: bool = false


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


## Mark tutorial as completed for a level
func mark_tutorial_completed(level_name: String) -> void:
	completed_tutorials[level_name] = true
	save_data()
	print("GameData: Tutorial completed for %s" % level_name)


## Check if tutorial has been completed for a level
func has_completed_tutorial(level_name: String) -> bool:
	return completed_tutorials.get(level_name, false)


## Reset tutorial completion for a level (for testing)
func reset_tutorial(level_name: String) -> void:
	completed_tutorials.erase(level_name)
	save_data()


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
		"completed_levels": completed_levels,
		"completed_tutorials": completed_tutorials
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
				completed_tutorials = data.get("completed_tutorials", {})


## Clear all saved data
func clear_data() -> void:
	best_times.clear()
	completed_levels.clear()
	completed_tutorials.clear()
	save_data()


## Mark intro as played (session-only, not saved to disk)
func mark_intro_played() -> void:
	has_played_intro = true


## Check if intro has been played this session
func has_intro_been_played() -> bool:
	return has_played_intro
