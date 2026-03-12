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
	var base_scale : float = min(width, height)
	var line_color := Color("#dbeafe")
	var body_color := Color("#fca5a5")
	var thickness := 6.0

	# Gallows
	draw_line(Vector2(width * 0.1, height * 0.9), Vector2(width * 0.8, height * 0.9), line_color, thickness)
	draw_line(Vector2(width * 0.22, height * 0.9), Vector2(width * 0.22, height * 0.1), line_color, thickness)
	draw_line(Vector2(width * 0.22, height * 0.1), Vector2(width * 0.62, height * 0.1), line_color, thickness)
	draw_line(Vector2(width * 0.62, height * 0.1), Vector2(width * 0.62, height * 0.2), line_color, thickness)

	var rope_end := Vector2(width * 0.62, height * 0.2)
	var head_radius := base_scale * 0.08
	var torso_length := base_scale * 0.24
	var arm_length := base_scale * 0.14
	var leg_length := base_scale * 0.18
	var leg_spread := base_scale * 0.10

	# Keep all body parts centered and connected under the rope end.
	var head_center := rope_end + Vector2(0.0, head_radius)
	var neck := head_center + Vector2(0.0, head_radius)
	var hip := neck + Vector2(0.0, torso_length)
	var left_hand := neck + Vector2(-arm_length, arm_length)
	var right_hand := neck + Vector2(arm_length, arm_length)
	var left_foot := hip + Vector2(-leg_spread, leg_length)
	var right_foot := hip + Vector2(leg_spread, leg_length)

	if wrong_guesses >= 1:
		draw_circle(head_center, head_radius, body_color)
		draw_circle(head_center, head_radius * 0.75, Color("#0f172a"))
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
