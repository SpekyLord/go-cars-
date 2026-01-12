extends SyntaxHighlighter
class_name PythonSyntaxHighlighter

## Custom Python-like syntax highlighter for GoCars code editor
## Provides comprehensive token highlighting including keywords, strings, numbers, comments, etc.

# Color scheme (VS Code-inspired Python theme)
var color_keyword: Color = Color("#FF6B9D")       # Pink
var color_builtin: Color = Color("#66D9EF")       # Cyan
var color_string: Color = Color("#E6DB74")        # Yellow
var color_number: Color = Color("#AE81FF")        # Purple
var color_comment: Color = Color("#75715E")       # Gray
var color_operator: Color = Color("#F92672")      # Red-pink
var color_decorator: Color = Color("#A6E22E")     # Green
var color_function: Color = Color("#A6E22E")      # Green
var color_default: Color = Color("#F8F8F2")       # White

# Python keywords
var keywords: Array[String] = [
	"if", "else", "elif", "while", "for", "def", "return", "class",
	"import", "from", "as", "try", "except", "finally", "with",
	"lambda", "yield", "pass", "break", "continue", "and", "or",
	"not", "in", "is", "True", "False", "None", "async", "await",
	"raise", "assert", "del", "global", "nonlocal"
]

# Built-in functions
var builtins: Array[String] = [
	"print", "len", "range", "int", "str", "float", "list", "dict",
	"set", "tuple", "bool", "type", "isinstance", "input", "open",
	"abs", "min", "max", "sum", "all", "any", "enumerate", "zip",
	"map", "filter", "sorted", "reversed"
]

# Operators (for pattern matching)
var operators: Array[String] = [
	"==", "!=", "<=", ">=", "+=", "-=", "*=", "/=", "//=", "%=", "**=",
	"=", "<", ">", "+", "-", "*", "/", "//", "%", "**"
]

# State tracking for multi-line strings
var in_multiline_string: bool = false
var multiline_delimiter: String = ""


func _get_line_syntax_highlighting(line_number: int) -> Dictionary:
	var line_text: String = get_text_edit().get_line(line_number)
	var result: Dictionary = {}

	# Handle empty lines
	if line_text.length() == 0:
		return result

	# Check for decorator line (starts with @)
	if line_text.strip_edges().begins_with("@"):
		_highlight_entire_line(result, 0, line_text.length(), color_decorator)
		return result

	# Check for comment line (starts with #)
	var stripped = line_text.strip_edges()
	if stripped.begins_with("#"):
		_highlight_entire_line(result, 0, line_text.length(), color_comment)
		return result

	# Process character by character
	var i: int = 0
	var line_length: int = line_text.length()

	while i < line_length:
		var c: String = line_text[i]

		# Skip whitespace
		if c == " " or c == "\t":
			i += 1
			continue

		# Check for comment (# to end of line)
		if c == "#":
			_highlight_range(result, i, line_length, color_comment)
			break

		# Check for strings (single, double, triple quotes)
		if c == '"' or c == "'":
			var end_pos = _find_string_end(line_text, i)
			_highlight_range(result, i, end_pos, color_string)
			i = end_pos
			continue

		# Check for numbers
		if c.is_valid_int() or (c == "." and i + 1 < line_length and line_text[i + 1].is_valid_int()):
			var end_pos = _find_number_end(line_text, i)
			_highlight_range(result, i, end_pos, color_number)
			i = end_pos
			continue

		# Check for operators
		var op_found = false
		for op in operators:
			if line_text.substr(i, op.length()) == op:
				_highlight_range(result, i, i + op.length(), color_operator)
				i += op.length()
				op_found = true
				break
		if op_found:
			continue

		# Check for identifiers (keywords, builtins, function names)
		if _is_identifier_char(c):
			var end_pos = _find_identifier_end(line_text, i)
			var word = line_text.substr(i, end_pos - i)

			if word in keywords:
				_highlight_range(result, i, end_pos, color_keyword)
			elif word in builtins:
				_highlight_range(result, i, end_pos, color_builtin)
			elif end_pos < line_length and line_text[end_pos] == "(":
				# Function call
				_highlight_range(result, i, end_pos, color_function)
			else:
				# Regular identifier - use default color
				_highlight_range(result, i, end_pos, color_default)

			i = end_pos
			continue

		# Default: skip this character
		i += 1

	return result


func _highlight_entire_line(result: Dictionary, start: int, end: int, color: Color) -> void:
	result[start] = {"color": color}


func _highlight_range(result: Dictionary, start: int, end: int, color: Color) -> void:
	if start < end:
		result[start] = {"color": color}


func _find_string_end(text: String, start: int) -> int:
	var quote = text[start]
	var i = start + 1
	var text_length = text.length()

	# Check for triple quotes
	if i + 1 < text_length and text[i] == quote and text[i + 1] == quote:
		# Triple quoted string
		i += 2
		while i + 2 < text_length:
			if text[i] == quote and text[i + 1] == quote and text[i + 2] == quote:
				return i + 3
			i += 1
		return text_length

	# Regular string
	while i < text_length:
		if text[i] == quote:
			return i + 1
		if text[i] == "\\":
			i += 2  # Skip escaped character
			continue
		i += 1

	return text_length


func _find_number_end(text: String, start: int) -> int:
	var i = start
	var text_length = text.length()
	var has_dot = false

	# Check for hex (0x) or binary (0b)
	if i < text_length and text[i] == "0":
		if i + 1 < text_length:
			if text[i + 1] == "x" or text[i + 1] == "X":
				i += 2
				while i < text_length and text[i].is_valid_hex_number():
					i += 1
				return i
			elif text[i + 1] == "b" or text[i + 1] == "B":
				i += 2
				while i < text_length and (text[i] == "0" or text[i] == "1"):
					i += 1
				return i

	# Regular number (int or float)
	while i < text_length:
		var c = text[i]
		if c.is_valid_int():
			i += 1
		elif c == "." and not has_dot:
			has_dot = true
			i += 1
		else:
			break

	return i


func _find_identifier_end(text: String, start: int) -> int:
	var i = start
	var text_length = text.length()

	while i < text_length:
		var c = text[i]
		if _is_identifier_char(c) or c.is_valid_int():
			i += 1
		else:
			break

	return i


# Helper method to check if character is valid identifier character
func _is_identifier_char(c: String) -> bool:
	if c.length() != 1:
		return false
	var code = c.unicode_at(0)
	return (code >= 65 and code <= 90) or (code >= 97 and code <= 122) or c == "_"


# Override to enable the highlighter
func _init() -> void:
	pass
