# Advanced Features Testing Guide

## Pre-Testing Checklist

Before running tests, ensure:
- [ ] All 19 core GDScript files are in place (`scripts/core/` and `scripts/ui/`)
- [ ] All 4 UI scene files are created (`scenes/ui/*.tscn`)
- [ ] Icon generator is functional (`scripts/ui/icon_generator.gd`)
- [ ] Enhanced editor is integrated (`scripts/ui/code_editor_window_enhanced.gd`)
- [ ] Godot 4.5.1 is installed and accessible

---

## Manual Testing Procedures

### Feature 1: Error Highlighting & Linting

#### Test 1.1: Syntax Errors
**Steps:**
1. Open the enhanced code editor
2. Type: `if True`
3. **Expected**: Red wavy underline, error shows "Missing ':' after if condition"

#### Test 1.2: Typo Detection
**Steps:**
1. Type: `pritn("hello")`
2. **Expected**: Error shows "'pritn' is not defined. Did you mean 'print'?"

#### Test 1.3: Unused Variables
**Steps:**
1. Type:
   ```python
   x = 5
   y = 10
   car.go()
   ```
2. **Expected**: Warnings for unused variables 'x' and 'y'

#### Test 1.4: Bracket Balance
**Steps:**
1. Type: `car.turn("left"`
2. **Expected**: Error "Unclosed string or parenthesis"

#### Test 1.5: Error Panel Navigation
**Steps:**
1. Create code with multiple errors
2. Click "🐛 Errors" button to show panel
3. Click an error in the list
4. **Expected**: Cursor jumps to error line and column

**Pass Criteria:** All 5 tests show correct errors/warnings, panel navigation works

---

### Feature 2: Code Snippets/Templates

#### Test 2.1: Basic Snippet Expansion
**Steps:**
1. Type: `fori`
2. Press **Tab**
3. **Expected**: Expands to `for i in range(10):` with cursor at "10"

#### Test 2.2: Tab Stop Navigation
**Steps:**
1. Type: `def` and press Tab
2. Type `move_forward`
3. Press **Tab**
4. Type `steps`
5. Press **Tab**
6. **Expected**: Cursor moves through: function name → parameters → body

#### Test 2.3: Shift+Tab Previous Navigation
**Steps:**
1. Expand snippet with Tab
2. Press Tab twice to move forward
3. Press **Shift+Tab**
4. **Expected**: Cursor moves back to previous tab stop

#### Test 2.4: Escape to Cancel
**Steps:**
1. Expand snippet with Tab
2. Press **Escape**
3. **Expected**: Snippet mode cancels, placeholders remain as text

#### Test 2.5: Game-Specific Snippets
**Steps:**
1. Type: `moveloop`
2. Press **Tab**
3. **Expected**: Expands to complete movement loop template:
   ```python
   while not car.at_end():
       if car.front_road():
           car.go()
       else:
           car.stop()
   ```

**Pass Criteria:** All snippets expand correctly, tab navigation works both directions

---

### Feature 3: Code Folding

#### Test 3.1: Function Folding
**Steps:**
1. Type:
   ```python
   def move():
       car.go()
       car.stop()
   ```
2. Click fold icon (▼) in gutter next to `def`
3. **Expected**: Function body collapses, shows preview "... (2 lines)"

#### Test 3.2: Loop Folding
**Steps:**
1. Type:
   ```python
   for i in range(5):
       car.go()
       car.wait(1)
   ```
2. Click fold icon next to `for`
3. **Expected**: Loop body collapses

#### Test 3.3: Conditional Folding
**Steps:**
1. Type:
   ```python
   if car.front_road():
       car.go()
   else:
       car.stop()
   ```
2. Click fold icon next to `if`
3. **Expected**: If-else block collapses

#### Test 3.4: Keyboard Shortcuts
**Steps:**
1. Place cursor inside a foldable block
2. Press **Ctrl+Shift+[**
3. **Expected**: Block folds
4. Press **Ctrl+Shift+]**
5. **Expected**: Block unfolds

#### Test 3.5: Fold All / Unfold All
**Steps:**
1. Create multiple foldable blocks
2. Press **Ctrl+Shift+0**
3. **Expected**: All blocks fold
4. Press **Ctrl+Shift+9**
5. **Expected**: All blocks unfold

**Pass Criteria:** All fold/unfold operations work, preview text shows correctly

---

### Feature 4: Execution Visualization

#### Test 4.1: Line Highlighting
**Steps:**
1. Write simple code:
   ```python
   car.go()
   car.stop()
   ```
2. Press **F5** to run
3. **Expected**:
   - Line 1 highlights yellow
   - Then line 2 highlights yellow
   - Execution arrow (➡️) appears in gutter

