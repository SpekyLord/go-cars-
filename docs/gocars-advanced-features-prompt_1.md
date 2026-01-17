# Advanced Editor Features for GoCars Code Editor

You are implementing advanced editor features for GoCars, an educational coding-puzzle game built in Godot 4.5.1. The game teaches Python programming through traffic simulation scenarios, and the code editor uses floating modular windows with CodeEdit nodes.

## Current Tech Stack

- Godot 4.5.1 with GDScript
- Modular floating window system (CodeEditorWindow nodes)
- CodeEdit nodes for text editing
- Custom theming and syntax highlighting system
- IntelliSense system with autocomplete

---

# Feature 1: Error Highlighting & Linting

**Objective:** Provide real-time feedback on syntax errors and code issues with visual indicators and an error panel.

## 1.1 Error Types

| Type | Severity | Visual | Example |
|------|----------|--------|---------|
| Syntax Error | Error | Red squiggly underline | `def foo(` (missing `)`) |
| Name Error | Error | Red squiggly | `pritn("hello")` (typo) |
| Undefined Variable | Warning | Yellow squiggly | Using `x` before assignment |
| Unused Variable | Info | Gray/dim text | `x = 5` but never used |
| Indentation Error | Error | Red squiggly | Inconsistent indentation |
| Type Hint Mismatch | Warning | Yellow squiggly | `move_forward("fast")` (expects int) |

## 1.2 Linter Rules

```gdscript
# linter_rules.gd
class_name LinterRules

enum Severity { ERROR, WARNING, INFO, HINT }

# Syntax patterns to check
static var rules: Array[Dictionary] = [
    # Syntax errors
    {
        "id": "E001",
        "name": "unclosed_parenthesis",
        "severity": Severity.ERROR,
        "message": "Unclosed parenthesis",
        "check": "bracket_balance"
    },
    {
        "id": "E002",
        "name": "unclosed_string",
        "severity": Severity.ERROR,
        "message": "Unclosed string literal",
        "check": "string_balance"
    },
    {
        "id": "E003",
        "name": "invalid_syntax",
        "severity": Severity.ERROR,
        "message": "Invalid syntax",
        "check": "syntax_parse"
    },
    {
        "id": "E004",
        "name": "indentation_error",
        "severity": Severity.ERROR,
        "message": "Unexpected indentation",
        "check": "indentation"
    },
    {
        "id": "E005",
        "name": "missing_colon",
        "severity": Severity.ERROR,
        "message": "Expected ':' after statement",
        "check": "block_colon"
    },
    
    # Name errors
    {
        "id": "E101",
        "name": "undefined_name",
        "severity": Severity.ERROR,
        "message": "Undefined name '%s'",
        "check": "name_defined"
    },
    {
        "id": "E102",
        "name": "undefined_function",
        "severity": Severity.ERROR,
        "message": "Undefined function '%s'. Did you mean '%s'?",
        "check": "function_defined"
    },
    
    # Warnings
    {
        "id": "W001",
        "name": "unused_variable",
        "severity": Severity.WARNING,
        "message": "Variable '%s' is assigned but never used",
        "check": "variable_usage"
    },
    {
        "id": "W002",
        "name": "unused_import",
        "severity": Severity.WARNING,
        "message": "Imported module '%s' is never used",
        "check": "import_usage"
    },
    {
        "id": "W003",
        "name": "type_mismatch",
        "severity": Severity.WARNING,
        "message": "Expected %s but got %s",
        "check": "type_check"
    },
    {
        "id": "W004",
        "name": "unreachable_code",
        "severity": Severity.WARNING,
        "message": "Unreachable code after '%s'",
        "check": "reachability"
    },
    
    # Info/Hints
    {
        "id": "I001",
        "name": "could_simplify",
        "severity": Severity.INFO,
        "message": "This could be simplified to '%s'",
        "check": "simplification"
    },
    {
        "id": "I002",
        "name": "naming_convention",
        "severity": Severity.HINT,
        "message": "Consider using snake_case for variable names",
        "check": "naming"
    },
]

# Known game functions for validation
static var known_functions: Array[String] = [
    "move_forward", "move_backward", "turn_left", "turn_right",
    "stop", "wait", "get_speed", "set_speed", "accelerate", "decelerate",
    "is_blocked", "is_clear", "detect_obstacle", "get_distance_to_obstacle",
    "can_turn_left", "can_turn_right", "get_position", "get_direction",
    "get_lane", "is_traffic_light_green", "is_traffic_light_red",
    "wait_for_green", "honk", "signal_left", "signal_right", "signal_off",
    "print", "len", "range", "int", "str", "float", "list", "dict",
    "abs", "min", "max", "sum", "round", "type", "input"
]

static var python_keywords: Array[String] = [
    "if", "else", "elif", "while", "for", "def", "return", "class",
    "import", "from", "as", "try", "except", "finally", "with",
    "pass", "break", "continue", "and", "or", "not", "in", "is",
    "True", "False", "None", "lambda", "yield", "global", "nonlocal"
]
```

## 1.3 Linter Engine

