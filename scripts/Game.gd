extends Control

const EASY_WORDS_PATH := "res://data/words_easy.json"
const MEDIUM_WORDS_PATH := "res://data/words_medium.json"
const MAX_MISSES := 6

@onready var hangman_canvas: HangmanCanvas = %HangmanCanvas
@onready var word_label: Label = %WordLabel
@onready var wrong_guesses_label: Label = %WrongGuessesLabel
@onready var status_label: Label = %StatusLabel
@onready var keyboard_row_1: HBoxContainer = %KeyboardRow1
@onready var keyboard_row_2: HBoxContainer = %KeyboardRow2
@onready var new_game_button: Button = %NewGameButton
@onready var hint_button: Button = %HintButton
@onready var hint_label: Label = %HintLabel
@onready var level_button: Button = %LevelButton

var easy_words: Array[Dictionary] = []
var medium_words: Array[Dictionary] = []
var current_level := "easy"
var selected_word := ""
var selected_hint := ""
var hint_visible := false
var guessed_letters: Dictionary = {}
var letter_buttons: Dictionary = {}
var misses := 0

func _ready() -> void:
	print("Game.gd _ready(), owner:", get_owner(), " name:", name)
	load_words()
	build_keyboard()
	new_game_button.pressed.connect(start_new_game)
	hint_button.pressed.connect(_on_hint_button_pressed)
	level_button.pressed.connect(_on_level_button_pressed)
	level_button.text = "Easy"
	start_new_game()

func load_words() -> void:
	easy_words = _load_words_from_json(EASY_WORDS_PATH)
	medium_words = _load_words_from_json(MEDIUM_WORDS_PATH)

func _load_words_from_json(path: String) -> Array[Dictionary]:
	print("Attempting to load scroll from: " + path)
	var loaded_words: Array[Dictionary] = []
	if not FileAccess.file_exists(path):
		var runtime := "Web" if OS.has_feature("web") else OS.get_name()
		push_error("Words file is not accessible at path '%s' (runtime: %s). Verify the filename and res:// path in the export." % [path, runtime])
		return loaded_words

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		var runtime := "Web" if OS.has_feature("web") else OS.get_name()
		push_error("Could not open words file at path '%s' (runtime: %s)." % [path, runtime])
		return loaded_words

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Array):
		push_error("Words JSON at path '%s' is not an array." % path)
		return loaded_words

	for entry in parsed:
		if not (entry is Dictionary):
			continue
		if not (entry.has("word") and entry.has("hint")):
			continue

		loaded_words.append({
			"word": String(entry["word"]),
			"hint": String(entry["hint"]),
		})

	return loaded_words

func build_keyboard() -> void:
	for child in keyboard_row_1.get_children():
		child.queue_free()
	for child in keyboard_row_2.get_children():
		child.queue_free()
	letter_buttons.clear()

	for code in range(65, 91):
		var letter := char(code)
		var button := Button.new()
		button.text = letter
		button.custom_minimum_size = Vector2(44, 44)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_letter_button_pressed.bind(letter))
		if code <= 77:
			keyboard_row_1.add_child(button)
		else:
			keyboard_row_2.add_child(button)
		letter_buttons[letter] = button

func start_new_game() -> void:
	var active_words := easy_words if current_level == "easy" else medium_words
	if active_words.is_empty():
		status_label.text = "No words loaded for %s level." % current_level.capitalize()
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var entry := active_words[rng.randi_range(0, active_words.size() - 1)]
	selected_word = String(entry.get("word", ""))
	selected_hint = String(entry.get("hint", ""))
	hint_visible = false
	hint_label.text = ""
	hint_button.button_pressed = false
	hint_button.text = "Show Hint"
	guessed_letters.clear()
	misses = 0

	for button: Button in _all_keyboard_buttons():
		button.disabled = false

	status_label.text = "Pick a letter"
	update_ui()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey):
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode < KEY_A or key_event.keycode > KEY_Z:
		return

	var letter := char(key_event.keycode).to_upper()
	process_guess(letter)

func _on_letter_button_pressed(letter: String) -> void:
	get_viewport().gui_release_focus()
	process_guess(letter)

func _on_hint_button_pressed() -> void:
	hint_visible = hint_button.button_pressed
	hint_button.text = "Hide Hint" if hint_visible else "Show Hint"
	hint_label.text = selected_hint if hint_visible else ""

func _on_level_button_pressed() -> void:
	current_level = "medium" if current_level == "easy" else "easy"
	level_button.text = current_level.capitalize()
	start_new_game()

func process_guess(letter: String) -> void:
	if guessed_letters.has(letter):
		return

	guessed_letters[letter] = true
	disable_letter_button(letter)

	if selected_word.find(letter) == -1:
		misses += 1

	update_ui()
	check_game_state()

func disable_letter_button(letter: String) -> void:
	if not letter_buttons.has(letter):
		return

	var button := letter_buttons[letter] as Button
	if button:
		button.disabled = true

func update_ui() -> void:
	var masked_letters: PackedStringArray = []
	for i in selected_word.length():
		var current := selected_word[i]
		if current == " ":
			masked_letters.append("  ")
		elif guessed_letters.has(current):
			masked_letters.append(current)
		else:
			masked_letters.append("_")

	word_label.text = " ".join(masked_letters)
	wrong_guesses_label.text = "Wrong guesses: %d/%d" % [misses, MAX_MISSES]
	hangman_canvas.set_wrong_guesses(misses)

func check_game_state() -> void:
	if is_word_complete():
		status_label.text = "You win!"
		set_keyboard_enabled(false)
		return

	if misses >= MAX_MISSES:
		status_label.text = "You lost! Word: %s" % selected_word
		set_keyboard_enabled(false)
		return

	status_label.text = "Keep guessing"

func is_word_complete() -> bool:
	for i in selected_word.length():
		var current := selected_word[i]
		if current != " " and not guessed_letters.has(current):
			return false
	return true

func set_keyboard_enabled(enabled: bool) -> void:
	for button: Button in _all_keyboard_buttons():
		if not guessed_letters.has(button.text):
			button.disabled = not enabled

func _all_keyboard_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	for child in keyboard_row_1.get_children():
		if child is Button:
			buttons.append(child)
	for child in keyboard_row_2.get_children():
		if child is Button:
			buttons.append(child)
	return buttons
