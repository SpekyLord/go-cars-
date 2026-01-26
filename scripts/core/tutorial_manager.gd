## Tutorial Manager for GoCars
## AutoLoad singleton that manages tutorial progression and UI
## Author: Claude Code
## Date: January 2026

extends Node

## Preload TutorialData class
const TutorialDataClass = preload("res://scripts/core/tutorial_data.gd")

## Signals
signal tutorial_started(level_id: String)
signal tutorial_step_changed(step_index: int)
signal tutorial_completed(level_id: String)
signal tutorial_skipped(level_id: String)
signal dialogue_shown(text: String, speaker: String, emotion: String)
signal dialogue_hidden()
signal highlight_requested(target: String)
signal highlight_cleared()
signal wait_for_action(action_type: String)
signal force_event(event_type: String)

## Tutorial data (RefCounted - TutorialData instance)
var tutorial_data = null

## Current tutorial state (TutorialData.TutorialLevel instance)
var current_tutorial = null
var current_step_index: int = -1
var current_dialogue_index: int = 0
var is_tutorial_active: bool = false
var is_waiting_for_action: bool = false
var pending_wait_action: String = ""

## UI references (set by main_tilemap.gd when tutorial starts)
var dialogue_box: Node = null

## Preloaded dialogue box scene
var dialogue_box_scene: PackedScene = null

func _ready() -> void:
	# Load tutorial data
	tutorial_data = TutorialDataClass.new()

	# Preload dialogue box scene
	dialogue_box_scene = load("res://scenes/ui/tutorial/tutorial_dialogue_box.tscn")

	print("TutorialManager: Ready")

## Start tutorial for a level
func start_tutorial(level_name: String, parent_node: Node) -> bool:
	if not tutorial_data:
		push_error("TutorialManager: No tutorial data loaded")
		return false

	current_tutorial = tutorial_data.get_tutorial_for_level(level_name)
	if not current_tutorial:
		print("TutorialManager: No tutorial found for level %s" % level_name)
		return false

	# Check if already completed and should skip
	if GameData.has_completed_tutorial(level_name):
		print("TutorialManager: Tutorial %s already completed, showing skip option" % level_name)
		# Show skip option will be handled by dialogue box

	# Create dialogue box if not exists
	if not dialogue_box and dialogue_box_scene:
		dialogue_box = dialogue_box_scene.instantiate()
		parent_node.add_child(dialogue_box)

		# Connect dialogue box signals
		if dialogue_box.has_signal("continue_pressed"):
			dialogue_box.continue_pressed.connect(_on_continue_pressed)
		if dialogue_box.has_signal("skip_pressed"):
			dialogue_box.skip_pressed.connect(_on_skip_pressed)

	# Show skip button if already completed
	if dialogue_box and GameData.has_completed_tutorial(level_name):
		if dialogue_box.has_method("show_skip_button"):
			dialogue_box.show_skip_button()

	# Start tutorial
	current_step_index = -1
	current_dialogue_index = 0
	is_tutorial_active = true
	is_waiting_for_action = false

	tutorial_started.emit(current_tutorial.id)
	print("TutorialManager: Started tutorial %s" % current_tutorial.id)

	# Show first step
	advance_step()

	return true

## Advance to next step
func advance_step() -> void:
	if not is_tutorial_active or not current_tutorial:
		return

	current_step_index += 1
	current_dialogue_index = 0

	if current_step_index >= current_tutorial.steps.size():
		# Tutorial complete
		complete_tutorial()
		return

	var step = current_tutorial.steps[current_step_index]
	tutorial_step_changed.emit(current_step_index)

	print("TutorialManager: Step %d - %s" % [step.step_number, step.title])

	# Process the step
	_process_step(step)

## Process a tutorial step
func _process_step(step) -> void:
	# Handle action
	match step.action:
		"point":
			highlight_requested.emit(step.target)
		"wait":
			is_waiting_for_action = true
			pending_wait_action = step.wait_type
			wait_for_action.emit(step.wait_type)
		"force":
			force_event.emit(step.target)
		"level_complete":
			# Show final dialogue then complete
			pass
		"appear":
			# Character appears - show dialogue box
			if dialogue_box and dialogue_box.has_method("show_character"):
				dialogue_box.show_character()
		_:
			# Clear any highlight for non-point actions
			highlight_cleared.emit()

	# Show dialogue if there is any
	if step.dialogue.size() > 0:
		_show_dialogue(step)
	elif step.action != "wait":
		# No dialogue and not waiting, auto-advance
		call_deferred("advance_step")