#### Test 4.2: Breakpoints
**Steps:**
1. Write code with multiple lines
2. Click line number gutter on line 3
3. **Expected**: Red dot appears
4. Press F5
5. **Expected**: Execution pauses at line 3 (yellow highlight)
6. Press F10 to step
7. **Expected**: Advances to next line

#### Test 4.3: Play/Pause/Step Controls
**Steps:**
1. Write loop code:
   ```python
   for i in range(10):
       car.go()
   ```
2. Press **F5** to run
3. Press **Space** to pause
4. **Expected**: Execution pauses mid-loop
5. Press **F10** to step
6. **Expected**: Advances one line
7. Press **F5** again
8. **Expected**: Resumes execution

#### Test 4.4: Speed Control
**Steps:**
1. Run code
2. Click "1x ▼" dropdown
3. Select "2.0x"
4. **Expected**: Speed button shows "2.0x ▼", execution runs faster

#### Test 4.5: Auto-Scroll
**Steps:**
1. Write 30+ lines of code
2. Scroll to top
3. Press F5
4. **Expected**: Editor auto-scrolls to keep executing line visible

**Pass Criteria:** All execution states work, highlighting accurate, controls responsive

---

### Feature 5: Performance Metrics

#### Test 5.1: Metrics Panel Display
**Steps:**
1. Click "📊 Metrics" button
2. **Expected**: Metrics panel appears showing all fields:
   - Steps
   - Time
   - Lines of Code
   - Distance
   - Turns
   - Commands breakdown

#### Test 5.2: Real-Time Updates
**Steps:**
1. Open metrics panel
2. Run code:
   ```python
   for i in range(5):
       car.go()
   ```
3. **Expected**:
   - Steps counter increments (0→1→2→3→4→5)
   - Time counter increases
   - Commands list updates showing `go() - 5x`

#### Test 5.3: Star Rating
**Steps:**
1. Complete a level with optimal code
2. **Expected**: 3 gold stars appear with animation
3. Complete a level with sub-optimal code
4. **Expected**: 1-2 stars appear

#### Test 5.4: Optimization Tips
**Steps:**
1. Write inefficient code (many repetitive lines)
2. Complete level
3. **Expected**: Tips section shows:
   - "Try using loops to reduce repetitive commands"
   - "Consider combining commands or using functions"

#### Test 5.5: Level Completion Summary
**Steps:**
1. Complete any level
2. **Expected**: Completion summary appears showing:
   - Level name
   - Score (0-100)
   - Star rating (animated)
   - Feedback message
   - Optimization tips
   - [Retry] and [Next Level] buttons

**Pass Criteria:** All metrics accurate, star rating correct, tips relevant

---

## Integration Tests

### Integration Test 1: Error Highlighting + Snippets
**Steps:**
1. Type `fori` and press Tab
2. Type invalid syntax inside loop: `pritn("test")`
3. **Expected**:
   - Snippet expands correctly
   - Error highlights typo and suggests "print"

### Integration Test 2: Folding + Execution
**Steps:**
1. Write function with multiple lines
2. Fold the function
3. Run code that calls the function
4. **Expected**:
   - Execution highlights work even in folded code
   - Unfolds automatically when executing folded line

### Integration Test 3: Breakpoints + Metrics
**Steps:**
1. Set breakpoint inside loop
2. Run code
3. **Expected**:
   - Execution pauses at breakpoint
   - Metrics update up to pause point
   - Metrics resume updating when continued

### Integration Test 4: All Features Together
**Steps:**
1. Use snippet to create loop (`fori` + Tab)
2. Add intentional error inside loop
3. View error in panel
4. Fix error
5. Fold the loop
6. Set breakpoint
7. Run code
8. View metrics while stepping through
9. **Expected**: All features work harmoniously without conflicts

**Pass Criteria:** No feature interferes with another, all work simultaneously

---

## Regression Tests

### Regression Test 1: Original Features Still Work
**Steps:**
1. Test Python syntax highlighting
2. Test file explorer operations
3. Test IntelliSense (if present)
4. Test run/pause/reset buttons
5. **Expected**: All original features unaffected by new additions

### Regression Test 2: Performance
**Steps:**
1. Type 100+ lines of code
2. **Expected**:
   - No lag when typing
   - Linting debounce prevents stuttering
   - Editor remains responsive

### Regression Test 3: Save/Load
**Steps:**
1. Write code with errors highlighted
2. Save file
3. Close editor
4. Reopen file
5. **Expected**:
   - Code loads correctly
   - Errors re-highlight after load
   - Fold state resets (normal behavior)

---

## Automated Test Script

Create `tests/test_advanced_features.gd`:

