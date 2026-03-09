# Hangman Codex (Godot 4.6)

A web-focused Hangman game built with **GDScript** for **Godot Engine 4.6**.

## Features

- Random word selection from `data/words.txt`
- On-screen A–Z keyboard
- Drawn hangman graphic (no external image dependency)
- Win/lose states with restart button
- Placeholder asset files for music, SFX, and graphics

## Project Structure

- `project.godot` — Godot project config
- `scenes/Main.tscn` — Main game scene
- `scripts/Game.gd` — Core game logic
- `scripts/HangmanCanvas.gd` — Custom drawing logic for hangman visuals
- `data/words.txt` — Word list used by the game
- `assets/` — Placeholder media assets you can replace

## Run Locally

1. Open the project in Godot **4.6**.
2. Run the `Main` scene (or press play to run the project).

## Web Export (HTML5)

1. In Godot, open **Project > Export**.
2. Add the **Web** preset.
3. Choose output path (for example `build/web/index.html`).
4. Export and deploy with any static hosting provider.

## Customize Words

Edit `data/words.txt` and keep one word/phrase per line. The game picks one line at random each new round.

## Replace Placeholder Assets

These files are intentionally empty placeholders:

- `assets/audio/music/placeholder_music.ogg`
- `assets/audio/sfx/placeholder_correct.wav`
- `assets/audio/sfx/placeholder_wrong.wav`
- `assets/graphics/placeholder_background.png`
- `assets/graphics/placeholder_hangman_parts.png`

Replace them with your own production assets as needed.