```gdscript
# linter.gd
class_name Linter
extends RefCounted

signal diagnostics_updated(diagnostics: Array[Diagnostic])

class Diagnostic:
    var line: int
    var column_start: int
    var column_end: int
    var severity: LinterRules.Severity
    var code: String
    var message: String
    var suggestions: Array[String] = []
    
    func _init(l: int, cs: int, ce: int, sev: LinterRules.Severity, c: String, msg: String) -> void:
        line = l
        column_start = cs
        column_end = ce
        severity = sev
        code = c
        message = msg

var diagnostics: Array[Diagnostic] = []
var defined_variables: Dictionary = {}  # name -> line defined
var used_variables: Dictionary = {}     # name -> Array of lines used
var defined_functions: Dictionary = {}  # name -> line defined

# Debounce timer for performance
var lint_timer: Timer
var pending_content: String = ""

func _init() -> void:
    lint_timer = Timer.new()
    lint_timer.one_shot = true
    lint_timer.wait_time = 0.3  # 300ms debounce
    lint_timer.timeout.connect(_do_lint)

func get_timer() -> Timer:
    return lint_timer

func lint(content: String) -> void:
    pending_content = content
    lint_timer.start()

func _do_lint() -> void:
    diagnostics.clear()
    defined_variables.clear()
    used_variables.clear()
    defined_functions.clear()
    
    var lines = pending_content.split("\n")
    
    # First pass: collect definitions
    _collect_definitions(lines)
    
    # Second pass: check for errors
    for i in range(lines.size()):
        var line = lines[i]
        _check_line(line, i, lines)
    
    # Third pass: check for unused variables
    _check_unused()
    
    diagnostics_updated.emit(diagnostics)

func _collect_definitions(lines: Array) -> void:
    for i in range(lines.size()):
        var line = lines[i]
        var stripped = line.strip_edges()
        
        # Function definitions
        if stripped.begins_with("def "):
            var func_name = _extract_function_name(stripped)
            if func_name != "":
                defined_functions[func_name] = i
        
        # Variable assignments
        if "=" in stripped and not stripped.begins_with("#"):
            var parts = stripped.split("=")
            if parts.size() >= 2:
                var var_name = parts[0].strip_edges()
                # Skip comparison operators
                if not var_name.ends_with("!") and not var_name.ends_with("<") and not var_name.ends_with(">"):
                    if var_name.is_valid_identifier():
                        defined_variables[var_name] = i

func _check_line(line: String, line_num: int, all_lines: Array) -> void:
    var stripped = line.strip_edges()
    
    # Skip empty lines and comments
    if stripped.is_empty() or stripped.begins_with("#"):
        return
    
    # Check bracket balance
    _check_brackets(line, line_num)
    
    # Check string balance
    _check_strings(line, line_num)
    
    # Check for missing colons
    _check_missing_colon(stripped, line_num)
    
    # Check indentation
    _check_indentation(line, line_num, all_lines)
    
    # Check undefined names
    _check_undefined_names(line, line_num)
    
    # Track variable usage
    _track_usage(line, line_num)

func _check_brackets(line: String, line_num: int) -> void:
    var stack: Array[Dictionary] = []  # {char, column}
    var in_string = false
    var string_char = ""
    
    for i in range(line.length()):
        var c = line[i]
        
        # Track string state
        if c in ["'", '"'] and (i == 0 or line[i-1] != "\\"):
            if not in_string:
                in_string = true
                string_char = c
            elif c == string_char:
                in_string = false
        
        if in_string:
            continue
        
        # Track brackets
        if c in ["(", "[", "{"]:
            stack.append({"char": c, "column": i})
        elif c in [")", "]", "}"]:
            var expected = {"(": ")", "[": "]", "{": "}"}
            if stack.is_empty():
                diagnostics.append(Diagnostic.new(
                    line_num, i, i + 1,
                    LinterRules.Severity.ERROR,
                    "E001",
                    "Unmatched closing bracket '%s'" % c
                ))
            else:
                var last = stack.pop_back()
                if expected[last.char] != c:
                    diagnostics.append(Diagnostic.new(
                        line_num, i, i + 1,
                        LinterRules.Severity.ERROR,
                        "E001",
                        "Mismatched bracket: expected '%s' but found '%s'" % [expected[last.char], c]
                    ))
    
    # Check for unclosed brackets at end of line
    for bracket in stack:
        diagnostics.append(Diagnostic.new(
            line_num, bracket.column, bracket.column + 1,
            LinterRules.Severity.ERROR,
            "E001",
            "Unclosed bracket '%s'" % bracket.char
        ))

func _check_strings(line: String, line_num: int) -> void:
    var in_string = false
    var string_char = ""
    var string_start = 0
    
    var i = 0
    while i < line.length():
        var c = line[i]
        
        # Check for triple quotes
        if i + 2 < line.length():
            var triple = line.substr(i, 3)
            if triple in ['"""', "'''"]:
                if not in_string:
                    in_string = true
                    string_char = triple
                    string_start = i
                    i += 3
                    continue
                elif string_char == triple:
                    in_string = false
                    i += 3
                    continue
        
        # Single/double quotes
        if c in ["'", '"'] and (i == 0 or line[i-1] != "\\"):
            if not in_string:
                in_string = true
                string_char = c
                string_start = i
            elif c == string_char:
                in_string = false
        
        i += 1
    
    # Check for unclosed string (only for single-line strings)
    if in_string and string_char.length() == 1:
        diagnostics.append(Diagnostic.new(
            line_num, string_start, line.length(),
            LinterRules.Severity.ERROR,
            "E002",
            "Unclosed string literal"
        ))

func _check_missing_colon(stripped: String, line_num: int) -> void:
    var block_starters = ["if ", "elif ", "else", "while ", "for ", "def ", "class ", "try", "except", "finally", "with "]
    
    for starter in block_starters:
        if stripped.begins_with(starter) or stripped == starter.strip_edges():
            if not stripped.ends_with(":"):
                # Check if it's a multi-line statement (ends with \)
                if not stripped.ends_with("\\"):
                    diagnostics.append(Diagnostic.new(
                        line_num, stripped.length(), stripped.length() + 1,
                        LinterRules.Severity.ERROR,
                        "E005",
                        "Expected ':' after '%s' statement" % starter.strip_edges()
                    ))
            break

func _check_indentation(line: String, line_num: int, all_lines: Array) -> void:
    if line.strip_edges().is_empty():
        return
    
    var indent = 0
    for c in line:
        if c == " ":
            indent += 1
        elif c == "\t":
            indent += 4  # Treat tabs as 4 spaces
        else:
            break
    
    # Check for inconsistent indentation (not multiple of 4)
    if indent % 4 != 0:
        diagnostics.append(Diagnostic.new(
            line_num, 0, indent,
            LinterRules.Severity.WARNING,
            "E004",
            "Indentation is not a multiple of 4 spaces"
        ))

func _check_undefined_names(line: String, line_num: int) -> void:
    # Extract identifiers from line
    var identifiers = _extract_identifiers(line)
    
    for id_info in identifiers:
        var name = id_info.name
        var col = id_info.column
        
        # Skip if it's a keyword, known function, or defined variable/function
        if name in LinterRules.python_keywords:
            continue
        if name in LinterRules.known_functions:
            continue
        if name in defined_variables:
            continue
        if name in defined_functions:
            continue
        
        # Check for similar names (typo detection)
        var suggestion = _find_similar_name(name)
        var msg = "Undefined name '%s'" % name
        if suggestion != "":
            msg += ". Did you mean '%s'?" % suggestion
        
        diagnostics.append(Diagnostic.new(
            line_num, col, col + name.length(),
            LinterRules.Severity.ERROR,
            "E101",
            msg
        ))
        
        if suggestion != "":
            diagnostics[-1].suggestions.append(suggestion)

func _track_usage(line: String, line_num: int) -> void:
    var identifiers = _extract_identifiers(line)
    
    for id_info in identifiers:
        var name = id_info.name
        if name in defined_variables:
            if not used_variables.has(name):
                used_variables[name] = []
            used_variables[name].append(line_num)

func _check_unused() -> void:
    for var_name in defined_variables:
        if not used_variables.has(var_name):
            var def_line = defined_variables[var_name]
            diagnostics.append(Diagnostic.new(
                def_line, 0, var_name.length(),
                LinterRules.Severity.WARNING,
                "W001",
                "Variable '%s' is assigned but never used" % var_name
            ))

func _extract_identifiers(line: String) -> Array[Dictionary]:
    var result: Array[Dictionary] = []
    var regex = RegEx.new()
    regex.compile(r"\b([a-zA-Z_][a-zA-Z0-9_]*)\b")
    
    for match in regex.search_all(line):
        result.append({
            "name": match.get_string(1),
            "column": match.get_start(1)
        })
    
    return result

func _extract_function_name(line: String) -> String:
    var regex = RegEx.new()
    regex.compile(r"def\s+(\w+)")
    var result = regex.search(line)
    if result:
        return result.get_string(1)
    return ""

func _find_similar_name(name: String) -> String:
    var best_match = ""
    var best_distance = 3  # Max edit distance threshold
    
    var all_names: Array[String] = []
    all_names.append_array(LinterRules.known_functions)
    all_names.append_array(defined_variables.keys())
    all_names.append_array(defined_functions.keys())
    
    for candidate in all_names:
        var distance = _levenshtein_distance(name.to_lower(), candidate.to_lower())
        if distance < best_distance:
            best_distance = distance
            best_match = candidate
    
    return best_match

func _levenshtein_distance(s1: String, s2: String) -> int:
    var len1 = s1.length()
    var len2 = s2.length()
    
    var matrix: Array[Array] = []
    for i in range(len1 + 1):
        matrix.append([])
        for j in range(len2 + 1):
            matrix[i].append(0)
    
    for i in range(len1 + 1):
        matrix[i][0] = i
    for j in range(len2 + 1):
        matrix[0][j] = j
    
    for i in range(1, len1 + 1):
        for j in range(1, len2 + 1):
            var cost = 0 if s1[i-1] == s2[j-1] else 1
            matrix[i][j] = min(
                matrix[i-1][j] + 1,      # deletion
                min(
                    matrix[i][j-1] + 1,  # insertion
                    matrix[i-1][j-1] + cost  # substitution
                )
            )
    
    return matrix[len1][len2]

func get_diagnostics_for_line(line_num: int) -> Array[Diagnostic]:
    var result: Array[Diagnostic] = []
    for diag in diagnostics:
        if diag.line == line_num:
            result.append(diag)
    return result
```

## 1.4 Error Display in CodeEdit

```gdscript
# error_highlighter.gd
class_name ErrorHighlighter
extends Node

var code_edit: CodeEdit
var linter: Linter

# Colors for different severity levels
const COLORS = {
    LinterRules.Severity.ERROR: Color("#FF5555"),
    LinterRules.Severity.WARNING: Color("#FFFF55"),
    LinterRules.Severity.INFO: Color("#8888FF"),
    LinterRules.Severity.HINT: Color("#888888"),
}

# Gutter icons
var error_icon: Texture2D
var warning_icon: Texture2D
var info_icon: Texture2D

const GUTTER_ERROR = 1  # Gutter index for error indicators

func _init(editor: CodeEdit) -> void:
    code_edit = editor
    linter = Linter.new()
    linter.diagnostics_updated.connect(_on_diagnostics_updated)
    
    # Add the timer to the scene tree
    code_edit.add_child(linter.get_timer())
    
    # Setup error gutter
    code_edit.add_gutter(GUTTER_ERROR)
    code_edit.set_gutter_type(GUTTER_ERROR, CodeEdit.GUTTER_TYPE_ICON)
    code_edit.set_gutter_width(GUTTER_ERROR, 20)

func lint_content(content: String) -> void:
    linter.lint(content)

func _on_diagnostics_updated(diagnostics: Array) -> void:
    _clear_all_markers()
    
    for diag in diagnostics:
        _add_error_marker(diag)

func _clear_all_markers() -> void:
    # Clear gutter icons
    for i in range(code_edit.get_line_count()):
        code_edit.set_line_gutter_icon(i, GUTTER_ERROR, null)
    
    # Clear underlines (if using custom drawing)
    code_edit.queue_redraw()

func _add_error_marker(diag: Linter.Diagnostic) -> void:
    # Set gutter icon
    var icon = _get_icon_for_severity(diag.severity)
    if icon:
        code_edit.set_line_gutter_icon(diag.line, GUTTER_ERROR, icon)
    
    # Set line background tint for errors
    if diag.severity == LinterRules.Severity.ERROR:
        code_edit.set_line_background_color(diag.line, Color(1, 0, 0, 0.1))

func _get_icon_for_severity(severity: LinterRules.Severity) -> Texture2D:
    match severity:
        LinterRules.Severity.ERROR:
            return error_icon
        LinterRules.Severity.WARNING:
            return warning_icon
        _:
            return info_icon

func get_hover_info(line: int, column: int) -> String:
    var diags = linter.get_diagnostics_for_line(line)
    for diag in diags:
        if column >= diag.column_start and column <= diag.column_end:
            var info = "[%s] %s" % [diag.code, diag.message]
            if not diag.suggestions.is_empty():
                info += "\nSuggestion: " + diag.suggestions[0]
            return info
    return ""
```

