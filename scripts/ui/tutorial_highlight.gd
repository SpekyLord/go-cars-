## Tutorial Highlight System for GoCars
## Creates a spotlight effect to highlight UI elements during tutorials
## Author: Claude Code
## Date: January 2026

extends CanvasLayer

## Child nodes
@onready var dark_overlay: ColorRect = $DarkOverlay
@onready var spotlight_rect: ColorRect = $SpotlightRect
@onready var pointer_arrow: Label = $PointerArrow
@onready var hint_label: Label = $HintLabel

## Tween for animations
var tween: Tween

## Target tracking
var current_target: Control = null
var is_highlighting: bool = false

## Margin around highlighted element
const SPOTLIGHT_MARGIN: float = 10.0

## Bounce animation settings
const BOUNCE_DISTANCE: float = 15.0
const BOUNCE_DURATION: float = 0.6

func _ready() -> void:
	# Start hidden
	visible = false
	print("TutorialHighlight: Ready")

## Highlight a target UI element
func highlight_target(target_name: String, hint: String = "") -> void:
	# Find the target node
	var target = _find_target(target_name)
	
	if not target:
		push_warning("TutorialHighlight: Target '%s' not found" % target_name)
		return
	
	current_target = target
	is_highlighting = true
	visible = true
	
	print("TutorialHighlight: Highlighting '%s'" % target_name)
	
	# Position spotlight and pointer
	_update_spotlight_position()
	
	# Set hint text
	if hint.is_empty():
		hint_label.text = ""
		hint_label.visible = false
	else:
		hint_label.text = hint
		hint_label.visible = true
		_position_hint_label()
	
	# Animate in
	_animate_show()
	
	# Start bounce animation
	_start_bounce_animation()

## Clear the highlight
func clear_highlight() -> void:
	if not is_highlighting:
		return
	
	is_highlighting = false
	current_target = null
	
	print("TutorialHighlight: Clearing highlight")
	
	# Stop animations
	if tween:
		tween.kill()
	
	# Fade out
	_animate_hide()

## Find target by name or path
func _find_target(target_name: String) -> Control:
	# Normalize target name
	target_name = target_name.to_lower().strip_edges()
	
	# Get root node (main scene)
	var root = get_tree().root
	
	# Common target mappings
	var targets = {
		"run_button": ["RunButton", "CodeEditorWindow/VBoxContainer/ContentContainer/ContentVBox/ControlBar/RunButton"],
		"pause_button": ["PauseButton", "CodeEditorWindow/VBoxContainer/ContentContainer/ContentVBox/ControlBar/PauseButton"],
		"reset_button": ["ResetButton", "CodeEditorWindow/VBoxContainer/ContentContainer/ContentVBox/ControlBar/ResetButton"],
		"code_editor": ["CodeEditorWindow", "CodeEditor"],
		"toolbar": ["Toolbar"],
		"code_editor_button": ["CodeEditorButton", "Toolbar/CodeEditorButton"],
		"readme_button": ["ReadmeButton", "Toolbar/ReadmeButton"],
		"skill_tree_button": ["SkillTreeButton", "Toolbar/SkillTreeButton"],
		"file_explorer": ["FileExplorer", "CodeEditorWindow/VBoxContainer/ContentContainer/ContentVBox/MainVSplit/HSplit/FileExplorer"],
		"code_edit": ["CodeEdit", "CodeEditorWindow/VBoxContainer/ContentContainer/ContentVBox/MainVSplit/HSplit/CodeEdit"],
	}
	
	# Try to find mapped target
	if target_name in targets:
		for path in targets[target_name]:
			var target = _find_node_by_name(root, path)
			if target:
				return target
	
	# Try direct name search
	var target = _find_node_by_name(root, target_name)
	if target:
		return target
	
	return null

## Recursively find node by name
func _find_node_by_name(node: Node, target_name: String) -> Control:
	# Check if this node matches
	if node.name == target_name and node is Control:
		return node as Control
	
	# Check children
	for child in node.get_children():
		var result = _find_node_by_name(child, target_name)
		if result:
			return result
	
	return null

## Update spotlight position based on target
func _update_spotlight_position() -> void:
	if not current_target or not is_instance_valid(current_target):
		return
	
	# Get target's global rect
	var target_rect = current_target.get_global_rect()
	
	# Expand rect with margin
	var spotlight_pos = target_rect.position - Vector2(SPOTLIGHT_MARGIN, SPOTLIGHT_MARGIN)
	var spotlight_size = target_rect.size + Vector2(SPOTLIGHT_MARGIN * 2, SPOTLIGHT_MARGIN * 2)
	
	# Position spotlight rect
	spotlight_rect.position = spotlight_pos
	spotlight_rect.size = spotlight_size
	
	# Position pointer arrow above target
	var arrow_pos = Vector2(
		target_rect.position.x + target_rect.size.x / 2 - pointer_arrow.size.x / 2,
		target_rect.position.y - pointer_arrow.size.y - 10
	)
	pointer_arrow.position = arrow_pos

## Position hint label near target
func _position_hint_label() -> void:
	if not current_target or not is_instance_valid(current_target):
		return
	
	var target_rect = current_target.get_global_rect()
	
	# Position hint below pointer arrow
	var hint_pos = Vector2(
		target_rect.position.x + target_rect.size.x / 2 - hint_label.size.x / 2,
		target_rect.position.y - pointer_arrow.size.y - hint_label.size.y - 20
	)
	
	# Keep within screen bounds
	var screen_size = get_viewport().get_visible_rect().size
	hint_pos.x = clamp(hint_pos.x, 10, screen_size.x - hint_label.size.x - 10)
	hint_pos.y = clamp(hint_pos.y, 10, screen_size.y - hint_label.size.y - 10)
	
	hint_label.position = hint_pos

## Animate show
func _animate_show() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Fade in dark overlay
	tween.tween_property(dark_overlay, "modulate:a", 1.0, 0.3)
	
	# Fade in pointer and hint
	tween.tween_property(pointer_arrow, "modulate:a", 1.0, 0.4)
	if hint_label.visible:
		tween.tween_property(hint_label, "modulate:a", 1.0, 0.4)

## Animate hide
func _animate_hide() -> void:
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Fade out all elements
	tween.tween_property(dark_overlay, "modulate:a", 0.0, 0.2)
	tween.tween_property(pointer_arrow, "modulate:a", 0.0, 0.2)
	tween.tween_property(hint_label, "modulate:a", 0.0, 0.2)
	
	# Hide when done
	tween.finished.connect(func(): visible = false)

## Start bounce animation for pointer arrow
func _start_bounce_animation() -> void:
	if not is_highlighting:
		return
	
	# Store original position
	var original_y = pointer_arrow.position.y
	
	# Create bounce tween
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Bounce down and up
	tween.tween_property(pointer_arrow, "position:y", original_y + BOUNCE_DISTANCE, BOUNCE_DURATION / 2)
	tween.tween_property(pointer_arrow, "position:y", original_y, BOUNCE_DURATION / 2)

## Process to update position if target moves
func _process(_delta: float) -> void:
	if is_highlighting and current_target and is_instance_valid(current_target):
		_update_spotlight_position()
		if hint_label.visible:
			_position_hint_label()
