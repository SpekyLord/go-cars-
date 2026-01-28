## Menu Panel for GoCars
## Provides in-game menu options
## Author: Claude Code
## Date: January 2026

extends CanvasLayer

## Signals
signal back_to_levels_pressed()
signal reset_windows_pressed()
signal close_pressed()

@export_group("Dimmer")
@export var dimmer_color: Color = Color(0, 0, 0, 0.6)
@export var dimmer_fade_in: float = 0.12
@export var dimmer_fade_out: float = 0.12
@export var start_hidden: bool = true

## Node references
@onready var panel: Panel = $Panel
@onready var back_button: Button = $Panel/VBoxContainer/BackToLevelsButton
@onready var reset_button: Button = $Panel/VBoxContainer/ResetWindowsButton
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

var _dimmer: ColorRect
var _dimmer_tween: Tween

func _ready() -> void:
	_ensure_dimmer()

	# Normalize initial state (scene may have Panel visible by default).
	if start_hidden:
		panel.visible = false
		visible = false

	_sync_dimmer_immediate(panel.visible)

	# Connect button signals
	back_button.pressed.connect(_on_back_to_levels_pressed)
	reset_button.pressed.connect(_on_reset_windows_pressed)
	close_button.pressed.connect(_on_close_pressed)

## Toggle panel visibility
func toggle() -> void:
	if visible and panel.visible:
		hide_panel()
	else:
		show_panel()

## Show the panel
func show_panel() -> void:
	_ensure_dimmer()
	visible = true
	panel.visible = true
	_fade_dimmer(true)

## Hide the panel
func hide_panel() -> void:
	panel.visible = false
	_fade_dimmer(false)

func _ensure_dimmer() -> void:
	# Reuse an existing Dimmer if someone added one in the scene.
	_dimmer = get_node_or_null("Dimmer") as ColorRect
	if _dimmer == null:
		_dimmer = ColorRect.new()
		_dimmer.name = "Dimmer"
		add_child(_dimmer)
		# Ensure it's behind Panel.
		move_child(_dimmer, 0)

	# Fullscreen dimmer.
	_dimmer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_dimmer.offset_left = 0.0
	_dimmer.offset_top = 0.0
	_dimmer.offset_right = 0.0
	_dimmer.offset_bottom = 0.0

	# Visual + input behavior.
	_dimmer.color = dimmer_color
	_dimmer.mouse_filter = Control.MOUSE_FILTER_STOP # block clicks behind the menu
	_dimmer.visible = false
	_dimmer.modulate.a = 0.0
	_dimmer.z_index = -1000

func _sync_dimmer_immediate(is_showing: bool) -> void:
	if _dimmer == null:
		return
	_dimmer.color = dimmer_color
	_dimmer.visible = is_showing
	_dimmer.modulate.a = 1.0 if is_showing else 0.0

func _fade_dimmer(is_showing: bool) -> void:
	if _dimmer == null:
		return

	_dimmer.color = dimmer_color

	if _dimmer_tween and _dimmer_tween.is_valid():
		_dimmer_tween.kill()
	_dimmer_tween = null

	_dimmer.visible = true
	_dimmer_tween = create_tween()
	_dimmer_tween.set_trans(Tween.TRANS_QUAD)
	_dimmer_tween.set_ease(Tween.EASE_OUT)

	var target_a := 1.0 if is_showing else 0.0
	var time := dimmer_fade_in if is_showing else dimmer_fade_out
	_dimmer_tween.tween_property(_dimmer, "modulate:a", target_a, time)

	if not is_showing:
		_dimmer_tween.finished.connect(func():
			if is_instance_valid(_dimmer):
				_dimmer.visible = false
			# Hide the whole layer after fade-out, so it stops intercepting input.
			visible = false
		)

## Button callbacks
func _on_back_to_levels_pressed() -> void:
	back_to_levels_pressed.emit()

func _on_reset_windows_pressed() -> void:
	reset_windows_pressed.emit()

func _on_close_pressed() -> void:
	close_pressed.emit()