## 1.5 Error Panel UI

```gdscript
# error_panel.gd
extends PanelContainer
class_name ErrorPanel

signal error_clicked(line: int, column: int)

@onready var error_list: Tree = $VBox/ErrorTree
@onready var error_count_label: Label = $VBox/Header/ErrorCount
@onready var warning_count_label: Label = $VBox/Header/WarningCount

var diagnostics: Array = []

func _ready() -> void:
    error_list.item_activated.connect(_on_item_activated)
    error_list.create_item()  # Root item
    error_list.hide_root = true
    
    # Setup columns
    error_list.columns = 4
    error_list.set_column_title(0, "")  # Icon
    error_list.set_column_title(1, "Line")
    error_list.set_column_title(2, "Code")
    error_list.set_column_title(3, "Message")
    error_list.set_column_expand(0, false)
    error_list.set_column_expand(1, false)
    error_list.set_column_custom_minimum_width(0, 24)
    error_list.set_column_custom_minimum_width(1, 50)
    error_list.set_column_custom_minimum_width(2, 60)

func update_diagnostics(diags: Array) -> void:
    diagnostics = diags
    _refresh_list()
    _update_counts()

func _refresh_list() -> void:
    # Clear existing items
    var root = error_list.get_root()
    for child in root.get_children():
        child.free()
    
    # Add diagnostics
    for diag in diagnostics:
        var item = error_list.create_item(root)
        
        # Icon column
        var icon = _get_severity_icon(diag.severity)
        item.set_icon(0, icon)
        
        # Line column
        item.set_text(1, str(diag.line + 1))  # 1-indexed for display
        
        # Code column
        item.set_text(2, diag.code)
        
        # Message column
        item.set_text(3, diag.message)
        
        # Store metadata for click handling
        item.set_metadata(0, {"line": diag.line, "column": diag.column_start})
        
        # Color based on severity
        var color = _get_severity_color(diag.severity)
        for col in range(4):
            item.set_custom_color(col, color)

func _update_counts() -> void:
    var error_count = 0
    var warning_count = 0
    
    for diag in diagnostics:
        if diag.severity == LinterRules.Severity.ERROR:
            error_count += 1
        elif diag.severity == LinterRules.Severity.WARNING:
            warning_count += 1
    
    error_count_label.text = "%d Errors" % error_count
    warning_count_label.text = "%d Warnings" % warning_count
    
    # Color indicators
    error_count_label.add_theme_color_override("font_color", Color.RED if error_count > 0 else Color.GRAY)
    warning_count_label.add_theme_color_override("font_color", Color.YELLOW if warning_count > 0 else Color.GRAY)

func _on_item_activated() -> void:
    var selected = error_list.get_selected()
    if selected:
        var meta = selected.get_metadata(0)
        error_clicked.emit(meta.line, meta.column)

func _get_severity_icon(severity: LinterRules.Severity) -> Texture2D:
    # Return appropriate icon
    return null  # Placeholder - load actual icons

func _get_severity_color(severity: LinterRules.Severity) -> Color:
    match severity:
        LinterRules.Severity.ERROR:
            return Color("#FF5555")
        LinterRules.Severity.WARNING:
            return Color("#FFFF55")
        LinterRules.Severity.INFO:
            return Color("#8888FF")
        _:
            return Color("#888888")
```

---

# Feature 2: Code Snippets / Templates

**Objective:** Provide expandable code templates triggered by short prefixes to speed up coding and teach common patterns.

## 2.1 Snippet Definition Format

```gdscript
# snippet.gd
class_name Snippet
extends RefCounted

var prefix: String           # Trigger text (e.g., "fori")
var name: String             # Display name
var description: String      # Help text
var body: Array[String]      # Lines of code
var tab_stops: Array[Dictionary] = []  # {index, line, column, placeholder, linked_to}
var scope: String = "python" # Language scope

func _init(p: String, n: String, desc: String, b: Array[String]) -> void:
    prefix = p
    name = n
    description = desc
    body = b
    _parse_tab_stops()

func _parse_tab_stops() -> void:
    # Parse ${1:placeholder} and $1 patterns in body
    var regex = RegEx.new()
    regex.compile(r"\$\{(\d+):([^}]*)\}|\$(\d+)")
    
    for line_idx in range(body.size()):
        var line = body[line_idx]
        for match in regex.search_all(line):
            var index: int
            var placeholder: String
            
            if match.get_string(1) != "":
                # ${1:placeholder} format
                index = match.get_string(1).to_int()
                placeholder = match.get_string(2)
            else:
                # $1 format
                index = match.get_string(3).to_int()
                placeholder = ""
            
            tab_stops.append({
                "index": index,
                "line": line_idx,
                "column": match.get_start(),
                "placeholder": placeholder,
                "length": match.get_string().length()
            })
    
    # Sort by index
    tab_stops.sort_custom(func(a, b): return a.index < b.index)

func get_expanded_text(indent: String = "") -> String:
    var result: Array[String] = []
    
    for i in range(body.size()):
        var line = body[i]
        # Replace tab stop markers with placeholders
        var regex = RegEx.new()
        regex.compile(r"\$\{(\d+):([^}]*)\}|\$(\d+)")
        
        var processed_line = ""
        var last_end = 0
        
        for match in regex.search_all(line):
            processed_line += line.substr(last_end, match.get_start() - last_end)
            
            if match.get_string(2) != "":
                processed_line += match.get_string(2)  # Use placeholder text
            # $0 is final cursor position, leave empty
            
            last_end = match.get_end()
        
        processed_line += line.substr(last_end)
        
        # Add indent for all lines except first
        if i > 0:
            result.append(indent + processed_line)
        else:
            result.append(processed_line)
    
    return "\n".join(result)
```

## 2.2 Built-in Snippets Library

```gdscript
# snippet_library.gd
class_name SnippetLibrary

static var snippets: Array[Snippet] = []

static func _static_init() -> void:
    # Control Flow
    snippets.append(Snippet.new(
        "if", "If Statement", "If conditional block",
        ["if ${1:condition}:", "\t${2:pass}"]
    ))
    
    snippets.append(Snippet.new(
        "ife", "If-Else", "If-else conditional block",
        ["if ${1:condition}:", "\t${2:pass}", "else:", "\t${3:pass}"]
    ))
    
    snippets.append(Snippet.new(
        "ifel", "If-Elif-Else", "If-elif-else chain",
        ["if ${1:condition}:", "\t${2:pass}", "elif ${3:condition}:", "\t${4:pass}", "else:", "\t${5:pass}"]
    ))
    
    # Loops
    snippets.append(Snippet.new(
        "for", "For Loop", "For loop with iterator",
        ["for ${1:item} in ${2:iterable}:", "\t${3:pass}"]
    ))
    
    snippets.append(Snippet.new(
        "fori", "For Range Loop", "For loop with range",
        ["for ${1:i} in range(${2:10}):", "\t${3:pass}"]
    ))
    
    snippets.append(Snippet.new(
        "forr", "For Range with Start", "For loop with start and end",
        ["for ${1:i} in range(${2:0}, ${3:10}):", "\t${4:pass}"]
    ))
    
    snippets.append(Snippet.new(
        "while", "While Loop", "While loop block",
        ["while ${1:condition}:", "\t${2:pass}"]
    ))
    
    snippets.append(Snippet.new(
        "whilet", "While True Loop", "Infinite loop with break",
        ["while True:", "\t${1:pass}", "\tif ${2:condition}:", "\t\tbreak"]
    ))
    
    # Functions
    snippets.append(Snippet.new(
        "def", "Function Definition", "Define a function",
        ["def ${1:function_name}(${2:params}):", "\t${3:pass}"]
    ))
    
    snippets.append(Snippet.new(
        "defr", "Function with Return", "Function with return statement",
        ["def ${1:function_name}(${2:params}):", "\t${3:result = None}", "\treturn ${4:result}"]
    ))
    
    snippets.append(Snippet.new(
        "main", "Main Block", "Main entry point",
        ["def main():", "\t${1:pass}", "", "main()"]
    ))
    
    # Error Handling
    snippets.append(Snippet.new(
        "try", "Try-Except", "Try-except block",
        ["try:", "\t${1:pass}", "except ${2:Exception}:", "\t${3:pass}"]
    ))
    
    snippets.append(Snippet.new(
        "tryf", "Try-Except-Finally", "Try-except-finally block",
        ["try:", "\t${1:pass}", "except ${2:Exception}:", "\t${3:pass}", "finally:", "\t${4:pass}"]
    ))
    
    # Game-Specific Snippets
    snippets.append(Snippet.new(
        "moveloop", "Movement Loop", "Loop with movement commands",
        ["for ${1:i} in range(${2:5}):", "\tmove_forward()", "\t${3:pass}"]
    ))
    
    snippets.append(Snippet.new(
        "checkblock", "Check Blocked", "Check if blocked and handle",
        ["if is_blocked():", "\t${1:turn_left()}", "else:", "\tmove_forward()"]
    ))
    
    snippets.append(Snippet.new(
        "waitgreen", "Wait for Green Light", "Wait for traffic light",
        ["while is_traffic_light_red():", "\twait(0.5)", "move_forward()"]
    ))
    
    snippets.append(Snippet.new(
        "patrol", "Patrol Pattern", "Basic patrol loop",
        ["while True:", "\tfor ${1:i} in range(${2:4}):", "\t\tmove_forward()", "\tturn_right()"]
    ))
    
    snippets.append(Snippet.new(
        "avoidobs", "Avoid Obstacle", "Obstacle avoidance pattern",
        ["if detect_obstacle('front'):", "\tif can_turn_left():", "\t\tturn_left()", "\telif can_turn_right():", "\t\tturn_right()", "else:", "\tmove_forward()"]
    ))

static func get_by_prefix(prefix: String) -> Array[Snippet]:
    var result: Array[Snippet] = []
    var prefix_lower = prefix.to_lower()
    
    for snippet in snippets:
        if snippet.prefix.to_lower().begins_with(prefix_lower):
            result.append(snippet)
    
    return result

static func get_exact(prefix: String) -> Snippet:
    for snippet in snippets:
        if snippet.prefix == prefix:
            return snippet
    return null
```

