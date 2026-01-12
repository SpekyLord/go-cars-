extends PopupPanel
class_name RenameDialog

## Dialog for renaming files with validation
## Emits 'file_renamed' signal with old_name and new_name

signal file_renamed(old_name: String, new_name: String)
signal rename_cancelled()

var old_filename: String = ""
var existing_files: Array[String] = []

@onready var title_label: Label = %TitleLabel
@onready var name_input: LineEdit = %NameInput
@onready var confirm_button: Button = %ConfirmButton
@onready var cancel_button: Button = %CancelButton
@onready var error_label: Label = %ErrorLabel


func _ready() -> void:
	if not is_node_ready():
		return

	# Connect signals
	if confirm_button:
		confirm_button.pressed.connect(_on_confirm_pressed)
	if cancel_button:
		cancel_button.pressed.connect(_on_cancel_pressed)
	if name_input:
		name_input.text_submitted.connect(_on_text_submitted)
		name_input.text_changed.connect(_on_text_changed)

	# Setup popup behavior
	popup_hide.connect(_on_popup_hide)


func show_rename(filename: String, existing_filenames: Array[String]) -> void:
	"""Show the rename dialog for the given file"""
	old_filename = filename
	existing_files = existing_filenames

	# Remove .py extension if present
	var display_name = filename
	if display_name.ends_with(".py"):
		display_name = display_name.substr(0, display_name.length() - 3)

	if title_label:
		title_label.text = "Rename File"

	if name_input:
		name_input.text = display_name
		name_input.select_all()

	if error_label:
		error_label.text = ""
		error_label.visible = false

	popup_centered()

	# Focus the input
	if name_input:
		name_input.grab_focus()


func _on_confirm_pressed() -> void:
	_attempt_rename()


func _on_text_submitted(_text: String) -> void:
	_attempt_rename()


func _on_cancel_pressed() -> void:
	hide()
	rename_cancelled.emit()


func _on_popup_hide() -> void:
	# Reset state when popup closes
	if error_label:
		error_label.visible = false


func _on_text_changed(new_text: String) -> void:
	"""Validate input as user types"""
	if error_label:
		if _validate_name(new_text):
			error_label.visible = false
		else:
			error_label.visible = true


func _attempt_rename() -> void:
	"""Validate and emit rename signal"""
	if not name_input:
		return

	var new_name = name_input.text.strip_edges()

	# Validate
	if not _validate_name(new_name):
		return

	# Add .py extension if not present
	if not new_name.ends_with(".py"):
		new_name += ".py"

	# Check if name unchanged
	if new_name == old_filename:
		hide()
		return

	# Success - emit signal and close
	hide()
	file_renamed.emit(old_filename, new_name)


func _validate_name(name: String) -> bool:
	"""Validate filename and show error if invalid"""
	if not error_label:
		return true

	# Empty name
	if name.is_empty():
		error_label.text = "Filename cannot be empty"
		error_label.visible = true
		return false

	# Check for invalid characters
	var invalid_chars = ["<", ">", ":", "\"", "/", "\\", "|", "?", "*"]
	for char in invalid_chars:
		if name.contains(char):
			error_label.text = "Invalid characters in filename"
			error_label.visible = true
			return false

	# Check if starts with number or special char
	if name[0].is_valid_int() or name[0] == ".":
		error_label.text = "Filename cannot start with number or dot"
		error_label.visible = true
		return false

	# Check for duplicate (add .py if not present)
	var check_name = name if name.ends_with(".py") else name + ".py"
	if check_name != old_filename and check_name in existing_files:
		error_label.text = "File already exists"
		error_label.visible = true
		return false

	# Valid
	error_label.visible = false
	return true
