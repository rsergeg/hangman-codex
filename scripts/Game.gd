extends Control

const WORDS_PATH := "res://data/words.txt"
const MAX_MISSES := 6

@onready var hangman_canvas: HangmanCanvas = %HangmanCanvas
@onready var word_label: Label = %WordLabel
@onready var wrong_guesses_label: Label = %WrongGuessesLabel
@onready var status_label: Label = %StatusLabel
@onready var keyboard_container: HFlowContainer = %KeyboardContainer
@onready var new_game_button: Button = %NewGameButton

var words: PackedStringArray = []
var selected_word := ""
var guessed_letters: Dictionary = {}
var misses := 0

func _ready() -> void:
	load_words()
	build_keyboard()
	new_game_button.pressed.connect(start_new_game)
	start_new_game()

func load_words() -> void:
	words.clear()
	var file := FileAccess.open(WORDS_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open words file: %s" % WORDS_PATH)
		return

	while not file.eof_reached():
		var line := file.get_line().strip_edges().to_upper()
		if line.length() > 0:
			words.append(line)

func build_keyboard() -> void:
	for child in keyboard_container.get_children():
		child.queue_free()

	for code in range(65, 91):
		var letter := char(code)
		var button := Button.new()
		button.text = letter
		button.custom_minimum_size = Vector2(44, 44)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(on_letter_pressed.bind(letter, button))
		keyboard_container.add_child(button)

func start_new_game() -> void:
	if words.is_empty():
		status_label.text = "No words loaded. Add words to data/words.txt"
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	selected_word = words[rng.randi_range(0, words.size() - 1)]
	guessed_letters.clear()
	misses = 0

	for button: Button in keyboard_container.get_children():
		button.disabled = false

	status_label.text = "Pick a letter"
	update_ui()

func on_letter_pressed(letter: String, button: Button) -> void:
	if guessed_letters.has(letter):
		return

	guessed_letters[letter] = true
	button.disabled = true

	if selected_word.find(letter) == -1:
		misses += 1

	update_ui()
	check_game_state()

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
	for button: Button in keyboard_container.get_children():
		if not guessed_letters.has(button.text):
			button.disabled = not enabled
