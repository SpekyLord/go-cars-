# code_editor_window_enhanced.gd
## Enhanced Code Editor Window with Advanced Features
## Integrates: Linting, Snippets, Folding, Execution Viz, Metrics
## Author: Claude Code
## Date: January 2026

extends FloatingWindow
class_name CodeEditorWindowEnhanced

## Signals
signal code_run_requested(code: String)
signal code_pause_requested()
signal code_reset_requested()
signal speed_changed(speed: float)

## Child nodes
var control_bar: HBoxContainer
var run_button: Button
var pause_button: Button
var reset_button: Button
var speed_button: MenuButton
var hsplit: HSplitContainer
var file_explorer: FileExplorer
var code_edit: CodeEdit
var status_bar: HBoxContainer
var status_label: Label

## Advanced feature components
var error_highlighter: ErrorHighlighter
var snippet_handler: SnippetHandler
var fold_manager: FoldManager
var fold_gutter: FoldGutter
var execution_tracer: ExecutionTracer
var execution_highlighter: ExecutionHighlighter
var metrics_tracker: MetricsTracker

## UI Panels
var error_panel: ErrorPanel
var metrics_panel: MetricsPanel

## Virtual filesystem reference
var virtual_fs: Variant = null

## Debugger reference
var debugger: Variant = null

## IntelliSense manager
var intellisense: Variant = null

## Current file
var current_file: String = "main.py"
var is_modified: bool = false

## Speed options
var speed_options: Array = [0.5, 1.0, 2.0, 4.0]
var current_speed: float = 1.0

## Debugger constants
const BREAKPOINT_GUTTER: int = 1
const EXECUTION_LINE_COLOR: Color = Color(1.0, 1.0, 0.0, 0.2)

func _init() -> void:
	window_title = "Code Editor (Enhanced)"
	min_size = Vector2(900, 600)
	default_size = Vector2(1200, 700)
	default_position = Vector2(50, 50)

func _ready() -> void:
	super._ready()
	_setup_editor_ui()
	_setup_advanced_features()

