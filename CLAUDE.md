# CLAUDE.md - GoCars Development Guide

## Project Overview

GoCars is an educational coding-puzzle game built with Godot 4.5.1 for the TrackTech: CSS Hackathon 2026. Players write simplified Python-like code to control vehicles and traffic elements to solve puzzles.

**Theme:** Cars, Transportation, Motorsports, or Racing Systems  
**Focus:** Educational project with real-world relevance  
**Engine:** Godot 4.5.1  
**Language:** GDScript  

Read the full PRD at `docs/PRD.md` before implementing any features.

---

## How to Run the Game

### Run in Editor (with visible window)
```bash
godot --path . --editor
```

### Run Game Directly
```bash
godot --path . --run
```

### Run Headless (for testing/CI - no window)
```bash
godot --path . --headless --quit-after 10
```

### Run and Capture Errors
```bash
godot --path . 2>&1 | tee godot_output.log
```

---

## How to Run Tests

Run all tests:
```bash
./run_tests.sh
```

Run a specific test:
```bash
godot --path . --headless --script tests/test_code_parser.gd
```

Tests are located in `tests/` directory with `.test.gd` extension. Co-located tests can also be placed next to their source files.

---

## Project Structure

```
GoCars/
├── CLAUDE.md              # You are here
├── project.godot          # Godot project file
├── run_tests.sh           # Test runner script
├── docs/
│   └── PRD.md             # Full Product Requirements Document
├── assets/
│   ├── sprites/
│   ├── audio/
│   └── fonts/
├── scenes/
│   ├── main_menu.tscn
│   ├── gameplay.tscn
│   └── levels/
├── scripts/
│   ├── core/              # Code parser, simulation engine
│   ├── entities/          # Vehicle, stoplight, boat
│   ├── ui/                # Code editor, file explorer, HUD
│   └── systems/           # Save manager, score manager
├── tests/                 # Test files (.test.gd)
└── data/
	└── levels/            # Level configuration files
```

---

## GDScript Important Rules

### CRITICAL - Common Mistakes to Avoid

**1. String multiplication syntax:**
```gdscript
# ❌ WRONG - This is Python, not GDScript
var line = "=" * 50

# ✅ CORRECT - Use repeat() method
var line = "=".repeat(50)
```

**2. Print formatting:**
```gdscript
# ❌ WRONG - f-strings don't exist in GDScript
print(f"Value: {value}")

# ✅ CORRECT - Use % operator or str()
print("Value: %s" % value)
print("Value: " + str(value))
```

**3. Dictionary/Array initialization:**
```gdscript
# ❌ WRONG - dict() doesn't exist
var my_dict = dict()

# ✅ CORRECT
var my_dict = {}
var my_array = []
```

**4. Type hints:**
```gdscript
# ❌ WRONG - Python-style hints
def my_func(value: int) -> str:

# ✅ CORRECT - GDScript style
func my_func(value: int) -> String:
```

**5. Null checking:**
```gdscript
# ❌ WRONG
if my_var == None:

# ✅ CORRECT
if my_var == null:
```

**6. Boolean values:**
```gdscript
# ❌ WRONG - Python capitalization
True, False

# ✅ CORRECT - GDScript lowercase
true, false
```

**7. Self reference:**
```gdscript
# ❌ WRONG in most cases
self.my_method()

# ✅ CORRECT - self is often optional
my_method()
```

**8. For loops:**
```gdscript
# ❌ WRONG
for i in range(len(array)):

# ✅ CORRECT - Use size()
for i in range(array.size()):
# Or iterate directly
for item in array:
```

**9. Class inheritance:**
```gdscript
# ❌ WRONG
class MyClass(Node):

# ✅ CORRECT
extends Node
class_name MyClass
```

**10. Lambda/Anonymous functions:**
```gdscript
# ❌ WRONG - Python lambda
var fn = lambda x: x * 2

# ✅ CORRECT - GDScript callable
var fn = func(x): return x * 2
```

---

## Core Systems Overview

### 1. Code Parser (`scripts/core/code_parser.gd`)
- Parses simplified Python-like syntax
- Validates against available functions
- Returns structured commands or errors
- See PRD section TECH-003 for specifications

### 2. Simulation Engine (`scripts/core/simulation_engine.gd`)
- Executes queued commands
- Handles vehicle movement and physics
- Manages collision detection
- Controls playback speed

### 3. Level Manager (`scripts/core/level_manager.gd`)
- Loads level configurations
- Tracks win/lose conditions
- Manages progression and scoring

