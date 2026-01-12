extends FloatingWindow
class_name DebuggerPanel

## Debugger panel showing variables and call stack
## Displays current scope variables and function call hierarchy

## Child nodes
var tab_container: TabContainer
var variables_tab: VBoxContainer
var call_stack_tab: VBoxContainer

## Variables display
var variables_tree: Tree
var variables_root: TreeItem

## Call stack display
var call_stack_tree: Tree
var call_stack_root: TreeItem

## Debugger reference
var debugger: Variant = null  # Debugger instance


func _init() -> void:
	window_title = "Debugger"
	min_size = Vector2(350, 400)
	default_size = Vector2(400, 500)
	default_position = Vector2(950, 50)


func _ready() -> void:
	super._ready()
	_setup_debugger_ui()


func _setup_debugger_ui() -> void:
	var content = get_content_container()

	# Tab container
	tab_container = TabContainer.new()
	tab_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_child(tab_container)

	# Variables tab
	variables_tab = VBoxContainer.new()
	variables_tab.name = "Variables"
	tab_container.add_child(variables_tab)

	var variables_label = Label.new()
	variables_label.text = "Variables (Current Scope)"
	variables_tab.add_child(variables_label)

	variables_tree = Tree.new()
	variables_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	variables_tree.hide_root = true
	variables_tree.columns = 3
	variables_tree.set_column_title(0, "Variable")
	variables_tree.set_column_title(1, "Type")
	variables_tree.set_column_title(2, "Value")
	variables_tree.set_column_titles_visible(true)
	variables_tree.set_column_expand(0, true)
	variables_tree.set_column_expand(1, false)
	variables_tree.set_column_expand(2, true)
	variables_tree.set_column_custom_minimum_width(1, 80)
	variables_tab.add_child(variables_tree)

	# Call stack tab
	call_stack_tab = VBoxContainer.new()
	call_stack_tab.name = "Call Stack"
	tab_container.add_child(call_stack_tab)

	var stack_label = Label.new()
	stack_label.text = "Call Stack (Most Recent First)"
	call_stack_tab.add_child(stack_label)

	call_stack_tree = Tree.new()
	call_stack_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	call_stack_tree.hide_root = true
	call_stack_tree.columns = 1
	call_stack_tree.set_column_titles_visible(false)
	call_stack_tab.add_child(call_stack_tree)

	# Initialize tree roots
	variables_root = variables_tree.create_item()
	call_stack_root = call_stack_tree.create_item()


## Set the debugger instance
func set_debugger(dbg: Variant) -> void:
	debugger = dbg
	if debugger:
		debugger.variable_changed.connect(_on_variable_changed)
		debugger.call_stack_changed.connect(_on_call_stack_changed)


## Update variables display
func update_variables(variables: Dictionary) -> void:
	if not variables_tree or not variables_root:
		return

	# Clear existing items
	variables_root.clear_children()

	# Add each variable
	for var_name in variables.keys():
		var value = variables[var_name]
		var item = variables_tree.create_item(variables_root)

		item.set_text(0, var_name)
		item.set_text(1, _get_type_string(value))
		item.set_text(2, _get_value_string(value))

		# Expandable for complex types
		if typeof(value) == TYPE_ARRAY or typeof(value) == TYPE_DICTIONARY:
			_add_complex_type_children(item, value)


## Update call stack display
func update_call_stack(stack: Array) -> void:
	if not call_stack_tree or not call_stack_root:
		return

	# Clear existing items
	call_stack_root.clear_children()

	# Add each stack frame (reverse order - most recent first)
	for i in range(stack.size() - 1, -1, -1):
		var frame = stack[i]
		var item = call_stack_tree.create_item(call_stack_root)

		var text = "%s() - %s:%d" % [
			frame.get("function", "unknown"),
			frame.get("file", ""),
			frame.get("line", 0)
		]
		item.set_text(0, text)


## Add children for complex types (arrays, dictionaries)
func _add_complex_type_children(parent_item: TreeItem, value: Variant) -> void:
	match typeof(value):
		TYPE_ARRAY:
			for i in range(value.size()):
				var child = variables_tree.create_item(parent_item)
				child.set_text(0, "[%d]" % i)
				child.set_text(1, _get_type_string(value[i]))
				child.set_text(2, _get_value_string(value[i]))

		TYPE_DICTIONARY:
			for key in value.keys():
				var child = variables_tree.create_item(parent_item)
				child.set_text(0, str(key))
				child.set_text(1, _get_type_string(value[key]))
				child.set_text(2, _get_value_string(value[key]))


## Get type string for display
func _get_type_string(value: Variant) -> String:
	match typeof(value):
		TYPE_BOOL: return "bool"
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "str"
		TYPE_ARRAY: return "list"
		TYPE_DICTIONARY: return "dict"
		TYPE_NIL: return "None"
		_: return "object"


## Get value string for display
func _get_value_string(value: Variant) -> String:
	match typeof(value):
		TYPE_STRING:
			return '"%s"' % value
		TYPE_ARRAY:
			if value.size() == 0:
				return "[]"
			return "[...] (%d items)" % value.size()
		TYPE_DICTIONARY:
			if value.size() == 0:
				return "{}"
			return "{...} (%d items)" % value.size()
		TYPE_NIL:
			return "None"
		_:
			return str(value)


## Signal handlers
func _on_variable_changed(_var_name: String, _value: Variant) -> void:
	# Refresh entire variable display
	if debugger:
		update_variables(debugger.get_all_variables())


func _on_call_stack_changed(stack: Array) -> void:
	update_call_stack(stack)
