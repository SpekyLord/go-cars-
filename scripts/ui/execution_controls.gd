# execution_controls.gd
extends PanelContainer
class_name ExecutionControls

signal play_pressed
signal pause_pressed
signal stop_pressed
signal step_pressed
signal speed_changed(speed: float)

@onready var play_button: Button = $HBox/PlayButton
@onready var pause_button: Button = $HBox/PauseButton
@onready var stop_button: Button = $HBox/StopButton
@onready var step_button: Button = $HBox/StepButton
@onready var speed_slider: HSlider = $HBox/SpeedSlider
@onready var speed_value_label: Label = $HBox/SpeedValue
@onready var line_label: Label = $HBox/LineLabel
@onready var status_label: Label = $HBox/StatusLabel

var tracer: ExecutionTracer

func _ready() -> void:
	if play_button:
		play_button.pressed.connect(func(): play_pressed.emit())
	if pause_button:
		pause_button.pressed.connect(func(): pause_pressed.emit())
	if stop_button:
		stop_button.pressed.connect(func(): stop_pressed.emit())
	if step_button:
		step_button.pressed.connect(func(): step_pressed.emit())
	if speed_slider:
		speed_slider.value_changed.connect(_on_speed_changed)

	_set_idle_state()

func connect_tracer(execution_tracer: ExecutionTracer) -> void:
	tracer = execution_tracer
	tracer.execution_started.connect(_set_running_state)
	tracer.execution_paused.connect(_set_paused_state)
	tracer.execution_resumed.connect(_set_running_state)
	tracer.execution_finished.connect(_set_idle_state)
	tracer.line_executed.connect(_on_line_executed)

func _set_idle_state() -> void:
	if play_button:
		play_button.disabled = false
	if pause_button:
		pause_button.disabled = true
	if stop_button:
		stop_button.disabled = true
	if step_button:
		step_button.disabled = false
	if status_label:
		status_label.text = "Ready"
	if line_label:
		line_label.text = "Line: -"

func _set_running_state() -> void:
	if play_button:
		play_button.disabled = true
	if pause_button:
		pause_button.disabled = false
	if stop_button:
		stop_button.disabled = false
	if step_button:
		step_button.disabled = true
	if status_label:
		status_label.text = "Running"

func _set_paused_state() -> void:
	if play_button:
		play_button.disabled = false
	if pause_button:
		pause_button.disabled = true
	if stop_button:
		stop_button.disabled = false
	if step_button:
		step_button.disabled = false
	if status_label:
		status_label.text = "Paused"

func _on_line_executed(line: int, _vars: Dictionary) -> void:
	if line_label:
		line_label.text = "Line: %d" % (line + 1)

func _on_speed_changed(value: float) -> void:
	if speed_value_label:
		speed_value_label.text = "%.1fx" % value
	speed_changed.emit(value)
