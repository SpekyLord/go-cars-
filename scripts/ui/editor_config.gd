## Editor Configuration for GoCars Code Editor
## Manages editor settings like indentation, spaces/tabs, etc.
## Author: Claude Code
## Date: January 2026

class_name EditorConfig

## Indentation settings
static var indent_size: int = 4
static var use_spaces: bool = true
static var auto_indent: bool = true

## Autocomplete settings
static var autocomplete_trigger_length: int = 2
static var show_signature_help: bool = true

## Auto-pairing settings
static var enable_auto_pairing: bool = true
static var auto_pair_brackets: bool = true
static var auto_pair_quotes: bool = true