## 2.3 Snippet Expansion Handler

```gdscript
# snippet_handler.gd
class_name SnippetHandler
extends RefCounted

signal snippet_expanded(snippet: Snippet)
signal tab_stop_changed(index: int, total: int)

var code_edit: CodeEdit
var active_snippet: Snippet = null
var active_tab_stops: Array[Dictionary] = []
var current_tab_index: int = 0
var snippet_start_line: int = 0
var snippet_start_col: int = 0

func _init(editor: CodeEdit) -> void:
    code_edit = editor

func try_expand(prefix: String) -> bool:
    var snippet = SnippetLibrary.get_exact(prefix)
    if snippet == null:
        return false
    
    expand_snippet(snippet, prefix.length())
    return true

func expand_snippet(snippet: Snippet, prefix_length: int) -> void:
    # Store starting position
    snippet_start_line = code_edit.get_caret_line()
    snippet_start_col = code_edit.get_caret_column() - prefix_length
    
    # Get current line indent
    var line = code_edit.get_line(snippet_start_line)
    var indent = ""
    for c in line:
        if c == " " or c == "\t":
            indent += c
        else:
            break
    
    # Delete the prefix
    code_edit.select(snippet_start_line, snippet_start_col, snippet_start_line, code_edit.get_caret_column())
    code_edit.delete_selection()
    
    # Insert expanded text
    var expanded = snippet.get_expanded_text(indent)
    code_edit.insert_text_at_caret(expanded)
    
    # Setup tab stops
    active_snippet = snippet
    _setup_tab_stops(snippet, indent)
    
    if active_tab_stops.size() > 0:
        current_tab_index = 0
        _select_tab_stop(0)
        snippet_expanded.emit(snippet)

func _setup_tab_stops(snippet: Snippet, base_indent: String) -> void:
    active_tab_stops.clear()
    
    # Calculate actual positions in the editor
    var line_offset = snippet_start_line
    
    for ts in snippet.tab_stops:
        var actual_line = line_offset + ts.line
        var actual_col = ts.column
        
        # Adjust column for indent on lines after first
        if ts.line > 0:
            actual_col += base_indent.length()
        else:
            actual_col += snippet_start_col
        
        active_tab_stops.append({
            "index": ts.index,
            "line": actual_line,
            "column": actual_col,
            "placeholder": ts.placeholder,
            "length": ts.placeholder.length()
        })

func _select_tab_stop(index: int) -> void:
    if index >= active_tab_stops.size():
        _finish_snippet()
        return
    
    var ts = active_tab_stops[index]
    
    # Select the placeholder text
    code_edit.set_caret_line(ts.line)
    code_edit.set_caret_column(ts.column)
    
    if ts.length > 0:
        code_edit.select(ts.line, ts.column, ts.line, ts.column + ts.length)
    
    tab_stop_changed.emit(index + 1, active_tab_stops.size())

func next_tab_stop() -> bool:
    if active_snippet == null:
        return false
    
    # Update current tab stop length based on selection/edit
    if current_tab_index < active_tab_stops.size():
        var ts = active_tab_stops[current_tab_index]
        var current_col = code_edit.get_caret_column()
        ts.length = current_col - ts.column
    
    current_tab_index += 1
    
    if current_tab_index >= active_tab_stops.size():
        _finish_snippet()
        return false
    
    _select_tab_stop(current_tab_index)
    return true

func prev_tab_stop() -> bool:
    if active_snippet == null or current_tab_index <= 0:
        return false
    
    current_tab_index -= 1
    _select_tab_stop(current_tab_index)
    return true

func _finish_snippet() -> void:
    active_snippet = null
    active_tab_stops.clear()
    current_tab_index = 0

func is_active() -> bool:
    return active_snippet != null

func cancel() -> void:
    _finish_snippet()
```

## 2.4 Snippet Chooser Popup

```gdscript
# snippet_popup.gd
extends PopupPanel
class_name SnippetPopup

signal snippet_selected(snippet: Snippet)

@onready var item_list: ItemList = $VBox/ItemList
@onready var preview_label: RichTextLabel = $VBox/Preview

var filtered_snippets: Array[Snippet] = []

func show_snippets(prefix: String, position: Vector2) -> void:
    filtered_snippets = SnippetLibrary.get_by_prefix(prefix)
    
    if filtered_snippets.is_empty():
        hide()
        return
    
    _populate_list()
    global_position = position
    show()
    item_list.grab_focus()
    item_list.select(0)
    _update_preview(0)

func _populate_list() -> void:
    item_list.clear()
    
    for snippet in filtered_snippets:
        var display = "%s  →  %s" % [snippet.prefix, snippet.name]
        item_list.add_item(display)

func _update_preview(index: int) -> void:
    if index < 0 or index >= filtered_snippets.size():
        return
    
    var snippet = filtered_snippets[index]
    var preview_text = "[b]%s[/b]\n%s\n\n[code]%s[/code]" % [
        snippet.name,
        snippet.description,
        "\n".join(snippet.body)
    ]
    preview_label.text = preview_text

func select_next() -> void:
    var current = item_list.get_selected_items()
    if current.is_empty():
        item_list.select(0)
    else:
        var next_idx = (current[0] + 1) % filtered_snippets.size()
        item_list.select(next_idx)
        _update_preview(next_idx)

func select_prev() -> void:
    var current = item_list.get_selected_items()
    if current.is_empty():
        item_list.select(0)
    else:
        var prev_idx = (current[0] - 1 + filtered_snippets.size()) % filtered_snippets.size()
        item_list.select(prev_idx)
        _update_preview(prev_idx)

func confirm() -> void:
    var selected = item_list.get_selected_items()
    if not selected.is_empty():
        snippet_selected.emit(filtered_snippets[selected[0]])
    hide()

func _on_item_list_item_selected(index: int) -> void:
    _update_preview(index)

func _on_item_list_item_activated(index: int) -> void:
    snippet_selected.emit(filtered_snippets[index])
    hide()
```

---

# Feature 3: Code Folding

**Objective:** Allow collapsing and expanding code blocks to manage complexity in longer scripts.

## 3.1 Foldable Regions Detection

```gdscript
# fold_region.gd
class_name FoldRegion
extends RefCounted

var start_line: int
var end_line: int
var indent_level: int
var is_folded: bool = false
var fold_type: String  # "function", "class", "loop", "conditional", "region"
var preview_text: String  # Text shown when folded

func _init(start: int, end: int, indent: int, type: String) -> void:
    start_line = start
    end_line = end
    indent_level = indent
    fold_type = type

func get_line_count() -> int:
    return end_line - start_line
```

## 3.2 Fold Manager

