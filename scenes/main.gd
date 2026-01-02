extends Node2D

## Main scene controller - connects UI to SimulationEngine

@onready var simulation_engine: SimulationEngine = $SimulationEngine
@onready var code_editor: TextEdit = $UI/CodeEditor
@onready var run_button: Button = $UI/RunButton
@onready var status_label: Label = $UI/StatusLabel
@onready var test_vehicle: Vehicle = $GameWorld/TestVehicle
@onready var test_stoplight: Stoplight = $GameWorld/TestStoplight


func _ready() -> void:
	# Register vehicle with simulation engine
	simulation_engine.register_vehicle(test_vehicle)

	# Register stoplight if it exists
	if test_stoplight:
		simulation_engine.register_stoplight(test_stoplight)

	# Connect UI signals
	run_button.pressed.connect(_on_run_button_pressed)

	# Connect simulation signals
	simulation_engine.simulation_started.connect(_on_simulation_started)
	simulation_engine.simulation_paused.connect(_on_simulation_paused)
	simulation_engine.simulation_ended.connect(_on_simulation_ended)
	simulation_engine.car_reached_destination.connect(_on_car_reached_destination)
	simulation_engine.car_crashed.connect(_on_car_crashed)
	simulation_engine.level_completed.connect(_on_level_completed)
	simulation_engine.level_failed.connect(_on_level_failed)

	# Connect vehicle stoplight signals if vehicle exists
	if test_vehicle:
		test_vehicle.stopped_at_light.connect(_on_car_stopped_at_light)
		test_vehicle.resumed_from_light.connect(_on_car_resumed_from_light)

	# Set initial code (example showing stoplight + car interaction)
	code_editor.text = "stoplight.set_green()\ncar.go()"

	_update_status("Ready - Enter code and press 'Run Code'")


func _on_run_button_pressed() -> void:
	var code = code_editor.text
	if code.strip_edges().is_empty():
		_update_status("Error: No code entered")
		return

	# Reset vehicle position before running
	test_vehicle.reset(Vector2(100, 300), Vector2.RIGHT)

	# Execute the code
	simulation_engine.execute_code(code)


func _on_simulation_started() -> void:
	_update_status("Running...")
	run_button.disabled = true


func _on_simulation_paused() -> void:
	_update_status("Paused (Press Space to resume)")


func _on_simulation_ended(success: bool) -> void:
	run_button.disabled = false
	if success:
		_update_status("Simulation complete!")
	else:
		_update_status("Simulation failed")


func _on_car_reached_destination(car_id: String) -> void:
	_update_status("Car '%s' reached destination!" % car_id)


func _on_car_crashed(car_id: String) -> void:
	_update_status("Car '%s' crashed!" % car_id)


func _on_level_completed(stars: int) -> void:
	_update_status("Level Complete! Stars: %s" % stars)


func _on_level_failed(reason: String) -> void:
	_update_status("Level Failed: %s" % reason)


func _on_car_stopped_at_light(car_id: String, stoplight_id: String) -> void:
	_update_status("Car '%s' stopped at red light '%s'" % [car_id, stoplight_id])


func _on_car_resumed_from_light(car_id: String, stoplight_id: String) -> void:
	_update_status("Car '%s' resumed (light '%s' turned green)" % [car_id, stoplight_id])


func _update_status(message: String) -> void:
	status_label.text = "Status: %s" % message


func _input(event: InputEvent) -> void:
	# Handle R key for reset
	if event is InputEventKey and event.pressed and event.keycode == KEY_R:
		simulation_engine.reset()
		test_vehicle.reset(Vector2(100, 300), Vector2.RIGHT)
		if test_stoplight:
			test_stoplight.reset()
		_update_status("Reset - Ready")
		run_button.disabled = false
