extends Control
class_name HangmanCanvas

const MAX_STAGES := 6
var wrong_guesses: int = 0

func set_wrong_guesses(value: int) -> void:
	wrong_guesses = int(clamp(value, 0, MAX_STAGES))
	queue_redraw()

func _draw() -> void:
	var width: float = size.x
	var height: float = size.y
	var panel: Rect2 = Rect2(width * 0.15, height * 0.06, width * 0.7, height * 0.88)
	var line_color: Color = Color("#d6c7a0")
	var frame_color: Color = Color("#3a2f1f")
	var door_color: Color = Color("#6f4e37")
	var lock_color: Color = Color("#c9a227")
	var shadow_color: Color = Color("#1e293b")

	# Vault frame and door
	draw_rect(panel.grow(10), frame_color, true)
	draw_rect(panel, door_color, true)
	draw_rect(panel, line_color, false, 4.0)

	# Door crossbars
	var h_center: float = panel.position.y + panel.size.y * 0.5
	var v_center: float = panel.position.x + panel.size.x * 0.5
	draw_line(Vector2(panel.position.x + 20, h_center), Vector2(panel.end.x - 20, h_center), line_color, 6.0)
	draw_line(Vector2(v_center, panel.position.y + 20), Vector2(v_center, panel.end.y - 20), line_color, 6.0)

	# Lock dial in the center
	var dial_center: Vector2 = panel.get_center()
	var dial_radius: float = float(min(panel.size.x, panel.size.y)) * 0.12
	draw_circle(dial_center, dial_radius * 1.2, shadow_color)
	draw_circle(dial_center, dial_radius, lock_color)
	draw_circle(dial_center, dial_radius * 0.35, frame_color)

	# Staged runes / lock failures (6 parts)
	var rune_color: Color = Color("#fca5a5")
	var runes: Array[Vector2] = [
		Vector2(panel.position.x + panel.size.x * 0.2, panel.position.y + panel.size.y * 0.22),
		Vector2(panel.position.x + panel.size.x * 0.8, panel.position.y + panel.size.y * 0.22),
		Vector2(panel.position.x + panel.size.x * 0.2, panel.position.y + panel.size.y * 0.78),
		Vector2(panel.position.x + panel.size.x * 0.8, panel.position.y + panel.size.y * 0.78),
		Vector2(panel.position.x + panel.size.x * 0.5, panel.position.y + panel.size.y * 0.14),
		Vector2(panel.position.x + panel.size.x * 0.5, panel.position.y + panel.size.y * 0.86),
	]

	for i in range(wrong_guesses):
		var pos: Vector2 = runes[i]
		draw_circle(pos, 14.0, rune_color)
		draw_line(pos + Vector2(-10, 0), pos + Vector2(10, 0), frame_color, 3.0)
		draw_line(pos + Vector2(0, -10), pos + Vector2(0, 10), frame_color, 3.0)