## Show dialogue for current step
func _show_dialogue(step) -> void:
	if current_dialogue_index >= step.dialogue.size():
		# All dialogue shown, check if waiting
		if step.action == "wait":
			# Stay on this step until action is performed
			return
		else:
			# Move to next step
			advance_step()
		return

	var text = step.dialogue[current_dialogue_index]
	var speaker = step.speaker
	var emotion = step.emotion

	# Emit signal for dialogue
	dialogue_shown.emit(text, speaker, emotion)

	# Update dialogue box
	if dialogue_box and dialogue_box.has_method("show_dialogue"):
		dialogue_box.show_dialogue(text, speaker, emotion)

## Continue to next dialogue line or step
func continue_dialogue() -> void:
	if not is_tutorial_active or not current_tutorial:
		return

	if is_waiting_for_action:
		# Can't continue while waiting for action
		return

	var step = current_tutorial.steps[current_step_index]

	current_dialogue_index += 1

	if current_dialogue_index >= step.dialogue.size():
		# All dialogue shown
		if step.action == "wait":
			# Stay on this step
			return
		elif step.action == "level_complete":
			complete_tutorial()
		else:
			advance_step()
	else:
		_show_dialogue(step)

## Called when player performs waited action
func notify_action(action_type: String) -> void:
	if not is_waiting_for_action:
		return

	# Check if action matches what we're waiting for
	if _action_matches(action_type, pending_wait_action):
		print("TutorialManager: Action '%s' completed" % action_type)
		is_waiting_for_action = false
		pending_wait_action = ""
		advance_step()

## Check if performed action matches waited action
func _action_matches(performed: String, waited: String) -> bool:
	# Normalize both strings
	performed = performed.to_lower().strip_edges()
	waited = waited.to_lower().strip_edges()

	# Direct match
	if performed == waited:
		return true

	# Common action mappings
	var mappings = {
		"run_code": ["player presses run", "player runs code", "run", "f5"],
		"open_code_editor": ["player clicks to open code editor", "open editor", "code editor"],
		"type_code": ["player types", "player writes code", "type"],
	}

	for key in mappings:
		if performed == key:
			for match_str in mappings[key]:
				if match_str in waited:
					return true

	return false

## Complete the tutorial
func complete_tutorial() -> void:
	if not current_tutorial:
		return

	var level_name = ""
	for key in tutorial_data.level_to_tutorial:
		if tutorial_data.level_to_tutorial[key] == current_tutorial.id:
			level_name = key
			break

	# Mark as completed in GameData
	if not level_name.is_empty():
		GameData.mark_tutorial_completed(level_name)

	# Hide dialogue box
	if dialogue_box and dialogue_box.has_method("hide_dialogue"):
		dialogue_box.hide_dialogue()

	dialogue_hidden.emit()
	highlight_cleared.emit()
	tutorial_completed.emit(current_tutorial.id)

	print("TutorialManager: Tutorial %s completed" % current_tutorial.id)

	is_tutorial_active = false
	current_tutorial = null

## Skip tutorial
func skip_tutorial() -> void:
	if not current_tutorial:
		return

	var tutorial_id = current_tutorial.id
	var level_name = ""

	for key in tutorial_data.level_to_tutorial:
		if tutorial_data.level_to_tutorial[key] == tutorial_id:
			level_name = key
			break

	# Mark as completed
	if not level_name.is_empty():
		GameData.mark_tutorial_completed(level_name)

	# Hide UI
	if dialogue_box and dialogue_box.has_method("hide_dialogue"):
		dialogue_box.hide_dialogue()

	dialogue_hidden.emit()
	highlight_cleared.emit()
	tutorial_skipped.emit(tutorial_id)

	print("TutorialManager: Tutorial %s skipped" % tutorial_id)

	is_tutorial_active = false
	current_tutorial = null

## Signal callbacks
func _on_continue_pressed() -> void:
	continue_dialogue()

func _on_skip_pressed() -> void:
	skip_tutorial()

## Check if a level has a tutorial
func has_tutorial(level_name: String) -> bool:
	if not tutorial_data:
		return false
	return tutorial_data.has_tutorial(level_name)

## Get current step info
func get_current_step():
	if not current_tutorial or current_step_index < 0:
		return null
	if current_step_index >= current_tutorial.steps.size():
		return null
	return current_tutorial.steps[current_step_index]

## Check if tutorial is active
func is_active() -> bool:
	return is_tutorial_active

## Check if waiting for player action
func is_waiting() -> bool:
	return is_waiting_for_action

## Get pending wait action
func get_pending_action() -> String:
	return pending_wait_action