```gdscript
# fold_manager.gd
class_name FoldManager
extends RefCounted

signal folds_updated()

var code_edit: CodeEdit
var fold_regions: Array[FoldRegion] = []
var folded_lines: Dictionary = {}  # start_line -> FoldRegion

const FOLD_STARTERS = {
    "def ": "function",
    "class ": "class",
    "if ": "conditional",
    "elif ": "conditional",
    "else:": "conditional",
    "for ": "loop",
    "while ": "loop",
    "try:": "error_handling",
    "except": "error_handling",
    "finally:": "error_handling",
    "with ": "context",
    "#region": "region",
}

func _init(editor: CodeEdit) -> void:
    code_edit = editor

func analyze_folds(content: String) -> void:
    fold_regions.clear()
    var lines = content.split("\n")
    
    var region_stack: Array[Dictionary] = []  # {line, indent, type}
    
    for i in range(lines.size()):
        var line = lines[i]
        var stripped = line.strip_edges()
        var indent = _get_indent_level(line)
        
        # Check for fold starters
        for starter in FOLD_STARTERS:
            if stripped.begins_with(starter):
                # Close any regions at same or higher indent
                while not region_stack.is_empty() and region_stack[-1].indent >= indent:
                    var region = region_stack.pop_back()
                    _create_fold_region(region.line, i - 1, region.indent, region.type, lines)
                
                region_stack.append({
                    "line": i,
                    "indent": indent,
                    "type": FOLD_STARTERS[starter]
                })
                break
        
        # Check for #endregion
        if stripped.begins_with("#endregion"):
            for j in range(region_stack.size() - 1, -1, -1):
                if region_stack[j].type == "region":
                    var region = region_stack[j]
                    region_stack.remove_at(j)
                    _create_fold_region(region.line, i, region.indent, region.type, lines)
                    break
    
    # Close remaining regions at end of file
    for region in region_stack:
        var end_line = _find_block_end(region.line, region.indent, lines)
        _create_fold_region(region.line, end_line, region.indent, region.type, lines)
    
    folds_updated.emit()

func _get_indent_level(line: String) -> int:
    var indent = 0
    for c in line:
        if c == " ":
            indent += 1
        elif c == "\t":
            indent += 4
        else:
            break
    return indent / 4  # Convert to indent level

func _find_block_end(start_line: int, start_indent: int, lines: Array) -> int:
    for i in range(start_line + 1, lines.size()):
        var line = lines[i]
        if line.strip_edges().is_empty():
            continue
        
        var indent = _get_indent_level(line)
        if indent <= start_indent:
            return i - 1
    
    return lines.size() - 1

func _create_fold_region(start: int, end: int, indent: int, type: String, lines: Array) -> void:
    if end <= start:
        return
    
    var region = FoldRegion.new(start, end, indent, type)
    
    # Generate preview text
    var first_line = lines[start].strip_edges()
    region.preview_text = first_line + " ... (%d lines)" % (end - start)
    
    fold_regions.append(region)

func toggle_fold(line: int) -> void:
    var region = get_fold_at_line(line)
    if region:
        if region.is_folded:
            unfold(region)
        else:
            fold(region)

func fold(region: FoldRegion) -> void:
    if region.is_folded:
        return
    
    region.is_folded = true
    folded_lines[region.start_line] = region
    
    # Hide lines in CodeEdit
    for i in range(region.start_line + 1, region.end_line + 1):
        code_edit.set_line_as_hidden(i, true)
    
    folds_updated.emit()

func unfold(region: FoldRegion) -> void:
    if not region.is_folded:
        return
    
    region.is_folded = false
    folded_lines.erase(region.start_line)
    
    # Show lines in CodeEdit
    for i in range(region.start_line + 1, region.end_line + 1):
        code_edit.set_line_as_hidden(i, false)
    
    folds_updated.emit()

func fold_all() -> void:
    for region in fold_regions:
        fold(region)

func unfold_all() -> void:
    for region in fold_regions:
        unfold(region)

func get_fold_at_line(line: int) -> FoldRegion:
    for region in fold_regions:
        if region.start_line == line:
            return region
    return null

func is_line_foldable(line: int) -> bool:
    return get_fold_at_line(line) != null

func is_line_folded(line: int) -> bool:
    var region = get_fold_at_line(line)
    return region != null and region.is_folded

func get_visible_line_count() -> int:
    var hidden = 0
    for region in folded_lines.values():
        hidden += region.end_line - region.start_line
    return code_edit.get_line_count() - hidden
```

## 3.3 Fold Gutter UI

```gdscript
# fold_gutter.gd
class_name FoldGutter
extends RefCounted

var code_edit: CodeEdit
var fold_manager: FoldManager

const GUTTER_FOLD = 2  # Gutter index for fold indicators

# Icons
var fold_icon: Texture2D      # ▶ or ▼
var unfold_icon: Texture2D
var fold_end_icon: Texture2D  # └

func _init(editor: CodeEdit, manager: FoldManager) -> void:
    code_edit = editor
    fold_manager = manager
    
    # Setup fold gutter
    code_edit.add_gutter(GUTTER_FOLD)
    code_edit.set_gutter_type(GUTTER_FOLD, CodeEdit.GUTTER_TYPE_ICON)
    code_edit.set_gutter_width(GUTTER_FOLD, 16)
    code_edit.set_gutter_clickable(GUTTER_FOLD, true)
    
    # Connect signals
    code_edit.gutter_clicked.connect(_on_gutter_clicked)
    fold_manager.folds_updated.connect(_update_gutter_icons)

func _update_gutter_icons() -> void:
    # Clear all fold icons
    for i in range(code_edit.get_line_count()):
        code_edit.set_line_gutter_icon(i, GUTTER_FOLD, null)
    
    # Add icons for foldable lines
    for region in fold_manager.fold_regions:
        var icon = unfold_icon if region.is_folded else fold_icon
        code_edit.set_line_gutter_icon(region.start_line, GUTTER_FOLD, icon)

func _on_gutter_clicked(line: int, gutter: int) -> void:
    if gutter == GUTTER_FOLD:
        fold_manager.toggle_fold(line)
```

## 3.4 Fold Keyboard Shortcuts

```gdscript
# fold_shortcuts.gd - Integration with editor

func handle_fold_input(event: InputEventKey) -> bool:
    if not event.pressed:
        return false
    
    # Ctrl+Shift+[ - Fold current region
    if event.keycode == KEY_BRACKETLEFT and event.ctrl_pressed and event.shift_pressed:
        var line = code_edit.get_caret_line()
        var region = fold_manager.get_fold_at_line(line)
        if region:
            fold_manager.fold(region)
        return true
    
    # Ctrl+Shift+] - Unfold current region
    if event.keycode == KEY_BRACKETRIGHT and event.ctrl_pressed and event.shift_pressed:
        var line = code_edit.get_caret_line()
        var region = fold_manager.get_fold_at_line(line)
        if region:
            fold_manager.unfold(region)
        return true
    
    # Ctrl+Shift+0 - Fold all
    if event.keycode == KEY_0 and event.ctrl_pressed and event.shift_pressed:
        fold_manager.fold_all()
        return true
    
    # Ctrl+Shift+9 - Unfold all
    if event.keycode == KEY_9 and event.ctrl_pressed and event.shift_pressed:
        fold_manager.unfold_all()
        return true
    
    return false
```

---

# Feature 4: Execution Visualization

**Objective:** Highlight the currently executing line during playback and visualize the car's path on the game map.

## 4.1 Execution Tracer

```gdscript
# execution_tracer.gd
class_name ExecutionTracer
extends Node

signal line_executed(line: int, variables: Dictionary)
signal execution_started()
signal execution_paused()
signal execution_resumed()
signal execution_finished()
signal car_moved(from: Vector2i, to: Vector2i, action: String)

enum State { IDLE, RUNNING, PAUSED, STEPPING }

var current_state: State = State.IDLE
var current_line: int = -1
var execution_speed: float = 1.0  # Lines per second
var step_delay: float = 0.5      # Delay between steps in auto mode

var execution_history: Array[Dictionary] = []  # {line, variables, action, position}
var variable_snapshots: Dictionary = {}

# Reference to the game interpreter
var interpreter: Node  # Your Python interpreter implementation

func _init(interp: Node) -> void:
    interpreter = interp

func start_execution(code: String) -> void:
    execution_history.clear()
    variable_snapshots.clear()
    current_line = 0
    current_state = State.RUNNING
    execution_started.emit()
    
    # Start the interpreter
    interpreter.execute(code)

func pause_execution() -> void:
    if current_state == State.RUNNING:
        current_state = State.PAUSED
        interpreter.pause()
        execution_paused.emit()

func resume_execution() -> void:
    if current_state == State.PAUSED:
        current_state = State.RUNNING
        interpreter.resume()
        execution_resumed.emit()

func step_execution() -> void:
    if current_state == State.PAUSED or current_state == State.IDLE:
        current_state = State.STEPPING
        interpreter.step()

func stop_execution() -> void:
    current_state = State.IDLE
    interpreter.stop()
    execution_finished.emit()

# Called by interpreter when a line is about to execute
func on_line_execute(line: int, vars: Dictionary, action: String = "", car_pos: Vector2i = Vector2i.ZERO) -> void:
    current_line = line
    variable_snapshots = vars.duplicate(true)
    
    var history_entry = {
        "line": line,
        "variables": vars.duplicate(true),
        "action": action,
        "position": car_pos,
        "timestamp": Time.get_ticks_msec()
    }
    execution_history.append(history_entry)
    
    line_executed.emit(line, vars)
    
    if action != "" and action.begins_with("move"):
        var prev_pos = Vector2i.ZERO
        if execution_history.size() > 1:
            prev_pos = execution_history[-2].position
        car_moved.emit(prev_pos, car_pos, action)

func get_variable_at_step(step_index: int) -> Dictionary:
    if step_index >= 0 and step_index < execution_history.size():
        return execution_history[step_index].variables
    return {}

func get_execution_path() -> Array[Vector2i]:
    var path: Array[Vector2i] = []
    for entry in execution_history:
        if entry.position != Vector2i.ZERO and (path.is_empty() or path[-1] != entry.position):
            path.append(entry.position)
    return path

func set_execution_speed(speed: float) -> void:
    execution_speed = clamp(speed, 0.1, 10.0)
    step_delay = 1.0 / execution_speed
```

