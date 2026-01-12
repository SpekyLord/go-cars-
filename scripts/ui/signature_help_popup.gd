## Signature Help Popup for GoCars Code Editor
## Shows function parameter hints while typing
## Author: Claude Code
## Date: January 2026

extends PopupPanel
class_name SignatureHelpPopup

var signature_label: RichTextLabel
var param_label: Label
var doc_label: Label

var current_function: Dictionary = {}
var current_param_index: int = 0

func _init() -> void:
	size = Vector2(400, 100)

func _build_ui() -> void:
	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(vbox)

	# Signature label with rich text
	signature_label = RichTextLabel.new()
	signature_label.bbcode_enabled = true
	signature_label.fit_content = true
	signature_label.scroll_active = false
	signature_label.custom_minimum_size = Vector2(0, 25)
	vbox.add_child(signature_label)

	# Parameter indicator
	param_label = Label.new()
	param_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	vbox.add_child(param_label)

	# Documentation
	doc_label = Label.new()
	doc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	doc_label.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(doc_label)

func _ready() -> void:
	_build_ui()
	hide()

func show_signature(func_data: Dictionary, param_index: int, position: Vector2) -> void:
	current_function = func_data
	current_param_index = param_index

	_render_signature()

	_set_popup_position(position)
	popup()

func _render_signature() -> void:
	if current_function.is_empty():
		return

	var sig = current_function.signature
	var params = _parse_parameters(sig)

	# Build rich text with current param highlighted
	var rich_text = "[code]"
	var func_name = sig.split("(")[0]
	rich_text += func_name + "("

	for i in range(params.size()):
		if i > 0:
			rich_text += ", "
		if i == current_param_index:
			rich_text += "[color=#FFD700][b]" + params[i] + "[/b][/color]"
		else:
			rich_text += params[i]

	rich_text += ")[/code]"

	signature_label.text = rich_text

	# Show param info
	if current_param_index < params.size():
		param_label.text = "Parameter %d of %d" % [current_param_index + 1, params.size()]
	else:
		param_label.text = "Too many arguments"

	doc_label.text = current_function.get("doc", "")

func _parse_parameters(signature: String) -> Array[String]:
	var params: Array[String] = []
	var start = signature.find("(")
	var end = signature.rfind(")")

	if start == -1 or end == -1:
		return params

	var param_str = signature.substr(start + 1, end - start - 1)
	if param_str.strip_edges().is_empty():
		return params

	# Simple split (doesn't handle nested generics, but works for our use case)
	for p in param_str.split(","):
		params.append(p.strip_edges())

	return params

func update_param_index(index: int) -> void:
	current_param_index = index
	_render_signature()

func _set_popup_position(pos: Vector2) -> void:
	if not is_inside_tree():
		return

	var viewport = get_viewport()
	if not viewport:
		return

	var screen_size = viewport.get_visible_rect().size
	var final_pos = Vector2(pos.x, pos.y - size.y - 5)

	if final_pos.x + size.x > screen_size.x:
		final_pos.x = screen_size.x - size.x
	if final_pos.y < 0:
		# Show below cursor instead
		final_pos.y = 30

	set_position(final_pos)