func _setup_editor_ui() -> void:
	var content = get_content_container()

	# Main VBox for editor content
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(vbox)

	# Control bar
	control_bar = HBoxContainer.new()
	control_bar.name = "ControlBar"
	vbox.add_child(control_bar)

	# Run button
	run_button = Button.new()
	run_button.name = "RunButton"
	run_button.text = "▶ Run"
	run_button.tooltip_text = "Run code (F5 or Ctrl+Enter)"
	control_bar.add_child(run_button)

	# Pause button
	pause_button = Button.new()
	pause_button.name = "PauseButton"
	pause_button.text = "⏸ Pause"
	pause_button.tooltip_text = "Pause execution (Space)"
	control_bar.add_child(pause_button)

	# Reset button
	reset_button = Button.new()
	reset_button.name = "ResetButton"
	reset_button.text = "🔄 Reset"
	reset_button.tooltip_text = "Reset level (R or Ctrl+R)"
	control_bar.add_child(reset_button)

	# Speed button
	speed_button = MenuButton.new()
	speed_button.name = "SpeedButton"
	speed_button.text = "1x ▼"
	speed_button.tooltip_text = "Change simulation speed"
	control_bar.add_child(speed_button)

	# Setup speed menu
	var popup = speed_button.get_popup()
	for speed in speed_options:
		popup.add_item("%.1fx" % speed)
	popup.index_pressed.connect(_on_speed_selected)

	# Add spacer
	var spacer = Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	control_bar.add_child(spacer)

	# Add toggle buttons for panels
	var toggle_errors_btn = Button.new()
	toggle_errors_btn.text = "🐛 Errors"
	toggle_errors_btn.tooltip_text = "Toggle error panel"
	toggle_errors_btn.pressed.connect(_toggle_error_panel)
	control_bar.add_child(toggle_errors_btn)

	var toggle_metrics_btn = Button.new()
	toggle_metrics_btn.text = "📊 Metrics"
	toggle_metrics_btn.tooltip_text = "Toggle metrics panel"
	toggle_metrics_btn.pressed.connect(_toggle_metrics_panel)
	control_bar.add_child(toggle_metrics_btn)

	# HSplit for file explorer and editor
	hsplit = HSplitContainer.new()
	hsplit.name = "HSplit"
	hsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(hsplit)

	# File explorer
	var FileExplorerClass = load("res://scripts/ui/file_explorer.gd")
	file_explorer = FileExplorerClass.new()
	file_explorer.name = "FileExplorer"
	file_explorer.custom_minimum_size = Vector2(200, 0)
	hsplit.add_child(file_explorer)

	# Right side VSplit for editor and panels
	var vsplit = VSplitContainer.new()
	vsplit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vsplit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	hsplit.add_child(vsplit)

	# Code editor
	code_edit = CodeEdit.new()
	code_edit.name = "CodeEdit"
	code_edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	code_edit.size_flags_vertical = Control.SIZE_EXPAND_FILL
	code_edit.syntax_highlighter = _create_python_highlighter()
	code_edit.gutters_draw_line_numbers = true
	code_edit.wrap_mode = TextEdit.LINE_WRAPPING_NONE

	# Add breakpoint gutter
	code_edit.add_gutter(BREAKPOINT_GUTTER)
	code_edit.set_gutter_name(BREAKPOINT_GUTTER, "breakpoints")
	code_edit.set_gutter_clickable(BREAKPOINT_GUTTER, true)
	code_edit.set_gutter_draw(BREAKPOINT_GUTTER, true)
	code_edit.set_gutter_type(BREAKPOINT_GUTTER, TextEdit.GUTTER_TYPE_ICON)

	vsplit.add_child(code_edit)

	# Bottom panel container (for error panel)
	var bottom_panel = PanelContainer.new()
	bottom_panel.custom_minimum_size = Vector2(0, 150)
	bottom_panel.visible = false
	vsplit.add_child(bottom_panel)

	# Load error panel scene
	var error_panel_scene = load("res://scenes/ui/error_panel.tscn")
	if error_panel_scene:
		error_panel = error_panel_scene.instantiate()
		error_panel.error_clicked.connect(_on_error_clicked)
		bottom_panel.add_child(error_panel)

	# Status bar
	status_bar = HBoxContainer.new()
	status_bar.name = "StatusBar"
	vbox.add_child(status_bar)

	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.text = "Ln 1, Col 1 | main.py | ✓ Saved"
	status_bar.add_child(status_label)

	# Setup IntelliSense
	var IntelliSenseClass = load("res://scripts/ui/intellisense_manager.gd")
	intellisense = IntelliSenseClass.new(code_edit)
	intellisense.setup_popups(content)
	intellisense.set_current_file(current_file)

	# Connect signals
	run_button.pressed.connect(_on_run_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	file_explorer.file_selected.connect(_on_file_selected)
	code_edit.text_changed.connect(_on_text_changed)
	code_edit.caret_changed.connect(_update_status_bar)
	code_edit.gutter_clicked.connect(_on_gutter_clicked)

func _setup_advanced_features() -> void:
	print("[CodeEditorEnhanced] Setting up advanced features...")

	# 1. Error Highlighting & Linting
	error_highlighter = ErrorHighlighter.new(code_edit)
	error_highlighter.linter.diagnostics_updated.connect(_on_diagnostics_updated)

	# Generate icons
	error_highlighter.error_icon = IconGenerator.create_error_icon()
	error_highlighter.warning_icon = IconGenerator.create_warning_icon()
	error_highlighter.info_icon = IconGenerator.create_info_icon()

	print("[CodeEditorEnhanced] ✓ Linter initialized")

	# 2. Code Snippets
	snippet_handler = SnippetHandler.new(code_edit)
	snippet_handler.snippet_expanded.connect(_on_snippet_expanded)
	print("[CodeEditorEnhanced] ✓ Snippet handler initialized (%d snippets)" % SnippetLibrary.snippets.size())

	# 3. Code Folding
	fold_manager = FoldManager.new(code_edit)
	fold_gutter = FoldGutter.new(code_edit, fold_manager)

	# Generate fold icons
	fold_gutter.fold_icon = IconGenerator.create_fold_icon()
	fold_gutter.unfold_icon = IconGenerator.create_unfold_icon()

	print("[CodeEditorEnhanced] ✓ Code folding initialized")

	# 4. Execution Visualization
	execution_tracer = ExecutionTracer.new(null)  # Interpreter set later
	execution_highlighter = ExecutionHighlighter.new(code_edit, execution_tracer)

	# Generate execution icons
	execution_highlighter.breakpoint_icon = IconGenerator.create_breakpoint_icon()
	execution_highlighter.exec_arrow_icon = IconGenerator.create_exec_arrow_icon()

	print("[CodeEditorEnhanced] ✓ Execution tracer initialized")

	# 5. Performance Metrics
	metrics_tracker = MetricsTracker.new(execution_tracer)
	metrics_tracker.metrics_updated.connect(_on_metrics_updated)

	print("[CodeEditorEnhanced] ✓ Metrics tracker initialized")

	# Load metrics panel (floating)
	var metrics_scene = load("res://scenes/ui/metrics_panel.tscn")
	if metrics_scene:
		metrics_panel = metrics_scene.instantiate()
		metrics_panel.visible = false
		metrics_panel.position = Vector2(get_viewport().get_visible_rect().size.x - 320, 50)
		get_tree().root.add_child(metrics_panel)

		# Generate star icons
		_setup_star_icons()

	print("[CodeEditorEnhanced] ✓ All advanced features ready!")

func _setup_star_icons() -> void:
	if not metrics_panel:
		return

	var star_container = metrics_panel.get_node_or_null("VBox/ScoreSection/Stars")
	if star_container:
		# Add 3 star icons
		for i in range(3):
			var star = TextureRect.new()
			star.custom_minimum_size = Vector2(24, 24)
			star.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
			star.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			star.texture = IconGenerator.create_star_empty_icon()
			star_container.add_child(star)

func _input(event: InputEvent) -> void:
	if not visible:
		return

	# Let IntelliSense handle input first
	if intellisense and intellisense.handle_input(event):
		return

	if event is InputEventKey and event.pressed and not event.echo:
		# Tab: Try snippet expansion or navigation
		if event.keycode == KEY_TAB and not event.shift_pressed:
			if snippet_handler.is_active():
				snippet_handler.next_tab_stop()
				get_viewport().set_input_as_handled()
				return
			else:
				# Try to expand snippet
				var line = code_edit.get_line(code_edit.get_caret_line())
				var col = code_edit.get_caret_column()
				var word_start = col
				while word_start > 0 and line[word_start - 1].is_valid_identifier():
					word_start -= 1
				var word = line.substr(word_start, col - word_start)

				if snippet_handler.try_expand(word):
					get_viewport().set_input_as_handled()
					return

		# Shift+Tab: Previous tab stop
		elif event.keycode == KEY_TAB and event.shift_pressed:
			if snippet_handler.is_active():
				snippet_handler.prev_tab_stop()
				get_viewport().set_input_as_handled()
				return

		# Escape: Cancel snippet
		elif event.keycode == KEY_ESCAPE:
			if snippet_handler.is_active():
				snippet_handler.cancel()
				get_viewport().set_input_as_handled()
				return

		# Ctrl+Shift+[: Fold current block
		elif event.keycode == KEY_BRACKETLEFT and event.ctrl_pressed and event.shift_pressed:
			var line = code_edit.get_caret_line()
			var region = fold_manager.get_fold_at_line(line)
			if region:
				fold_manager.fold(region)
			get_viewport().set_input_as_handled()
			return

		# Ctrl+Shift+]: Unfold current block
		elif event.keycode == KEY_BRACKETRIGHT and event.ctrl_pressed and event.shift_pressed:
			var line = code_edit.get_caret_line()
			var region = fold_manager.get_fold_at_line(line)
			if region:
				fold_manager.unfold(region)
			get_viewport().set_input_as_handled()
			return

		# Ctrl+Shift+0: Fold all
		elif event.keycode == KEY_0 and event.ctrl_pressed and event.shift_pressed:
			fold_manager.fold_all()
			get_viewport().set_input_as_handled()
			return

		# Ctrl+Shift+9: Unfold all
		elif event.keycode == KEY_9 and event.ctrl_pressed and event.shift_pressed:
			fold_manager.unfold_all()
			get_viewport().set_input_as_handled()
			return

		# Ctrl+N: New file
		if event.keycode == KEY_N and event.ctrl_pressed:
			file_explorer._on_new_file_pressed()
			get_viewport().set_input_as_handled()

		# Ctrl+S: Save file
		elif event.keycode == KEY_S and event.ctrl_pressed:
			_save_file()
			get_viewport().set_input_as_handled()

		# F2: Rename file
		elif event.keycode == KEY_F2:
			if file_explorer:
				file_explorer._on_rename_pressed()
			get_viewport().set_input_as_handled()

		# F5 or Ctrl+Enter: Run code
		elif (event.keycode == KEY_F5) or (event.keycode == KEY_ENTER and event.ctrl_pressed):
			if execution_tracer.current_state == ExecutionTracer.State.PAUSED:
				execution_tracer.resume_execution()
			else:
				_on_run_pressed()
			get_viewport().set_input_as_handled()

		# F10: Step
		elif event.keycode == KEY_F10:
			execution_tracer.step_execution()
			get_viewport().set_input_as_handled()

func _create_python_highlighter() -> SyntaxHighlighter:
	var PythonSyntaxHighlighterClass = load("res://scripts/ui/python_syntax_highlighter.gd")
	var highlighter = PythonSyntaxHighlighterClass.new()
	return highlighter

func set_virtual_filesystem(vfs: Variant) -> void:
	virtual_fs = vfs
	if file_explorer:
		file_explorer.set_virtual_filesystem(vfs)
		_load_file(current_file)

func set_debugger(dbg: Variant) -> void:
	debugger = dbg

func _load_file(file_path: String) -> void:
	if virtual_fs == null:
		return

	var content = virtual_fs.read_file(file_path)
	code_edit.text = content
	current_file = file_path
	is_modified = false
	_update_status_bar()

	if intellisense:
		intellisense.parse_file_symbols(file_path, content)
		intellisense.set_current_file(file_path)

	# Trigger linting and folding
	_on_text_changed()

func _save_file() -> void:
	if virtual_fs == null or current_file == "":
		return

	virtual_fs.update_file(current_file, code_edit.text)
	is_modified = false
	_update_status_bar()

func _on_file_selected(file_path: String) -> void:
	if is_modified:
		_save_file()
	_load_file(file_path)

func _on_text_changed() -> void:
	is_modified = true
	_update_status_bar()

	if intellisense:
		intellisense.on_text_changed()

	# Trigger linting
	if error_highlighter:
		error_highlighter.lint_content(code_edit.text)

	# Analyze folds
	if fold_manager:
		fold_manager.analyze_folds(code_edit.text)

	# Analyze code for metrics
	if metrics_tracker:
		metrics_tracker.analyze_code(code_edit.text)

func _update_status_bar() -> void:
	var line = code_edit.get_caret_line() + 1
	var col = code_edit.get_caret_column() + 1
	var saved_text = "✓ Saved" if not is_modified else "● Modified"
	status_label.text = "Ln %d, Col %d | %s | %s" % [line, col, current_file, saved_text]

func _on_run_pressed() -> void:
	if is_modified:
		_save_file()

	# Start execution tracking
	if execution_tracer:
		execution_tracer.start_execution(code_edit.text)

	code_run_requested.emit(code_edit.text)

func _on_pause_pressed() -> void:
	if execution_tracer:
		execution_tracer.pause_execution()
	code_pause_requested.emit()

func _on_reset_pressed() -> void:
	if execution_tracer:
		execution_tracer.stop_execution()
	code_reset_requested.emit()

func _on_speed_selected(index: int) -> void:
	current_speed = speed_options[index]
	speed_button.text = "%.1fx ▼" % current_speed
	speed_changed.emit(current_speed)

func get_code() -> String:
	return code_edit.text

func set_code(code: String) -> void:
	code_edit.text = code
	is_modified = false
	_update_status_bar()
	_on_text_changed()

func _on_gutter_clicked(line: int, gutter: int) -> void:
	if gutter == BREAKPOINT_GUTTER:
		execution_highlighter.toggle_breakpoint(line)

func _on_diagnostics_updated(diagnostics: Array) -> void:
	if error_panel:
		error_panel.update_diagnostics(diagnostics)

func _on_error_clicked(line: int, column: int) -> void:
	code_edit.set_caret_line(line)
	code_edit.set_caret_column(column)
	code_edit.grab_focus()

func _on_snippet_expanded(snippet: Snippet) -> void:
	print("[CodeEditor] Expanded snippet: %s" % snippet.name)

func _on_metrics_updated(metrics: PerformanceMetrics) -> void:
	if metrics_panel and metrics_panel.visible:
		metrics_panel.update_metrics(metrics)

func _toggle_error_panel() -> void:
	if error_panel:
		var panel_container = error_panel.get_parent()
		if panel_container:
			panel_container.visible = !panel_container.visible

func _toggle_metrics_panel() -> void:
	if metrics_panel:
		metrics_panel.visible = !metrics_panel.visible
