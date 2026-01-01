extends CharacterBody2D
class_name Vehicle

## Vehicle entity that can be controlled via code commands.
## Supports: go(), stop(), turn_left(), turn_right(), wait(seconds)

signal reached_destination(vehicle_id: String)
signal crashed(vehicle_id: String)

# Vehicle properties
@export var vehicle_id: String = "car1"
@export var speed: float = 200.0  # Pixels per second
@export var destination: Vector2 = Vector2.ZERO

# Movement state
var is_moving: bool = false
var is_waiting: bool = false
var wait_timer: float = 0.0
var queued_turn: String = ""  # "left" or "right" or ""
var direction: Vector2 = Vector2.RIGHT  # Current facing direction

# Speed multiplier (for car.speed() function)
var speed_multiplier: float = 1.0

# Distance threshold for reaching destination
const DESTINATION_THRESHOLD: float = 10.0


func _ready() -> void:
	# Set up collision
	set_collision_layer_value(1, true)  # Layer 1 for vehicles
	set_collision_mask_value(1, true)   # Detect other vehicles


func _physics_process(delta: float) -> void:
	# Handle waiting
	if is_waiting:
		wait_timer -= delta
		if wait_timer <= 0:
			is_waiting = false
			wait_timer = 0.0
		return

	# Handle movement
	if is_moving:
		_move(delta)
		_check_destination()


func _move(delta: float) -> void:
	var actual_speed = speed * speed_multiplier
	velocity = direction * actual_speed
	move_and_slide()

	# Check for collisions
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() is Vehicle:
			_on_crash()
			return


func _check_destination() -> void:
	if destination != Vector2.ZERO:
		var distance = global_position.distance_to(destination)
		if distance < DESTINATION_THRESHOLD:
			stop()
			reached_destination.emit(vehicle_id)


func _on_crash() -> void:
	stop()
	crashed.emit(vehicle_id)


# ============================================
# Command Functions (called by SimulationEngine)
# ============================================

## Start moving forward continuously
func go() -> void:
	is_moving = true


## Stop immediately
func stop() -> void:
	is_moving = false
	velocity = Vector2.ZERO


## Queue a 90-degree left turn at next intersection
func turn_left() -> void:
	# Immediately rotate 90 degrees counter-clockwise
	direction = direction.rotated(-PI / 2)
	rotation -= PI / 2


## Queue a 90-degree right turn at next intersection
func turn_right() -> void:
	# Immediately rotate 90 degrees clockwise
	direction = direction.rotated(PI / 2)
	rotation += PI / 2


## Pause movement for specified seconds
func wait(seconds: int) -> void:
	is_waiting = true
	wait_timer = float(seconds)


## Set speed multiplier (0.5 to 2.0)
func set_speed(value: float) -> void:
	speed_multiplier = clamp(value, 0.5, 2.0)


# ============================================
# Utility Functions
# ============================================

## Set the destination for this vehicle
func set_destination(dest: Vector2) -> void:
	destination = dest


## Check if vehicle has reached its destination
func at_destination() -> bool:
	if destination == Vector2.ZERO:
		return false
	return global_position.distance_to(destination) < DESTINATION_THRESHOLD


## Get distance to destination
func distance_to_destination() -> float:
	if destination == Vector2.ZERO:
		return -1.0
	return global_position.distance_to(destination)


## Reset vehicle to initial state
func reset(start_pos: Vector2, start_dir: Vector2 = Vector2.RIGHT) -> void:
	global_position = start_pos
	direction = start_dir.normalized()
	rotation = direction.angle()
	is_moving = false
	is_waiting = false
	wait_timer = 0.0
	queued_turn = ""
	speed_multiplier = 1.0
	velocity = Vector2.ZERO
