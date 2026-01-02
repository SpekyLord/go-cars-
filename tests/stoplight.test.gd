extends SceneTree

## Tests for the Stoplight system

func _init():
	print("=".repeat(50))
	print("Running Stoplight tests...")
	print("=".repeat(50))

	test_initial_state()
	test_set_red()
	test_set_green()
	test_set_yellow()
	test_get_state()
	test_should_stop()
	test_state_signal()

	print("=".repeat(50))
	print("All Stoplight tests passed!")
	print("=".repeat(50))
	quit()


func test_initial_state():
	var stoplight = Stoplight.new()
	assert(stoplight.current_state == Stoplight.LightState.RED, "Initial state should be RED")
	assert(stoplight.get_state() == "red", "get_state() should return 'red'")
	print("  [PASS] test_initial_state")


func test_set_red():
	var stoplight = Stoplight.new()
	stoplight.set_green()  # Change first
	stoplight.set_red()
	assert(stoplight.current_state == Stoplight.LightState.RED, "State should be RED after set_red()")
	assert(stoplight.is_red() == true, "is_red() should return true")
	print("  [PASS] test_set_red")


func test_set_green():
	var stoplight = Stoplight.new()
	stoplight.set_green()
	assert(stoplight.current_state == Stoplight.LightState.GREEN, "State should be GREEN after set_green()")
	assert(stoplight.is_green() == true, "is_green() should return true")
	print("  [PASS] test_set_green")


func test_set_yellow():
	var stoplight = Stoplight.new()
	stoplight.set_yellow()
	assert(stoplight.current_state == Stoplight.LightState.YELLOW, "State should be YELLOW after set_yellow()")
	assert(stoplight.is_yellow() == true, "is_yellow() should return true")
	print("  [PASS] test_set_yellow")


func test_get_state():
	var stoplight = Stoplight.new()

	stoplight.set_red()
	assert(stoplight.get_state() == "red", "get_state() should return 'red'")

	stoplight.set_green()
	assert(stoplight.get_state() == "green", "get_state() should return 'green'")

	stoplight.set_yellow()
	assert(stoplight.get_state() == "yellow", "get_state() should return 'yellow'")

	print("  [PASS] test_get_state")


func test_should_stop():
	var stoplight = Stoplight.new()

	# Red light = should stop
	stoplight.set_red()
	assert(stoplight.should_stop() == true, "should_stop() should be true for RED")

	# Yellow light = should stop (caution)
	stoplight.set_yellow()
	assert(stoplight.should_stop() == true, "should_stop() should be true for YELLOW")

	# Green light = should NOT stop
	stoplight.set_green()
	assert(stoplight.should_stop() == false, "should_stop() should be false for GREEN")

	print("  [PASS] test_should_stop")


func test_state_signal():
	var stoplight = Stoplight.new()
	var signal_received = false
	var received_id = ""
	var received_state = ""

	# Connect to signal
	stoplight.state_changed.connect(func(id, state):
		signal_received = true
		received_id = id
		received_state = state
	)

	# Change state
	stoplight.set_green()

	assert(signal_received == true, "state_changed signal should be emitted")
	assert(received_id == "stoplight1", "Signal should include stoplight_id")
	assert(received_state == "green", "Signal should include new state")

	print("  [PASS] test_state_signal")
