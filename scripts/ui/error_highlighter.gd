# error_highlighter.gd
class_name ErrorHighlighter
extends Node

var code_edit: CodeEdit
var linter: Linter

# Colors for different severity levels
const COLORS = {
	LinterRules.Severity.ERROR: Color("#FF5555"),
	LinterRules.Severity.WARNING: Color("#FFFF55"),
	LinterRules.Severity.INFO: Color("#8888FF"),
	LinterRules.Severity.HINT: Color("#888888"),
}

# Gutter icons
var error_icon: Texture2D
var warning_icon: Texture2D
var info_icon: Texture2D

const GUTTER_ERROR = 1  # Gutter index for error indicators

func _init(editor: CodeEdit) -> void:
	code_edit = editor
	linter = Linter.new()
	linter.diagnostics_updated.connect(_on_diagnostics_updated)

	# Add the timer to the scene tree
	code_edit.add_child(linter.get_timer())

	# Setup error gutter
	code_edit.add_gutter(GUTTER_ERROR)
	code_edit.set_gutter_type(GUTTER_ERROR, CodeEdit.GUTTER_TYPE_ICON)
	code_edit.set_gutter_width(GUTTER_ERROR, 20)

func setup_error_panel(parent: Control) -> void:
	"""Setup error panel UI (optional - for showing error list)"""
	# This is optional - error highlighting works without a panel
	# If you want an error panel, it would be added here
	pass

func lint_content(content: String) -> void:
	linter.lint(content)

func _on_diagnostics_updated(diagnostics: Array) -> void:
	_clear_all_markers()

	for diag in diagnostics:
		_add_error_marker(diag)

func _clear_all_markers() -> void:
	# Clear gutter icons
	for i in range(code_edit.get_line_count()):
		code_edit.set_line_gutter_icon(i, GUTTER_ERROR, null)

	# Clear line background colors
	for i in range(code_edit.get_line_count()):
		code_edit.set_line_background_color(i, Color.TRANSPARENT)

	# Redraw
	code_edit.queue_redraw()

func _add_error_marker(diag: Linter.Diagnostic) -> void:
	# Set gutter icon
	var icon = _get_icon_for_severity(diag.severity)
	if icon:
		code_edit.set_line_gutter_icon(diag.line, GUTTER_ERROR, icon)

	# Set line background tint for errors
	if diag.severity == LinterRules.Severity.ERROR:
		code_edit.set_line_background_color(diag.line, Color(1, 0, 0, 0.1))

func _get_icon_for_severity(severity: LinterRules.Severity) -> Texture2D:
	match severity:
		LinterRules.Severity.ERROR:
			return error_icon
		LinterRules.Severity.WARNING:
			return warning_icon
		_:
			return info_icon

func get_hover_info(line: int, column: int) -> String:
	var diags = linter.get_diagnostics_for_line(line)
	for diag in diags:
		if column >= diag.column_start and column <= diag.column_end:
			var info = "[%s] %s" % [diag.code, diag.message]
			if not diag.suggestions.is_empty():
				info += "\nSuggestion: " + diag.suggestions[0]
			return info
	return ""
