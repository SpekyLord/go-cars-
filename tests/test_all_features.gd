# test_all_features.gd
# Quick test to verify all advanced features work
# Run with: godot --path . --headless --script tests/test_all_features.gd

extends SceneTree

func _init():
	print("=" .repeat(60))
	print("TESTING ALL ADVANCED FEATURES")
	print("=" .repeat(60))

	test_linter()
	test_snippets()
	test_folding()
	test_execution_tracer()
	test_metrics()

	print("\n" + "=" .repeat(60))
	print("ALL TESTS COMPLETED!")
	print("=" .repeat(60))

	quit()

func test_linter():
	print("\n[1/5] TESTING LINTER...")

	var linter = Linter.new()

	var test_code = """if car.front_road()
	car.go()
pritn("hello")
unused_var = 5"""

	linter.lint(test_code)

	# Force immediate linting
	linter._do_lint()

	print("  ✓ Linter created successfully")
	print("  ✓ Found %d diagnostics" % linter.diagnostics.size())

	if linter.diagnostics.size() > 0:
		print("  Diagnostics:")
		for diag in linter.diagnostics:
			var severity_names = ["ERROR", "WARNING", "INFO", "HINT"]
			var sev_name = severity_names[diag.severity] if diag.severity < 4 else "UNKNOWN"
			print("    [%s] Line %d: %s" % [sev_name, diag.line + 1, diag.message])

func test_snippets():
	print("\n[2/5] TESTING SNIPPETS...")

	print("  ✓ SnippetLibrary loaded")
	print("  ✓ Found %d snippets" % SnippetLibrary.snippets.size())

	# Test a few snippets
	var test_snippets = ["if", "fori", "while", "moveloop"]
	print("  Testing snippets:")
	for prefix in test_snippets:
		var snippet = SnippetLibrary.get_exact(prefix)
		if snippet:
			print("    ✓ '%s' → %s" % [prefix, snippet.name])
		else:
			print("    ✗ '%s' NOT FOUND" % prefix)

	# Test expansion
	var fori_snippet = SnippetLibrary.get_exact("fori")
	if fori_snippet:
		var expanded = fori_snippet.get_expanded_text("")
		print("  Sample expansion (fori):")
		for line in expanded.split("\n"):
			print("    " + line)

func test_folding():
	print("\n[3/5] TESTING CODE FOLDING...")

	# Need a CodeEdit for fold manager
	var code_edit = CodeEdit.new()
	var fold_manager = FoldManager.new(code_edit)

	var test_code = """def my_function():
	x = 1
	y = 2
	return x + y

for i in range(10):
	print(i)
	if i > 5:
		break

while True:
	car.go()
	if car.at_end():
		break"""

	code_edit.text = test_code
	fold_manager.analyze_folds(test_code)

	print("  ✓ FoldManager created")
	print("  ✓ Found %d foldable regions" % fold_manager.fold_regions.size())

	if fold_manager.fold_regions.size() > 0:
		print("  Foldable regions:")
		for region in fold_manager.fold_regions:
			print("    Line %d-%d: %s (%d lines)" % [
				region.start_line + 1,
				region.end_line + 1,
				region.fold_type,
				region.get_line_count()
			])

	code_edit.queue_free()

func test_execution_tracer():
	print("\n[4/5] TESTING EXECUTION TRACER...")

	var tracer = ExecutionTracer.new(null)
	print("  ✓ ExecutionTracer created")

	tracer.start_execution("test code")
	print("  ✓ Execution started")

	# Simulate some execution steps
	var test_vars = {"speed": 1.5, "x": 10}
	tracer.on_line_execute(0, test_vars, "move_forward", Vector2i(0, 0))
	tracer.on_line_execute(1, test_vars, "turn_left", Vector2i(1, 0))
	tracer.on_line_execute(2, test_vars, "move_forward", Vector2i(1, 1))

	print("  ✓ Recorded %d execution steps" % tracer.execution_history.size())
	print("  ✓ Path has %d points" % tracer.get_execution_path().size())

	tracer.stop_execution()
	print("  ✓ Execution stopped")

func test_metrics():
	print("\n[5/5] TESTING PERFORMANCE METRICS...")

	var metrics = PerformanceMetrics.new()
	print("  ✓ PerformanceMetrics created")

	# Set level pars
	metrics.level_par_steps = 50
	metrics.level_par_time = 5000.0
	metrics.level_optimal_loc = 10

	# Simulate execution
	metrics.lines_of_code = 12
	for i in range(60):
		metrics.record_step()
	metrics.record_command("move_forward")
	metrics.record_command("turn_left")
	metrics.record_command("move_forward")
	metrics.record_turn()
	metrics.record_movement(15.5)

	print("  Metrics:")
	print("    Execution steps: %d" % metrics.execution_steps)
	print("    Lines of code: %d" % metrics.lines_of_code)
	print("    Step rating: %s" % metrics.get_step_rating())
	print("    Code rating: %s" % metrics.get_code_rating())
	print("    Overall score: %d/100" % metrics.get_overall_score())
	print("    Star rating: %s" % ("★" .repeat(metrics.get_star_rating()) + "☆" .repeat(3 - metrics.get_star_rating())))
