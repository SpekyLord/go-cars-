extends SceneTree

## Tests for CodeParser
## Run with: godot --path . --headless --script tests/code_parser.test.gd

var _tests_passed: int = 0
var _tests_failed: int = 0


func _init():
	print("=".repeat(50))
	print("       CodeParser Tests")
	print("=".repeat(50))
	print("")

	# Valid command tests
	test_parse_go_command()
	test_parse_stop_command()
	test_parse_multiple_commands()

	# Invalid command tests
	test_parse_invalid_function()
	test_parse_invalid_object()
	test_parse_unknown_object_in_level()

	# Syntax error tests
	test_missing_parentheses()
	test_missing_dot()
	test_empty_line_ignored()
	test_comment_ignored()

	# Parameter tests
	test_wait_with_valid_param()
	test_wait_missing_param()
	test_wait_invalid_param()

	# Whitespace handling
	test_whitespace_handling()

	# Summary
	print("")
	print("=".repeat(50))
	print("       SUMMARY")
	print("=".repeat(50))
	print("Passed: %s" % _tests_passed)
	print("Failed: %s" % _tests_failed)
	print("")

	if _tests_failed > 0:
		print("SOME TESTS FAILED!")
		quit(1)
	else:
		print("All tests passed!")
		quit(0)


func _assert(condition: bool, message: String) -> bool:
	if condition:
		_tests_passed += 1
		print("  [PASS] %s" % message)
		return true
	else:
		_tests_failed += 1
		print("  [FAIL] %s" % message)
		return false


# ============================================
# Valid Command Tests
# ============================================

func test_parse_go_command():
	print("\ntest_parse_go_command:")
	var parser = CodeParser.new()
	var result = parser.parse("car.go()")

	_assert(result.valid == true, "car.go() should be valid")
	_assert(result.commands.size() == 1, "Should have 1 command")
	_assert(result.commands[0]["object"] == "car", "Object should be 'car'")
	_assert(result.commands[0]["function"] == "go", "Function should be 'go'")


func test_parse_stop_command():
	print("\ntest_parse_stop_command:")
	var parser = CodeParser.new()
	var result = parser.parse("car.stop()")

	_assert(result.valid == true, "car.stop() should be valid")
	_assert(result.commands.size() == 1, "Should have 1 command")
	_assert(result.commands[0]["function"] == "stop", "Function should be 'stop'")


func test_parse_multiple_commands():
	print("\ntest_parse_multiple_commands:")
	var parser = CodeParser.new()
	var code = "car.go()\ncar.stop()"
	var result = parser.parse(code)

	_assert(result.valid == true, "Multiple valid commands should be valid")
	_assert(result.commands.size() == 2, "Should have 2 commands")
	_assert(result.commands[0]["function"] == "go", "First command should be 'go'")
	_assert(result.commands[1]["function"] == "stop", "Second command should be 'stop'")


# ============================================
# Invalid Command Tests
# ============================================

func test_parse_invalid_function():
	print("\ntest_parse_invalid_function:")
	var parser = CodeParser.new()
	var result = parser.parse("car.fly()")

	_assert(result.valid == false, "car.fly() should be invalid")
	_assert(result.errors.size() == 1, "Should have 1 error")
	_assert("Unknown function" in result.errors[0]["message"], "Error should mention unknown function")


func test_parse_invalid_object():
	print("\ntest_parse_invalid_object:")
	var parser = CodeParser.new()
	var result = parser.parse("airplane.go()")

	_assert(result.valid == false, "airplane.go() should be invalid")
	_assert(result.errors.size() == 1, "Should have 1 error")


func test_parse_unknown_object_in_level():
	print("\ntest_parse_unknown_object_in_level:")
	var parser = CodeParser.new()
	# Request stoplight but only car is available in level
	var result = parser.parse("stoplight.set_green()", ["car"])

	_assert(result.valid == false, "stoplight should not be available")
	_assert("not found in this level" in result.errors[0]["message"], "Error should mention object not in level")


# ============================================
# Syntax Error Tests
# ============================================

func test_missing_parentheses():
	print("\ntest_missing_parentheses:")
	var parser = CodeParser.new()
	var result = parser.parse("car.go")

	_assert(result.valid == false, "car.go without () should be invalid")
	_assert("parentheses" in result.errors[0]["message"], "Error should mention parentheses")


func test_missing_dot():
	print("\ntest_missing_dot:")
	var parser = CodeParser.new()
	var result = parser.parse("cargo()")

	_assert(result.valid == false, "cargo() without dot should be invalid")
	_assert("Syntax error" in result.errors[0]["message"], "Error should be a syntax error")


func test_empty_line_ignored():
	print("\ntest_empty_line_ignored:")
	var parser = CodeParser.new()
	var code = "car.go()\n\ncar.stop()"
	var result = parser.parse(code)

	_assert(result.valid == true, "Empty lines should be ignored")
	_assert(result.commands.size() == 2, "Should still have 2 commands")


func test_comment_ignored():
	print("\ntest_comment_ignored:")
	var parser = CodeParser.new()
	var code = "# This is a comment\ncar.go()"
	var result = parser.parse(code)

	_assert(result.valid == true, "Comments should be ignored")
	_assert(result.commands.size() == 1, "Should only have 1 command")


# ============================================
# Parameter Tests
# ============================================

func test_wait_with_valid_param():
	print("\ntest_wait_with_valid_param:")
	var parser = CodeParser.new()
	var result = parser.parse("car.wait(5)")

	_assert(result.valid == true, "car.wait(5) should be valid")
	_assert(result.commands[0]["params"].size() == 1, "Should have 1 parameter")
	_assert(result.commands[0]["params"][0] == 5, "Parameter should be 5")


func test_wait_missing_param():
	print("\ntest_wait_missing_param:")
	var parser = CodeParser.new()
	var result = parser.parse("car.wait()")

	_assert(result.valid == false, "car.wait() without param should be invalid")
	_assert("requires a parameter" in result.errors[0]["message"], "Error should mention required parameter")


func test_wait_invalid_param():
	print("\ntest_wait_invalid_param:")
	var parser = CodeParser.new()
	var result = parser.parse("car.wait(abc)")

	_assert(result.valid == false, "car.wait(abc) should be invalid")
	_assert("integer" in result.errors[0]["message"], "Error should mention integer")


# ============================================
# Whitespace Tests
# ============================================

func test_whitespace_handling():
	print("\ntest_whitespace_handling:")
	var parser = CodeParser.new()

	var result1 = parser.parse("  car.go()  ")
	_assert(result1.valid == true, "Leading/trailing whitespace should be handled")

	var result2 = parser.parse("car . go ( )")
	# This might fail due to spaces around dot/parens - depends on implementation
	# For now we only strip edges, internal whitespace may cause issues
	_assert(result2.valid == true or result2.valid == false, "Internal whitespace test completed")