## 4.2 Line Highlighter for Execution

```gdscript
# execution_highlighter.gd
class_name ExecutionHighlighter
extends Node

var code_edit: CodeEdit
var tracer: ExecutionTracer

var current_exec_line: int = -1
var breakpoint_lines: Array[int] = []

const EXEC_LINE_COLOR = Color(1.0, 0.8, 0.2, 0.3)  # Yellow highlight
const BREAKPOINT_COLOR = Color(1.0, 0.2, 0.2, 0.5)  # Red highlight
const EXECUTED_LINE_COLOR = Color(0.2, 0.8, 0.2, 0.1)  # Faint green

const GUTTER_BREAKPOINT = 3
const GUTTER_EXEC_ARROW = 4

var breakpoint_icon: Texture2D
var exec_arrow_icon: Texture2D

func _init(editor: CodeEdit, execution_tracer: ExecutionTracer) -> void:
    code_edit = editor
    tracer = execution_tracer
    
    tracer.line_executed.connect(_on_line_executed)
    tracer.execution_finished.connect(_on_execution_finished)
    
    _setup_gutters()

func _setup_gutters() -> void:
    # Breakpoint gutter
    code_edit.add_gutter(GUTTER_BREAKPOINT)
    code_edit.set_gutter_type(GUTTER_BREAKPOINT, CodeEdit.GUTTER_TYPE_ICON)
    code_edit.set_gutter_width(GUTTER_BREAKPOINT, 16)
    code_edit.set_gutter_clickable(GUTTER_BREAKPOINT, true)
    
    # Execution arrow gutter
    code_edit.add_gutter(GUTTER_EXEC_ARROW)
    code_edit.set_gutter_type(GUTTER_EXEC_ARROW, CodeEdit.GUTTER_TYPE_ICON)
    code_edit.set_gutter_width(GUTTER_EXEC_ARROW, 16)
    
    code_edit.gutter_clicked.connect(_on_gutter_clicked)

func _on_line_executed(line: int, _vars: Dictionary) -> void:
    # Clear previous highlight
    if current_exec_line >= 0:
        code_edit.set_line_background_color(current_exec_line, Color.TRANSPARENT)
        code_edit.set_line_gutter_icon(current_exec_line, GUTTER_EXEC_ARROW, null)
    
    # Set new highlight
    current_exec_line = line
    
    # Check if hit breakpoint
    if line in breakpoint_lines:
        code_edit.set_line_background_color(line, BREAKPOINT_COLOR)
        tracer.pause_execution()
    else:
        code_edit.set_line_background_color(line, EXEC_LINE_COLOR)
    
    # Show execution arrow
    code_edit.set_line_gutter_icon(line, GUTTER_EXEC_ARROW, exec_arrow_icon)
    
    # Scroll to visible
    _ensure_line_visible(line)

func _on_execution_finished() -> void:
    if current_exec_line >= 0:
        code_edit.set_line_background_color(current_exec_line, Color.TRANSPARENT)
        code_edit.set_line_gutter_icon(current_exec_line, GUTTER_EXEC_ARROW, null)
    current_exec_line = -1

func _on_gutter_clicked(line: int, gutter: int) -> void:
    if gutter == GUTTER_BREAKPOINT:
        toggle_breakpoint(line)

func toggle_breakpoint(line: int) -> void:
    if line in breakpoint_lines:
        breakpoint_lines.erase(line)
        code_edit.set_line_gutter_icon(line, GUTTER_BREAKPOINT, null)
        code_edit.set_line_background_color(line, Color.TRANSPARENT)
    else:
        breakpoint_lines.append(line)
        code_edit.set_line_gutter_icon(line, GUTTER_BREAKPOINT, breakpoint_icon)

func clear_all_breakpoints() -> void:
    for line in breakpoint_lines:
        code_edit.set_line_gutter_icon(line, GUTTER_BREAKPOINT, null)
    breakpoint_lines.clear()

func _ensure_line_visible(line: int) -> void:
    var visible_lines = code_edit.get_visible_line_count()
    var first_visible = code_edit.get_first_visible_line()
    
    if line < first_visible or line >= first_visible + visible_lines:
        code_edit.set_line_as_center_visible(line)
```

## 4.3 Inline Variable Display

```gdscript
# inline_variables.gd
class_name InlineVariableDisplay
extends Node

var code_edit: CodeEdit
var tracer: ExecutionTracer
var inline_hints: Dictionary = {}  # line -> {var_name: value}

const HINT_COLOR = Color(0.6, 0.8, 1.0, 0.8)

func _init(editor: CodeEdit, execution_tracer: ExecutionTracer) -> void:
    code_edit = editor
    tracer = execution_tracer
    
    tracer.line_executed.connect(_on_line_executed)
    tracer.execution_finished.connect(_clear_all_hints)

func _on_line_executed(line: int, variables: Dictionary) -> void:
    var line_text = code_edit.get_line(line)
    var line_vars = _extract_variables_from_line(line_text, variables)
    
    if not line_vars.is_empty():
        inline_hints[line] = line_vars
        _draw_inline_hints(line, line_vars)

func _extract_variables_from_line(line: String, all_vars: Dictionary) -> Dictionary:
    var result: Dictionary = {}
    
    for var_name in all_vars:
        if var_name in line:
            result[var_name] = all_vars[var_name]
    
    return result

func _draw_inline_hints(line: int, vars: Dictionary) -> void:
    var hint_parts: Array[String] = []
    
    for var_name in vars:
        var value = vars[var_name]
        var value_str = _format_value(value)
        hint_parts.append("%s = %s" % [var_name, value_str])
    
    var hint_text = "  // " + ", ".join(hint_parts)
    inline_hints[line] = {"text": hint_text, "vars": vars}

func _format_value(value: Variant) -> String:
    match typeof(value):
        TYPE_STRING:
            return '"%s"' % value
        TYPE_ARRAY:
            if value.size() > 3:
                return "[%s, ... +%d]" % [str(value[0]), value.size() - 1]
            return str(value)
        TYPE_DICTIONARY:
            return "{...%d items}" % value.size()
        _:
            return str(value)

func _clear_all_hints() -> void:
    inline_hints.clear()
```

## 4.4 Path Visualization on Game Map

