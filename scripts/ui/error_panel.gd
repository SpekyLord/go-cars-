# error_panel.gd
extends PanelContainer
class_name ErrorPanel

signal error_clicked(line: int, column: int)

@onready var error_list: Tree = $VBox/ErrorTree
@onready var error_count_label: Label = $VBox/Header/ErrorCount
@onready var warning_count_label: Label = $VBox/Header/WarningCount

var diagnostics: Array = []

func _ready() -> void:
	if error_list:
		error_list.item_activated.connect(_on_item_activated)
		error_list.create_item()  # Root item
		error_list.hide_root = true

		# Setup columns
		error_list.columns = 4
		error_list.set_column_title(0, "")  # Icon
		error_list.set_column_title(1, "Line")
		error_list.set_column_title(2, "Code")
		error_list.set_column_title(3, "Message")
		error_list.set_column_expand(0, false)
		error_list.set_column_expand(1, false)
		error_list.set_column_custom_minimum_width(0, 24)
		error_list.set_column_custom_minimum_width(1, 50)
		error_list.set_column_custom_minimum_width(2, 60)

func update_diagnostics(diags: Array) -> void:
	diagnostics = diags
	_refresh_list()
	_update_counts()

func _refresh_list() -> void:
	if not error_list:
		return

	# Clear existing items
	var root = error_list.get_root()
	if root:
		for child in root.get_children():
			child.free()

		# Add diagnostics
		for diag in diagnostics:
			var item = error_list.create_item(root)

			# Icon column (placeholder)
			# item.set_icon(0, icon)

			# Line column
			item.set_text(1, str(diag.line + 1))  # 1-indexed for display

			# Code column
			item.set_text(2, diag.code)

			# Message column
			item.set_text(3, diag.message)

			# Store metadata for click handling
			item.set_metadata(0, {"line": diag.line, "column": diag.column_start})

			# Color based on severity
			var color = _get_severity_color(diag.severity)
			for col in range(4):
				item.set_custom_color(col, color)

func _update_counts() -> void:
	var error_count = 0
	var warning_count = 0

	for diag in diagnostics:
		if diag.severity == LinterRules.Severity.ERROR:
			error_count += 1
		elif diag.severity == LinterRules.Severity.WARNING:
			warning_count += 1

	if error_count_label:
		error_count_label.text = "%d Errors" % error_count
		# Color indicators
		error_count_label.add_theme_color_override("font_color", Color.RED if error_count > 0 else Color.GRAY)

	if warning_count_label:
		warning_count_label.text = "%d Warnings" % warning_count
		warning_count_label.add_theme_color_override("font_color", Color.YELLOW if warning_count > 0 else Color.GRAY)

func _on_item_activated() -> void:
	var selected = error_list.get_selected()
	if selected:
		var meta = selected.get_metadata(0)
		error_clicked.emit(meta.line, meta.column)

func _get_severity_color(severity: LinterRules.Severity) -> Color:
	match severity:
		LinterRules.Severity.ERROR:
			return Color("#FF5555")
		LinterRules.Severity.WARNING:
			return Color("#FFFF55")
		LinterRules.Severity.INFO:
			return Color("#8888FF")
		_:
			return Color("#888888")
