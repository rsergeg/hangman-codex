extends Control
class_name HangmanCanvas

const MAX_STAGES := 6
var wrong_guesses := 0

func set_wrong_guesses(value: int) -> void:
	wrong_guesses = clamp(value, 0, MAX_STAGES)
	queue_redraw()

func _draw() -> void:
	var width := size.x
	var height := size.y
	var line_color := Color("#dbeafe")
	var body_color := Color("#fca5a5")
	var thickness := 6.0

	# Gallows
	draw_line(Vector2(width * 0.1, height * 0.9), Vector2(width * 0.8, height * 0.9), line_color, thickness)
	draw_line(Vector2(width * 0.22, height * 0.9), Vector2(width * 0.22, height * 0.1), line_color, thickness)
	draw_line(Vector2(width * 0.22, height * 0.1), Vector2(width * 0.62, height * 0.1), line_color, thickness)
	draw_line(Vector2(width * 0.62, height * 0.1), Vector2(width * 0.62, height * 0.2), line_color, thickness)

	var head_center := Vector2(width * 0.62, height * 0.29)
	var neck := Vector2(width * 0.62, height * 0.38)
	var hip := Vector2(width * 0.62, height * 0.60)
	var left_hand := Vector2(width * 0.50, height * 0.48)
	var right_hand := Vector2(width * 0.74, height * 0.48)
	var left_foot := Vector2(width * 0.52, height * 0.78)
	var right_foot := Vector2(width * 0.72, height * 0.78)

	if wrong_guesses >= 1:
		draw_circle(head_center, width * 0.06, body_color)
		draw_circle(head_center, width * 0.045, Color("#0f172a"))
	if wrong_guesses >= 2:
		draw_line(neck, hip, body_color, thickness)
	if wrong_guesses >= 3:
		draw_line(neck, left_hand, body_color, thickness)
	if wrong_guesses >= 4:
		draw_line(neck, right_hand, body_color, thickness)
	if wrong_guesses >= 5:
		draw_line(hip, left_foot, body_color, thickness)
	if wrong_guesses >= 6:
		draw_line(hip, right_foot, body_color, thickness)
