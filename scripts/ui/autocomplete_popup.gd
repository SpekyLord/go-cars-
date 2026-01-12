## Autocomplete Popup for GoCars Code Editor
## Shows code suggestions with documentation
## Author: Claude Code
## Date: January 2026

extends PopupPanel
class_name AutocompletePopup

signal suggestion_selected(text: String)
signal cancelled

var item_list: ItemList
var doc_panel: PanelContainer
var doc_label: RichTextLabel
var signature_label: Label

var suggestions: Array[Dictionary] = []
var filtered_suggestions: Array[Dictionary] = []
var current_prefix: String = ""
var selected_index: int = 0

func _init() -> void:
	# Setup popup properties
	size = Vector2(400, 300)

func _build_ui() -> void:
	# Main VBox layout
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vbox)

	# Item list for suggestions
	item_list = ItemList.new()
	item_list.custom_minimum_size = Vector2(0, 200)
	item_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_list.allow_reselect = true
	vbox.add_child(item_list)

	# Separator
	var separator = HSeparator.new()
	vbox.add_child(separator)

	# Signature label
	signature_label = Label.new()
	signature_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	vbox.add_child(signature_label)

	# Documentation panel
	doc_panel = PanelContainer.new()
	doc_panel.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(doc_panel)

	doc_label = RichTextLabel.new()
	doc_label.bbcode_enabled = true
	doc_label.fit_content = true
	doc_label.scroll_active = false
	doc_panel.add_child(doc_label)

func _ready() -> void:
	_build_ui()
	item_list.item_selected.connect(_on_item_selected)
	item_list.item_activated.connect(_on_item_activated)
	hide()

func show_suggestions(items: Array[Dictionary], prefix: String, position: Vector2) -> void:
	suggestions = items
	current_prefix = prefix
	_filter_and_display()

	if filtered_suggestions.is_empty():
		hide()
		return

	# Position popup near cursor
	_set_popup_position(position)
	popup()
	if item_list:
		item_list.grab_focus()
	_select_item(0)

func _filter_and_display() -> void:
	filtered_suggestions.clear()
	item_list.clear()

	var prefix_lower = current_prefix.to_lower()

	for suggestion in suggestions:
		if suggestion.name.to_lower().begins_with(prefix_lower):
			filtered_suggestions.append(suggestion)

	# Limit to top 20 results
	if filtered_suggestions.size() > 20:
		filtered_suggestions.resize(20)

	for suggestion in filtered_suggestions:
		var display_name = suggestion.name
		# Add type indicator
		var type_indicator = _get_type_indicator(suggestion.type)
		var idx = item_list.add_item(type_indicator + " " + display_name)

		# Color code by type
		var color = _get_type_color(suggestion.type)
		item_list.set_item_custom_fg_color(idx, color)

func update_filter(new_prefix: String) -> void:
	current_prefix = new_prefix
	_filter_and_display()

	if filtered_suggestions.is_empty():
		hide()
	else:
		_select_item(0)

func select_next() -> void:
	if filtered_suggestions.is_empty():
		return
	_select_item((selected_index + 1) % filtered_suggestions.size())

func select_previous() -> void:
	if filtered_suggestions.is_empty():
		return
	_select_item((selected_index - 1 + filtered_suggestions.size()) % filtered_suggestions.size())

func _select_item(index: int) -> void:
	if index < 0 or index >= filtered_suggestions.size():
		return

	selected_index = index
	item_list.select(index)
	item_list.ensure_current_is_visible()
	_update_documentation()

func _update_documentation() -> void:
	if selected_index >= filtered_suggestions.size():
		return

	var suggestion = filtered_suggestions[selected_index]
	signature_label.text = suggestion.get("signature", suggestion.name)

	var doc_text = suggestion.get("doc", "No documentation available.")
	var category = suggestion.get("category", "")
	if not category.is_empty():
		doc_text = "[b]Category:[/b] " + category + "\n" + doc_text

	doc_label.text = doc_text
	doc_panel.show()

func confirm_selection() -> String:
	if filtered_suggestions.is_empty():
		return ""

	var suggestion = filtered_suggestions[selected_index]
	var insert_text = suggestion.name

	# Add parentheses for functions (but position cursor inside)
	if suggestion.type == "function" or suggestion.type == "builtin":
		insert_text += "()"

	hide()
	suggestion_selected.emit(insert_text)
	return insert_text

func cancel() -> void:
	hide()
	cancelled.emit()

func _on_item_selected(index: int) -> void:
	_select_item(index)

func _on_item_activated(index: int) -> void:
	_select_item(index)
	confirm_selection()

func _set_popup_position(pos: Vector2) -> void:
	if not is_inside_tree():
		return

	var viewport = get_viewport()
	if not viewport:
		return

	var screen_size = viewport.get_visible_rect().size
	var popup_size = size
	var final_pos = pos

	if final_pos.x + popup_size.x > screen_size.x:
		final_pos.x = screen_size.x - popup_size.x
	if final_pos.y + popup_size.y > screen_size.y:
		# Show above cursor
		final_pos.y = final_pos.y - popup_size.y - 20

	# Ensure not off-screen
	final_pos.x = max(0, final_pos.x)
	final_pos.y = max(0, final_pos.y)

	set_position(final_pos)

func _get_type_indicator(type: String) -> String:
	match type:
		"function": return "ƒ"
		"builtin": return "λ"
		"keyword": return "◆"
		"variable": return "χ"
		"class": return "▣"
		"object": return "●"
		_: return "○"

func _get_type_color(type: String) -> Color:
	match type:
		"function": return Color(0.65, 0.88, 0.18)  # Green
		"builtin": return Color(0.40, 0.85, 0.92)   # Cyan
		"keyword": return Color(0.79, 0.41, 0.58)   # Pink
		"variable": return Color(0.61, 0.81, 1.0)   # Light blue
		"class": return Color(0.80, 0.73, 0.46)     # Yellow
		"object": return Color(1.0, 0.60, 0.40)     # Orange
		_: return Color(0.8, 0.8, 0.8)              # Gray
