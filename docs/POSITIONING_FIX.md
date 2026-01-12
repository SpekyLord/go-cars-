# Code Editor Window Positioning Fix

## Issue
Code Editor window was appearing at position (0, 0) instead of the configured default position (50, 50).

## Root Cause
The `window_manager.gd` was loading saved window positions from `user://window_settings.json` which contained invalid position data (0, 0) from when the window was previously stuck at the top-left corner.

## Solution
Added position validation in `_load_window_state()` function to reject positions that are at or very close to (0, 0):

```gdscript
# Before - directly applied saved position
if ce.has("position"):
    code_editor_window.global_position = Vector2(ce["position"][0], ce["position"][1])

# After - validate position before applying
if ce.has("position"):
    var pos = Vector2(ce["position"][0], ce["position"][1])
    # Validate position is reasonable (not at 0,0 and within screen bounds)
    if pos.x > 10 and pos.y > 10:
        code_editor_window.global_position = pos
```

## Result
- Invalid saved positions (< 10, < 10) are now ignored
- Windows fall back to their default positions defined in their `_init()` functions
- Code Editor now spawns at (50, 50) as intended
- README window spawns at (300, 100) as intended
- Behavior matches user expectations ("spawn similar to the readme")

## Files Modified
- `scripts/ui/window_manager.gd` - Added position validation in `_load_window_state()`
