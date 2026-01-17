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
	if commands_tree:
		commands_tree.create_item()
		commands_tree.hide_root = true
		commands_tree.columns = 2
		commands_tree.set_column_title(0, "Command")
		commands_tree.set_column_title(1, "Count")

func update_metrics(metrics: PerformanceMetrics) -> void:
	if steps_label:
		steps_label.text = str(metrics.execution_steps)
	if steps_rating:
		steps_rating.text = metrics.get_step_rating()
		_color_rating(steps_rating, metrics.execution_steps, metrics.level_par_steps)

	if time_label:
		time_label.text = "%.2f s" % (metrics.total_time_ms / 1000.0)

	if loc_label:
		loc_label.text = str(metrics.lines_of_code)
	if loc_rating:
		loc_rating.text = metrics.get_code_rating()
		_color_rating(loc_rating, metrics.lines_of_code, metrics.level_optimal_loc)

	if distance_label:
		distance_label.text = "%.1f units" % metrics.distance_traveled
	if turns_label:
		turns_label.text = str(metrics.turns_made)

	var score = metrics.get_overall_score()
	if overall_score:
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
	if not star_display:
		return

	for i in range(star_display.get_child_count()):
		var star = star_display.get_child(i) as TextureRect
		if star:
			star.texture = star_filled if i < count else star_empty

func _update_commands_tree(commands: Dictionary) -> void:
	if not commands_tree:
		return

	var root = commands_tree.get_root()
	if root:
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