```gdscript
# path_visualizer.gd
class_name PathVisualizer
extends Node2D

var tracer: ExecutionTracer
var tile_size: Vector2 = Vector2(64, 64)

var path_points: Array[Vector2] = []
var current_position: Vector2 = Vector2.ZERO

var path_color: Color = Color(0.2, 0.6, 1.0, 0.7)
var path_width: float = 4.0
var dot_radius: float = 6.0
var arrow_size: float = 12.0

var show_step_numbers: bool = true
var show_direction_arrows: bool = true
var fade_old_path: bool = true

func _init(execution_tracer: ExecutionTracer) -> void:
    tracer = execution_tracer
    tracer.car_moved.connect(_on_car_moved)
    tracer.execution_started.connect(_clear_path)
    tracer.execution_finished.connect(_finalize_path)

func _on_car_moved(from: Vector2i, to: Vector2i, action: String) -> void:
    var world_from = grid_to_world(from)
    var world_to = grid_to_world(to)
    
    if path_points.is_empty() or path_points[-1] != world_from:
        path_points.append(world_from)
    
    path_points.append(world_to)
    current_position = world_to
    
    queue_redraw()

func grid_to_world(grid_pos: Vector2i) -> Vector2:
    return Vector2(grid_pos) * tile_size + tile_size / 2

func _draw() -> void:
    if path_points.size() < 2:
        return
    
    # Draw path line
    for i in range(path_points.size() - 1):
        var from = path_points[i]
        var to = path_points[i + 1]
        
        var alpha = 1.0
        if fade_old_path:
            alpha = float(i + 1) / path_points.size()
        
        var color = Color(path_color.r, path_color.g, path_color.b, path_color.a * alpha)
        draw_line(from, to, color, path_width, true)
        
        if show_direction_arrows:
            _draw_arrow(from, to, color)
    
    # Draw dots at each point
    for i in range(path_points.size()):
        var point = path_points[i]
        var alpha = 1.0 if not fade_old_path else float(i + 1) / path_points.size()
        var color = Color(path_color.r, path_color.g, path_color.b, alpha)
        
        draw_circle(point, dot_radius, color)
        
        if show_step_numbers:
            var font = ThemeDB.fallback_font
            var text = str(i + 1)
            var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
            draw_string(font, point - text_size / 2 + Vector2(0, 4), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
    
    # Draw current position indicator
    if not path_points.is_empty():
        var last = path_points[-1]
        draw_circle(last, dot_radius + 4, Color.YELLOW)
        draw_circle(last, dot_radius + 2, path_color)

func _draw_arrow(from: Vector2, to: Vector2, color: Color) -> void:
    var direction = (to - from).normalized()
    var mid = (from + to) / 2
    
    var arrow_base = mid - direction * arrow_size / 2
    var perpendicular = Vector2(-direction.y, direction.x)
    
    var tip = mid + direction * arrow_size / 2
    var left = arrow_base + perpendicular * arrow_size / 3
    var right = arrow_base - perpendicular * arrow_size / 3
    
    var points = PackedVector2Array([tip, left, right])
    draw_colored_polygon(points, color)

func _clear_path() -> void:
    path_points.clear()
    queue_redraw()

func _finalize_path() -> void:
    queue_redraw()

func get_total_distance() -> float:
    var total = 0.0
    for i in range(path_points.size() - 1):
        total += path_points[i].distance_to(path_points[i + 1])
    return total

func get_step_count() -> int:
    return path_points.size()
```

## 4.5 Execution Controls UI

```gdscript
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
@onready var speed_label: Label = $HBox/SpeedLabel
@onready var line_label: Label = $HBox/LineLabel
@onready var status_label: Label = $HBox/StatusLabel

var tracer: ExecutionTracer

func _ready() -> void:
    play_button.pressed.connect(func(): play_pressed.emit())
    pause_button.pressed.connect(func(): pause_pressed.emit())
    stop_button.pressed.connect(func(): stop_pressed.emit())
    step_button.pressed.connect(func(): step_pressed.emit())
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
    play_button.disabled = false
    pause_button.disabled = true
    stop_button.disabled = true
    step_button.disabled = false
    status_label.text = "Ready"
    line_label.text = "Line: -"

func _set_running_state() -> void:
    play_button.disabled = true
    pause_button.disabled = false
    stop_button.disabled = false
    step_button.disabled = true
    status_label.text = "Running"

func _set_paused_state() -> void:
    play_button.disabled = false
    pause_button.disabled = true
    stop_button.disabled = false
    step_button.disabled = false
    status_label.text = "Paused"

func _on_line_executed(line: int, _vars: Dictionary) -> void:
    line_label.text = "Line: %d" % (line + 1)

func _on_speed_changed(value: float) -> void:
    speed_label.text = "%.1fx" % value
    speed_changed.emit(value)
```

---

# Feature 5: Performance Metrics

**Objective:** Track and display code efficiency metrics to encourage optimization and provide feedback.

## 5.1 Metrics Data Structure

```gdscript
# performance_metrics.gd
class_name PerformanceMetrics
extends RefCounted

var execution_steps: int = 0
var total_time_ms: float = 0.0
var lines_of_code: int = 0
var function_calls: Dictionary = {}  # func_name -> call_count
var loop_iterations: int = 0
var commands_used: Dictionary = {}   # command -> count
var distance_traveled: float = 0.0
var turns_made: int = 0

# Level-specific metrics
var level_par_steps: int = 0       # "Par" step count for level
var level_par_time: float = 0.0    # "Par" time for level
var level_optimal_loc: int = 0     # Minimum LOC for level

# Rating thresholds (relative to par)
const RATING_EXCELLENT = 0.8   # <= 80% of par
const RATING_GOOD = 1.0        # <= 100% of par
const RATING_OK = 1.3          # <= 130% of par

func reset() -> void:
    execution_steps = 0
    total_time_ms = 0.0
    lines_of_code = 0
    function_calls.clear()
    loop_iterations = 0
    commands_used.clear()
    distance_traveled = 0.0
    turns_made = 0

func record_step() -> void:
    execution_steps += 1

func record_function_call(func_name: String) -> void:
    if not function_calls.has(func_name):
        function_calls[func_name] = 0
    function_calls[func_name] += 1

func record_loop_iteration() -> void:
    loop_iterations += 1

func record_command(command: String) -> void:
    if not commands_used.has(command):
        commands_used[command] = 0
    commands_used[command] += 1

func record_movement(distance: float) -> void:
    distance_traveled += distance

func record_turn() -> void:
    turns_made += 1

func get_step_rating() -> String:
    if level_par_steps <= 0:
        return "N/A"
    
    var ratio = float(execution_steps) / level_par_steps
    if ratio <= RATING_EXCELLENT:
        return "⭐⭐⭐ Excellent"
    elif ratio <= RATING_GOOD:
        return "⭐⭐ Good"
    elif ratio <= RATING_OK:
        return "⭐ OK"
    else:
        return "Needs Improvement"

func get_code_rating() -> String:
    if level_optimal_loc <= 0:
        return "N/A"
    
    var ratio = float(lines_of_code) / level_optimal_loc
    if ratio <= RATING_EXCELLENT:
        return "⭐⭐⭐ Minimal"
    elif ratio <= RATING_GOOD:
        return "⭐⭐ Clean"
    elif ratio <= RATING_OK:
        return "⭐ Adequate"
    else:
        return "Could be shorter"

func get_overall_score() -> int:
    var score = 100.0
    
    if level_par_steps > 0:
        var step_ratio = float(execution_steps) / level_par_steps
        score -= max(0, (step_ratio - 1.0) * 30)
    
    if level_optimal_loc > 0:
        var loc_ratio = float(lines_of_code) / level_optimal_loc
        score -= max(0, (loc_ratio - 1.0) * 20)
    
    return int(clamp(score, 0, 100))

func get_star_rating() -> int:
    var score = get_overall_score()
    if score >= 90:
        return 3
    elif score >= 70:
        return 2
    elif score >= 50:
        return 1
    else:
        return 0
```

## 5.2 Metrics Tracker

```gdscript
# metrics_tracker.gd
class_name MetricsTracker
extends Node

signal metrics_updated(metrics: PerformanceMetrics)

var metrics: PerformanceMetrics
var tracer: ExecutionTracer
var start_time: int = 0

func _init(execution_tracer: ExecutionTracer) -> void:
    metrics = PerformanceMetrics.new()
    tracer = execution_tracer
    
    tracer.execution_started.connect(_on_execution_started)
    tracer.execution_finished.connect(_on_execution_finished)
    tracer.line_executed.connect(_on_line_executed)
    tracer.car_moved.connect(_on_car_moved)

func set_level_pars(par_steps: int, par_time: float, optimal_loc: int) -> void:
    metrics.level_par_steps = par_steps
    metrics.level_par_time = par_time
    metrics.level_optimal_loc = optimal_loc

func analyze_code(code: String) -> void:
    var lines = code.split("\n")
    var loc = 0
    
    for line in lines:
        var stripped = line.strip_edges()
        if not stripped.is_empty() and not stripped.begins_with("#"):
            loc += 1
    
    metrics.lines_of_code = loc

func _on_execution_started() -> void:
    metrics.reset()
    start_time = Time.get_ticks_msec()

func _on_execution_finished() -> void:
    metrics.total_time_ms = Time.get_ticks_msec() - start_time
    metrics_updated.emit(metrics)

func _on_line_executed(line: int, variables: Dictionary) -> void:
    metrics.record_step()

func _on_car_moved(from: Vector2i, to: Vector2i, action: String) -> void:
    metrics.record_command(action)
    
    var distance = Vector2(to - from).length()
    metrics.record_movement(distance)
    
    if "turn" in action:
        metrics.record_turn()

func get_metrics() -> PerformanceMetrics:
    return metrics
```

## 5.3 Metrics Panel UI

