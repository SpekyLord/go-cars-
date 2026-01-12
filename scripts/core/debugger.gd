extends Node
class_name Debugger

## Python debugger for GoCars
## Handles breakpoints, stepping, variable inspection, and call stack tracking

## Signals
signal breakpoint_hit(line: int, file: String)
signal step_complete(line: int, file: String)
signal execution_finished()
signal variable_changed(var_name: String, value: Variant)
signal call_stack_changed(stack: Array)

## Debugger state
enum State { IDLE, RUNNING, PAUSED, STEPPING }
var current_state: State = State.IDLE

## Breakpoints: Dictionary<filename, Array<line_numbers>>
var breakpoints: Dictionary = {}

## Current execution state
var current_file: String = ""
var current_line: int = -1
var call_stack: Array[Dictionary] = []  # [{function: String, file: String, line: int}]

## Variable scopes
var global_variables: Dictionary = {}
var local_variables: Dictionary = {}

## Step control
var step_mode: String = ""  # "", "over", "into", "out"
var step_depth: int = 0  # Track function call depth for step over/out

## Reference to interpreter
var interpreter: Variant = null  # PythonInterpreter instance


func _init() -> void:
	pass


## Set the interpreter instance
func set_interpreter(interp: Variant) -> void:
	interpreter = interp


## Add a breakpoint
func add_breakpoint(file: String, line: int) -> void:
	if not breakpoints.has(file):
		breakpoints[file] = []

	if line not in breakpoints[file]:
		breakpoints[file].append(line)
		breakpoints[file].sort()


## Remove a breakpoint
func remove_breakpoint(file: String, line: int) -> void:
	if not breakpoints.has(file):
		return

	if line in breakpoints[file]:
		breakpoints[file].erase(line)


## Toggle a breakpoint
func toggle_breakpoint(file: String, line: int) -> bool:
	"""Toggle breakpoint and return true if now active"""
	if has_breakpoint(file, line):
		remove_breakpoint(file, line)
		return false
	else:
		add_breakpoint(file, line)
		return true


## Check if breakpoint exists
func has_breakpoint(file: String, line: int) -> bool:
	if not breakpoints.has(file):
		return false
	return line in breakpoints[file]


## Get all breakpoints for a file
func get_breakpoints(file: String) -> Array:
	if breakpoints.has(file):
		return breakpoints[file]
	return []


## Clear all breakpoints
func clear_all_breakpoints() -> void:
	breakpoints.clear()


## Clear breakpoints for a specific file
func clear_file_breakpoints(file: String) -> void:
	if breakpoints.has(file):
		breakpoints.erase(file)


## Start execution (run mode)
func start_execution() -> void:
	current_state = State.RUNNING
	step_mode = ""
	step_depth = 0


## Pause execution
func pause_execution() -> void:
	if current_state == State.RUNNING:
		current_state = State.PAUSED


## Resume execution
func resume_execution() -> void:
	if current_state == State.PAUSED:
		current_state = State.RUNNING


## Step over (F10)
func step_over() -> void:
	current_state = State.STEPPING
	step_mode = "over"
	step_depth = call_stack.size()


## Step into (F11)
func step_into() -> void:
	current_state = State.STEPPING
	step_mode = "into"
	step_depth = call_stack.size()


## Step out (Shift+F11)
func step_out() -> void:
	current_state = State.STEPPING
	step_mode = "out"
	step_depth = call_stack.size() - 1


## Called by interpreter before executing each line
func on_line_execute(file: String, line: int) -> bool:
	"""Returns true if execution should pause"""
	current_file = file
	current_line = line

	# Check for breakpoint
	if has_breakpoint(file, line):
		current_state = State.PAUSED
		breakpoint_hit.emit(line, file)
		return true

	# Handle stepping
	if current_state == State.STEPPING:
		match step_mode:
			"over":
				# Pause if at same depth or shallower
				if call_stack.size() <= step_depth:
					current_state = State.PAUSED
					step_complete.emit(line, file)
					step_mode = ""
					return true
			"into":
				# Always pause on next line
				current_state = State.PAUSED
				step_complete.emit(line, file)
				step_mode = ""
				return true
			"out":
				# Pause when back to parent function
				if call_stack.size() <= step_depth:
					current_state = State.PAUSED
					step_complete.emit(line, file)
					step_mode = ""
					return true

	# Continue execution
	return current_state == State.PAUSED


## Push function call onto stack
func push_call(function_name: String, file: String, line: int) -> void:
	call_stack.append({
		"function": function_name,
		"file": file,
		"line": line
	})
	call_stack_changed.emit(call_stack)


## Pop function call from stack
func pop_call() -> void:
	if call_stack.size() > 0:
		call_stack.pop_back()
		call_stack_changed.emit(call_stack)


## Update variable in current scope
func set_variable(var_name: String, value: Variant, is_global: bool = false) -> void:
	if is_global:
		global_variables[var_name] = value
	else:
		local_variables[var_name] = value

	variable_changed.emit(var_name, value)


## Get variable from current scope
func get_variable(var_name: String) -> Variant:
	if local_variables.has(var_name):
		return local_variables[var_name]
	elif global_variables.has(var_name):
		return global_variables[var_name]
	return null


## Get all variables in current scope
func get_all_variables() -> Dictionary:
	var all_vars = global_variables.duplicate()
	# Local variables override globals
	for key in local_variables:
		all_vars[key] = local_variables[key]
	return all_vars


## Clear local scope (when exiting function)
func clear_local_scope() -> void:
	local_variables.clear()


## Reset debugger state
func reset() -> void:
	current_state = State.IDLE
	current_file = ""
	current_line = -1
	call_stack.clear()
	global_variables.clear()
	local_variables.clear()
	step_mode = ""
	step_depth = 0
	call_stack_changed.emit(call_stack)


## Check if currently paused
func is_paused() -> bool:
	return current_state == State.PAUSED


## Check if currently running
func is_running() -> bool:
	return current_state == State.RUNNING or current_state == State.STEPPING


## Get current execution line
func get_current_line() -> int:
	return current_line


## Get current file
func get_current_file() -> String:
	return current_file


## Get call stack
func get_call_stack() -> Array:
	return call_stack.duplicate()