### 4. Available Player Functions
```gdscript
# Basic Movement
car.go()           # Move forward continuously
car.stop()         # Stop immediately
car.turn_left()    # Turn 90° left at intersection
car.turn_right()   # Turn 90° right at intersection
car.wait(seconds)  # Pause for N seconds

# Traffic Lights
stoplight.set_red()
stoplight.set_green()
stoplight.set_yellow()
stoplight.get_state()

# Advanced (later levels)
car.speed(value)   # 0.5 to 2.0 multiplier
boat.depart()
boat.get_capacity()
```

---

## Development Workflow

### Before Implementing a Feature:
1. Read the relevant section in `docs/PRD.md`
2. Plan the implementation - create a plan in a markdown file if complex
3. Identify which files need to be created/modified
4. Write tests first if applicable

### After Implementing:
1. Run `./run_tests.sh` to verify nothing broke
2. Run the game and test manually
3. Check for GDScript errors in output
4. Update documentation if needed

### When Creating New Files:
- Use snake_case for file names: `code_parser.gd`
- Use PascalCase for class names: `CodeParser`
- Place files in appropriate directories per project structure
- Add corresponding test file if it's a core system

---

## Testing Guidelines

### Test File Naming
- Test files end with `.test.gd`
- Name matches source: `code_parser.gd` → `code_parser.test.gd`

### Test Structure
```gdscript
extends SceneTree

func _init():
    print("Running CodeParser tests...")
    test_parse_go_command()
    test_parse_invalid_command()
    print("All tests passed!")
    quit()

func test_parse_go_command():
    var parser = CodeParser.new()
    var result = parser.parse("car.go()")
    assert(result.valid == true, "car.go() should be valid")
    print("  ✓ test_parse_go_command")

func test_parse_invalid_command():
    var parser = CodeParser.new()
    var result = parser.parse("car.fly()")
    assert(result.valid == false, "car.fly() should be invalid")
    print("  ✓ test_parse_invalid_command")
```

---

## Level Data Format

Levels are stored as JSON in `data/levels/`:

```json
{
    "id": "T1",
    "name": "First Drive",
    "description": "Learn to make your car go!",
    "available_functions": ["car.go"],
    "entities": {
        "cars": [
            {"id": "car1", "position": [2, 5], "destination": [8, 5]}
        ],
        "stoplights": []
    },
    "win_condition": "all_cars_at_destination",
    "star_criteria": {
        "one_star": "complete",
        "two_stars": "no_crashes",
        "three_stars": "lines_of_code <= 1"
    }
}
```

---

## Signals to Use

```gdscript
# Game events
signal code_executed(commands: Array)
signal simulation_started()
signal simulation_paused()
signal simulation_ended(success: bool)
signal car_reached_destination(car_id: String)
signal car_crashed(car_id: String)
signal level_completed(stars: int)
signal level_failed(reason: String)
```

---

## Priority Order for Implementation

Based on PRD priorities:

### P0 - Critical (Must Have)
1. Code Parser System (CORE-001, TECH-003)
2. Vehicle Control Functions (CORE-002)
3. Simulation Controls (CORE-003)
4. Campaign Mode (MODE-001)
5. Tutorial Levels T1-T5 (LVL-001)
6. Main Menu (UI-001)
7. Gameplay Interface (UI-002)

### P1 - High (Should Have)
1. Iloilo City Levels C1-C5 (LVL-002)
2. Water/Port Levels W1-W5 (LVL-003)
3. Infinite Mode (MODE-002)
4. Vehicle Collection System (VEH-001)

### P2 - Medium (Nice to Have)
1. Vehicle Info Display (VEH-002)
2. Advanced functions (speed, follow)
3. Sound effects and music
4. Polish and animations

---

## Asking Claude Code for Help

### Good Prompts:
- "Read docs/PRD.md section 4.1 and implement CORE-001 Code Editor System"
- "Create the code parser based on TECH-003 specifications"
- "Write tests for the code parser before implementing"
- "Run the game and fix any errors you see"
- "Review scripts/core/ for logical inconsistencies"

### When Stuck:
- "Let's plan this feature before implementing. Create a plan in docs/plans/"
- "What's the simplest way to implement [feature]?"
- "Run ./run_tests.sh and fix failing tests"

---

## Hackathon Timeline Reminder

- **Dec 15-22:** Foundation (car moves based on code)
- **Dec 23-31:** Core Mechanics (full gameplay loop)
- **Jan 1-10:** Content (all 15 levels)
- **Jan 11-18:** Polish & UI
- **Jan 19-23:** Testing & Submission
- **Jan 24:** Demo Day

---

## Notes

- Keep code clean and delete unused files regularly
- Commit frequently with descriptive messages
- Test on target hardware (standard school computer specs)
- The game should run at stable 60 FPS
- Executable size target: < 200MB