```gdscript
# metrics_panel.gd
extends PanelContainer
class_name MetricsPanel

@onready var steps_label: Label = $VBox/Grid/StepsValue
@onready var steps_rating: Label = $VBox/Grid/StepsRating
@onready var time_label: Label = $VBox/Grid/TimeValue
@onready var loc_label: Label = $VBox/Grid/LOCValue
@onready var loc_rating: Label = $VBox/Grid/LOCRating
@onready var distance_label: Label = $VBox/Grid/DistanceValue
@onready var turns_label: Label = $VBox/Grid/TurnsValue

@onready var overall_score: Label = $VBox/ScoreSection/ScoreValue
@onready var star_display: HBoxContainer = $VBox/ScoreSection/Stars
@onready var commands_tree: Tree = $VBox/CommandsSection/CommandsTree

var star_filled: Texture2D
var star_empty: Texture2D

func _ready() -> void:
    commands_tree.create_item()
    commands_tree.hide_root = true
    commands_tree.columns = 2
    commands_tree.set_column_title(0, "Command")
    commands_tree.set_column_title(1, "Count")

func update_metrics(metrics: PerformanceMetrics) -> void:
    steps_label.text = str(metrics.execution_steps)
    steps_rating.text = metrics.get_step_rating()
    _color_rating(steps_rating, metrics.execution_steps, metrics.level_par_steps)
    
    time_label.text = "%.2f s" % (metrics.total_time_ms / 1000.0)
    
    loc_label.text = str(metrics.lines_of_code)
    loc_rating.text = metrics.get_code_rating()
    _color_rating(loc_rating, metrics.lines_of_code, metrics.level_optimal_loc)
    
    distance_label.text = "%.1f units" % metrics.distance_traveled
    turns_label.text = str(metrics.turns_made)
    
    var score = metrics.get_overall_score()
    overall_score.text = "%d / 100" % score
    overall_score.add_theme_color_override("font_color", _get_score_color(score))
    
    _update_stars(metrics.get_star_rating())
    _update_commands_tree(metrics.commands_used)

func _color_rating(label: Label, value: int, par: int) -> void:
    if par <= 0:
        label.add_theme_color_override("font_color", Color.GRAY)
        return
    
    var ratio = float(value) / par
    var color: Color
    
    if ratio <= 0.8:
        color = Color.GREEN
    elif ratio <= 1.0:
        color = Color.YELLOW_GREEN
    elif ratio <= 1.3:
        color = Color.YELLOW
    else:
        color = Color.ORANGE_RED
    
    label.add_theme_color_override("font_color", color)

func _get_score_color(score: int) -> Color:
    if score >= 90:
        return Color.GREEN
    elif score >= 70:
        return Color.YELLOW_GREEN
    elif score >= 50:
        return Color.YELLOW
    else:
        return Color.ORANGE_RED

func _update_stars(count: int) -> void:
    for i in range(star_display.get_child_count()):
        var star = star_display.get_child(i) as TextureRect
        star.texture = star_filled if i < count else star_empty

func _update_commands_tree(commands: Dictionary) -> void:
    var root = commands_tree.get_root()
    for child in root.get_children():
        child.free()
    
    var sorted_commands: Array = []
    for cmd in commands:
        sorted_commands.append({"name": cmd, "count": commands[cmd]})
    sorted_commands.sort_custom(func(a, b): return a.count > b.count)
    
    for cmd_data in sorted_commands:
        var item = commands_tree.create_item(root)
        item.set_text(0, cmd_data.name)
        item.set_text(1, str(cmd_data.count))
```

## 5.4 Level Completion Summary

```gdscript
# completion_summary.gd
extends Control
class_name CompletionSummary

signal retry_pressed
signal next_level_pressed

@onready var title_label: Label = $Panel/VBox/Title
@onready var star_container: HBoxContainer = $Panel/VBox/Stars
@onready var score_label: Label = $Panel/VBox/Score
@onready var feedback_label: RichTextLabel = $Panel/VBox/Feedback
@onready var tips_label: Label = $Panel/VBox/Tips
@onready var retry_button: Button = $Panel/VBox/Buttons/RetryButton
@onready var next_button: Button = $Panel/VBox/Buttons/NextButton

var star_filled: Texture2D
var star_empty: Texture2D

func _ready() -> void:
    retry_button.pressed.connect(func(): retry_pressed.emit())
    next_button.pressed.connect(func(): next_level_pressed.emit())
    hide()

func show_summary(metrics: PerformanceMetrics, level_name: String) -> void:
    title_label.text = "Level Complete: %s" % level_name
    
    var stars = metrics.get_star_rating()
    _display_stars(stars)
    
    var score = metrics.get_overall_score()
    score_label.text = "Score: %d / 100" % score
    
    feedback_label.text = _generate_feedback(metrics)
    tips_label.text = _generate_tips(metrics)
    
    show()

func _display_stars(count: int) -> void:
    for i in range(3):
        var star = star_container.get_child(i) as TextureRect
        star.texture = star_filled if i < count else star_empty
        
        if i < count:
            var tween = create_tween()
            star.scale = Vector2.ZERO
            tween.tween_property(star, "scale", Vector2.ONE, 0.3).set_delay(i * 0.2)
            tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)

func _generate_feedback(metrics: PerformanceMetrics) -> String:
    var stars = metrics.get_star_rating()
    
    match stars:
        3:
            return "[color=green]★ Perfect! ★[/color]\nYour solution is optimal!"
        2:
            return "[color=yellow]Great job![/color]\nCan you optimize it further?"
        1:
            return "[color=orange]Good effort![/color]\nTry to reduce your step count."
        _:
            return "[color=red]Completed[/color]\nThere's room for improvement."

func _generate_tips(metrics: PerformanceMetrics) -> String:
    var tips: Array[String] = []
    
    if metrics.level_par_steps > 0:
        var ratio = float(metrics.execution_steps) / metrics.level_par_steps
        if ratio > 1.3:
            tips.append("💡 Try using loops to reduce repetitive commands")
    
    if metrics.level_optimal_loc > 0:
        var ratio = float(metrics.lines_of_code) / metrics.level_optimal_loc
        if ratio > 1.5:
            tips.append("💡 Consider combining commands or using functions")
    
    if metrics.turns_made > metrics.distance_traveled / 2:
        tips.append("💡 Plan your route more efficiently")
    
    if tips.is_empty():
        return ""
    
    return "\n".join(tips)
```

---

# Deliverables

## Feature 1: Error Highlighting & Linting
1. `LinterRules.gd` - Rule definitions and known symbols
2. `Linter.gd` - Core linting engine with diagnostics
3. `ErrorHighlighter.gd` - Visual error display in CodeEdit
4. `ErrorPanel.tscn` + `ErrorPanel.gd` - Error list UI
5. Error/warning icon assets

## Feature 2: Code Snippets
1. `Snippet.gd` - Snippet data structure with tab stops
2. `SnippetLibrary.gd` - Built-in snippets collection
3. `SnippetHandler.gd` - Expansion and tab stop navigation
4. `SnippetPopup.tscn` + `SnippetPopup.gd` - Snippet chooser UI

## Feature 3: Code Folding
1. `FoldRegion.gd` - Fold region data structure
2. `FoldManager.gd` - Fold detection and state management
3. `FoldGutter.gd` - Fold indicators in gutter
4. Fold/unfold icon assets

## Feature 4: Execution Visualization
1. `ExecutionTracer.gd` - Core execution tracking
2. `ExecutionHighlighter.gd` - Line highlighting during execution
3. `InlineVariableDisplay.gd` - Inline variable values
4. `PathVisualizer.gd` - Path drawing on game map
5. `ExecutionControls.tscn` + `ExecutionControls.gd` - Play/pause/step UI

## Feature 5: Performance Metrics
1. `PerformanceMetrics.gd` - Metrics data structure
2. `MetricsTracker.gd` - Metrics collection during execution
3. `MetricsPanel.tscn` + `MetricsPanel.gd` - Metrics display UI
4. `CompletionSummary.tscn` + `CompletionSummary.gd` - Level completion screen

---

# Testing Scenarios

## Error Highlighting
1. Typing `def foo(` shows unclosed parenthesis error
2. Typing `pritn` suggests `print` as correction
3. Unused variable shows warning after 2 seconds
4. Clicking error in panel jumps to line

## Code Snippets
1. Typing `fori` + Tab expands to for loop
2. Tab navigates between placeholders
3. Shift+Tab goes to previous placeholder
4. Escape cancels snippet mode

## Code Folding
1. Clicking fold icon collapses function
2. Folded region shows preview text
3. Ctrl+Shift+[ folds current block
4. Ctrl+Shift+9 unfolds all

## Execution Visualization
1. Current line highlights yellow during execution
2. Breakpoint pauses execution
3. Path draws on map as car moves
4. Variables display inline during step

## Performance Metrics
1. Step count increments during execution
2. Star rating updates on completion
3. Commands breakdown shows usage
4. Tips suggest improvements