```gdscript
extends SceneTree

func _init():
    print("=== Advanced Features Test Suite ===\n")

    test_linter()
    test_snippets()
    test_folding()
    test_icons()

    print("\n=== All Tests Passed! ===")
    quit()

func test_linter():
    print("Testing Linter...")
    var linter = load("res://scripts/core/linter.gd").new()

    var code = """if True
car.go()"""
    var diagnostics = linter.lint(code)
    assert(diagnostics.size() > 0, "Should detect missing colon")
    print("  ✓ Linter detects syntax errors")

    code = "pritn('hello')"
    diagnostics = linter.lint(code)
    assert(diagnostics.size() > 0, "Should detect typo")
    assert(diagnostics[0].suggestions.size() > 0, "Should suggest 'print'")
    print("  ✓ Linter suggests corrections")

func test_snippets():
    print("Testing Snippets...")
    var library = load("res://scripts/core/snippet_library.gd")

    assert(library.snippets.size() >= 15, "Should have 15+ snippets")
    print("  ✓ Snippet library loaded (%d snippets)" % library.snippets.size())

    var fori_snippet = library.get_snippet("fori")
    assert(fori_snippet != null, "Should have 'fori' snippet")
    assert(fori_snippet.body.contains("range"), "fori should use range()")
    print("  ✓ Snippets contain expected code")

func test_folding():
    print("Testing Fold Manager...")
    var fold_mgr = load("res://scripts/core/fold_manager.gd").new(null)

    var code = """def move():
    car.go()
    car.stop()"""
    fold_mgr.analyze_folds(code)

    var regions = fold_mgr.get_all_folds()
    assert(regions.size() > 0, "Should detect foldable region")
    assert(regions[0].start_line == 0, "Function starts at line 0")
    print("  ✓ Fold manager detects regions")

func test_icons():
    print("Testing Icon Generator...")
    var icon_gen = load("res://scripts/ui/icon_generator.gd")

    var error_icon = icon_gen.create_error_icon()
    assert(error_icon != null, "Should create error icon")
    print("  ✓ Error icon generated")

    var fold_icon = icon_gen.create_fold_icon()
    assert(fold_icon != null, "Should create fold icon")
    print("  ✓ Fold icon generated")

    var star_icon = icon_gen.create_star_filled_icon()
    assert(star_icon != null, "Should create star icon")
    print("  ✓ Star icon generated")
```

**Run with:**
```bash
godot --path . --headless --script tests/test_advanced_features.gd
```

---

## Visual Inspection Checklist

- [ ] Error icons appear in correct gutter column
- [ ] Fold icons toggle between ▼ and ▶
- [ ] Execution arrow is yellow and clearly visible
- [ ] Breakpoint dots are red and centered
- [ ] Star icons animate smoothly
- [ ] Error underlines are red and wavy
- [ ] Current line highlight is subtle yellow
- [ ] Panel layouts are clean and readable
- [ ] All buttons have tooltips
- [ ] Font sizes are appropriate

---

## Performance Benchmarks

| Test | Target | Acceptable |
|------|--------|------------|
| Linting 100 lines | < 50ms | < 100ms |
| Snippet expansion | < 10ms | < 20ms |
| Fold analysis 100 lines | < 30ms | < 60ms |
| Icon generation (all) | < 100ms | < 200ms |
| Metrics update | < 5ms | < 10ms |

**Measure with:**
```gdscript
var start_time = Time.get_ticks_msec()
# ... operation ...
var elapsed = Time.get_ticks_msec() - start_time
print("Elapsed: %d ms" % elapsed)
```

---

## Known Limitations

1. **Icon Resolution**: Procedural icons are 16x16 or 24x24, may appear pixelated on high-DPI displays
2. **Fold Preview**: Limited to first 50 characters of folded region
3. **Linter Scope**: Only detects syntax errors, not runtime errors
4. **Snippet Context**: Snippets don't consider surrounding code context
5. **Metrics Accuracy**: Step count may vary with code optimizations

---

## Bug Reporting Template

If you find a bug, report it with:

```
**Feature:** [Linting / Snippets / Folding / Execution / Metrics]
**Description:** Brief description of the issue
**Steps to Reproduce:**
1. ...
2. ...
3. ...
**Expected:** What should happen
**Actual:** What actually happens
**Console Output:** Any error messages
**Godot Version:** 4.5.1
**OS:** Windows / Linux / Mac
```

---

## Success Criteria

All features are considered **PASS** if:
- ✅ All manual tests pass
- ✅ All integration tests pass
- ✅ No regression in existing features
- ✅ Performance meets benchmarks
- ✅ No console errors during normal use
- ✅ Visual elements render correctly

---

**Happy Testing! 🧪**
