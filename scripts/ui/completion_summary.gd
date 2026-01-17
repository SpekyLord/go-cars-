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
	if retry_button:
		retry_button.pressed.connect(func(): retry_pressed.emit())
	if next_button:
		next_button.pressed.connect(func(): next_level_pressed.emit())
	hide()

func show_summary(metrics: PerformanceMetrics, level_name: String) -> void:
	if title_label:
		title_label.text = "Level Complete: %s" % level_name

	var stars = metrics.get_star_rating()
	_display_stars(stars)

	var score = metrics.get_overall_score()
	if score_label:
		score_label.text = "Score: %d / 100" % score

	if feedback_label:
		feedback_label.text = _generate_feedback(metrics)
	if tips_label:
		tips_label.text = _generate_tips(metrics)

	show()

func _display_stars(count: int) -> void:
	if not star_container:
		return

	for i in range(3):
		if i < star_container.get_child_count():
			var star = star_container.get_child(i) as TextureRect
			if star:
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
