## Menu Panel for GoCars
## Provides in-game menu options
## Author: Claude Code
## Date: January 2026

extends CanvasLayer

## Signals
signal back_to_levels_pressed()
signal reset_windows_pressed()
signal close_pressed()

## Node references
@onready var panel: Panel = $Panel
@onready var back_button: Button = $Panel/VBoxContainer/BackToLevelsButton
@onready var reset_button: Button = $Panel/VBoxContainer/ResetWindowsButton
@onready var close_button: Button = $Panel/VBoxContainer/CloseButton

func _ready() -> void:
	# Connect button signals
	back_button.pressed.connect(_on_back_to_levels_pressed)
	reset_button.pressed.connect(_on_reset_windows_pressed)
	close_button.pressed.connect(_on_close_pressed)

## Toggle panel visibility
func toggle() -> void:
	panel.visible = !panel.visible

## Show the panel
func show_panel() -> void:
	panel.visible = true

## Hide the panel
func hide_panel() -> void:
	panel.visible = false

## Button callbacks
func _on_back_to_levels_pressed() -> void:
	back_to_levels_pressed.emit()

func _on_reset_windows_pressed() -> void:
	reset_windows_pressed.emit()

func _on_close_pressed() -> void:
	close_pressed.emit()
