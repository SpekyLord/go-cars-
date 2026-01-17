# icon_generator.gd
# Generates simple procedural icons for the editor
class_name IconGenerator
extends RefCounted

static func create_error_icon(size: int = 16) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Draw red circle with X
	var center = size / 2.0
	var radius = size / 2.0 - 2

	for x in range(size):
		for y in range(size):
			var dx = x - center
			var dy = y - center
			var dist = sqrt(dx * dx + dy * dy)

			# Red circle
			if dist < radius and dist > radius - 2:
				image.set_pixel(x, y, Color.RED)
			# X mark
			elif abs(dx - dy) < 2 or abs(dx + dy - size + 1) < 2:
				if dist < radius - 2:
					image.set_pixel(x, y, Color.RED)

	return ImageTexture.create_from_image(image)

static func create_warning_icon(size: int = 16) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Draw yellow triangle with !
	var center_x = size / 2.0
	var height = size - 2

	for x in range(size):
		for y in range(size):
			# Triangle outline
			var left_edge = center_x - (height - y) / 2.0
			var right_edge = center_x + (height - y) / 2.0

			if y > 1 and x >= left_edge and x <= right_edge:
				if x <= left_edge + 1 or x >= right_edge - 1 or y <= 3:
					image.set_pixel(x, y, Color.YELLOW)

			# Exclamation mark
			if x >= center_x - 1 and x <= center_x + 1:
				if y > 4 and y < height - 4:
					image.set_pixel(x, y, Color(0, 0, 0))
				elif y >= height - 3 and y < height - 1:
					image.set_pixel(x, y, Color(0, 0, 0))

	return ImageTexture.create_from_image(image)

static func create_info_icon(size: int = 16) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Draw blue circle with i
	var center = size / 2.0
	var radius = size / 2.0 - 2

	for x in range(size):
		for y in range(size):
			var dx = x - center
			var dy = y - center
			var dist = sqrt(dx * dx + dy * dy)

			# Blue circle
			if dist < radius and dist > radius - 2:
				image.set_pixel(x, y, Color.DODGER_BLUE)

			# i mark
			if x >= center - 1 and x <= center + 1:
				# Dot
				if y >= 4 and y <= 6:
					image.set_pixel(x, y, Color.DODGER_BLUE)
				# Line
				elif y >= 8 and y < size - 3:
					image.set_pixel(x, y, Color.DODGER_BLUE)

	return ImageTexture.create_from_image(image)

static func create_breakpoint_icon(size: int = 16) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Red filled circle
	var center = size / 2.0
	var radius = size / 2.0 - 2

	for x in range(size):
		for y in range(size):
			var dx = x - center
			var dy = y - center
			var dist = sqrt(dx * dx + dy * dy)

			if dist < radius:
				image.set_pixel(x, y, Color.RED)

	return ImageTexture.create_from_image(image)

static func create_fold_icon(size: int = 16) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Draw right-pointing triangle (folded)
	var center_y = size / 2.0

	for x in range(4, size - 4):
		for y in range(size):
			var dy = abs(y - center_y)
			var max_dy = (x - 4) * 0.5

			if dy <= max_dy:
				image.set_pixel(x, y, Color.GRAY)

	return ImageTexture.create_from_image(image)

static func create_unfold_icon(size: int = 16) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Draw down-pointing triangle (unfolded)
	var center_x = size / 2.0

	for x in range(size):
		for y in range(4, size - 4):
			var dx = abs(x - center_x)
			var max_dx = (y - 4) * 0.5

			if dx <= max_dx:
				image.set_pixel(x, y, Color.GRAY)

	return ImageTexture.create_from_image(image)

static func create_exec_arrow_icon(size: int = 16) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Draw yellow right-pointing arrow
	var center_y = size / 2.0

	# Arrow shaft
	for x in range(2, size - 6):
		for y in range(int(center_y - 1), int(center_y + 2)):
			image.set_pixel(x, y, Color.YELLOW)

	# Arrow head
	for i in range(6):
		var y_start = int(center_y - 3 + i * 0.5)
		var y_end = int(center_y + 3 - i * 0.5)
		for y in range(y_start, y_end + 1):
			image.set_pixel(size - 6 + i, y, Color.YELLOW)

	return ImageTexture.create_from_image(image)

static func create_star_filled_icon(size: int = 24) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Draw filled star
	var center = size / 2.0
	var points = 5
	var outer_radius = size / 2.0 - 2
	var inner_radius = outer_radius * 0.4

	var star_points: Array[Vector2] = []
	for i in range(points * 2):
		var angle = PI / 2 + i * PI / points
		var radius = outer_radius if i % 2 == 0 else inner_radius
		star_points.append(Vector2(
			center + cos(angle) * radius,
			center + sin(angle) * radius
		))

	# Fill star (simple flood fill approximation)
	for x in range(size):
		for y in range(size):
			if _point_in_polygon(Vector2(x, y), star_points):
				image.set_pixel(x, y, Color.GOLD)

	return ImageTexture.create_from_image(image)

static func create_star_empty_icon(size: int = 24) -> ImageTexture:
	var image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)

	# Draw star outline
	var center = size / 2.0
	var points = 5
	var outer_radius = size / 2.0 - 2
	var inner_radius = outer_radius * 0.4

	var star_points: Array[Vector2] = []
	for i in range(points * 2):
		var angle = PI / 2 + i * PI / points
		var radius = outer_radius if i % 2 == 0 else inner_radius
		star_points.append(Vector2(
			center + cos(angle) * radius,
			center + sin(angle) * radius
		))

	# Draw outline
	for i in range(star_points.size()):
		var p1 = star_points[i]
		var p2 = star_points[(i + 1) % star_points.size()]
		_draw_line_on_image(image, p1, p2, Color.GRAY)

	return ImageTexture.create_from_image(image)

# Helper function to check if point is in polygon
static func _point_in_polygon(point: Vector2, polygon: Array[Vector2]) -> bool:
	var inside = false
	var j = polygon.size() - 1

	for i in range(polygon.size()):
		if ((polygon[i].y > point.y) != (polygon[j].y > point.y)) and \
		   (point.x < (polygon[j].x - polygon[i].x) * (point.y - polygon[i].y) / (polygon[j].y - polygon[i].y) + polygon[i].x):
			inside = !inside
		j = i

	return inside

# Helper function to draw line on image
static func _draw_line_on_image(image: Image, from: Vector2, to: Vector2, color: Color) -> void:
	var dx = abs(to.x - from.x)
	var dy = abs(to.y - from.y)
	var steps = max(dx, dy)

	for i in range(int(steps) + 1):
		var t = i / steps if steps > 0 else 0
		var x = int(lerp(from.x, to.x, t))
		var y = int(lerp(from.y, to.y, t))
		if x >= 0 and x < image.get_width() and y >= 0 and y < image.get_height():
			image.set_pixel(x, y, color)
