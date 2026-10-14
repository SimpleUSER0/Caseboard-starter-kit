# Caseboard Starter Kit — Godot 4

A small evidence-board component for 2D detective and mystery games. Arrange clue cards, toggle connections, check author-defined deductions and save the current board.

## Quick start

1. Install Godot **4.5.1** standard edition (GDScript). The engine is not bundled.
2. Extract this ZIP to a writable folder.
3. In Godot's project manager, choose **Import**, select `project.godot`, and open it.
4. Press **F5**. The demo opens with six clue cards.
5. Drag cards to arrange them. Turn **Link mode** on, then click two cards to connect them. Repeat that pair to remove its link.
6. Select **Check deduction**. Each sample brief explains what relationships you are looking for.

There are two sample cases and three built-in palettes: Archive, Blueprint and Noir. Switching palettes preserves the current board; switching cases starts that case afresh. Saves are separate for each sample case.

## Keyboard controls

- Tab / Shift+Tab: focus toolbar controls and evidence cards.
- Arrow keys on a focused card: move 10 board units.
- Shift+Arrow: move 40 units.
- Enter or Space on a card in link mode: select that card.
- Select the same card twice to cancel selection.

The canvas is 1500×1000 board units and sits inside a scroll container in the demo. Arrow keys move cards instead of changing card focus. Keyboard events have automated coverage; physical human use has not been independently evaluated.

## Add it to your game

Copy `addons/caseboard/` into your project's `addons/` directory. Copy the sample `demo/cases/` and `art/` folders if you want to use the bundled examples; custom cases can reference your own project images. This is a scene component, **not an editor plugin**; there is nothing to enable in Project Settings.

Instance `addons/caseboard/board.tscn` inside a `ScrollContainer`. It uses a fixed-size canvas so cards remain readable. After the node enters the scene tree:

```gdscript
@onready var board = $ScrollContainer/EvidenceBoard

func _ready() -> void:
    board.case_solved.connect(_on_case_solved)
    board.message.connect(_on_board_message)
    board.load_case("res://cases/my_case.json")

func _on_case_solved(case_id: String) -> void:
    print("Unlock next chapter: ", case_id)

func _on_board_message(text: String) -> void:
    $StatusLabel.text = text
```

Public methods:

| Method | Result |
|---|---|
| `load_case(path)` | Load/validate JSON and create cards; returns bool. |
| `set_link_mode(enabled)` | Switch dragging / connection selection. |
| `set_palette("Archive")` | Rebuild card visuals without changing evidence state. |
| `save_board("user://my_case.json")` | Save positions and links; returns bool. |
| `load_board("user://my_case.json")` | Validate and restore the matching case; returns bool. |
| `reset_board()` | Restore original positions and remove current links; leave disk save alone. |
| `submit_solution()` | Check author-defined rules and emit `case_solved` if solved; returns bool. |

Signals: `board_changed`, `message(text)`, `case_solved(case_id)`. Calling `submit_solution()` on an already solved board emits `case_solved` again; guard progression in your own game if needed.

`board.model.snapshot()` exposes serializable board state for a larger game save. `board.model.restore()` only changes the model; use `load_board()` for normal UI restoration, or rebuild the board after restoring model state. The model is intentionally separate from the visuals.

## Write your own case

Duplicate `demo/cases/observatory.json`. Use a **new case ID** when you change clues or deduction rules, so old saves cannot silently apply to a different case.

```json
{
  "schema_version": 1,
  "id": "sample_case",
  "title": "A Simple Case",
  "brief": "Connect the person to the signed note.",
  "strict_solution": true,
  "success_text": "You found the connection.",
  "required_links": [["person", "note"]],
  "cards": [
    {"id":"person","kind":"Suspect","title":"Sam","body":"Sam was nearby.","position":[40,40]},
    {"id":"note","kind":"Evidence","title":"Signed note","body":"Sam signed this note.","position":[450,40]}
  ]
}
```

Rules:

- Case and card IDs: 1–64 ASCII letters, digits, underscore or hyphen. Card IDs must be unique within a case.
- 1–40 cards; each needs `id`, `kind`, `title`, `body` and a two-number `position`.
- Positions: x between 0 and 1200; y between 0 and 740.
- `required_links`: at least one pair of distinct existing card IDs. Links are **undirected**. Pair order does not affect the solution.
- `strict_solution: true`: all required connections and no extras. Set to false to allow extra connections.
- Optional `image`: a `res://` PNG, JPG, WEBP or SVG path. Supply the image in your own project. Missing images are omitted.
- The model accepts up to 2000 characters per card text field. Use short text in the UI: roughly 10–25 title characters and 50–160 body characters. Long text can grow a card beyond the sample layout. For novels or extensive evidence descriptions, add a separate inspector in your game.
- Demo feedback reveals counts of missing and extra links. Change `submit_solution()` if you prefer less helpful feedback.

The solution is present in source JSON. This is for single-player narrative games, not secure competitive scoring or anti-cheat.

## Change the look

Select `palette_name` in the board's Inspector or call `set_palette()`. Palette dictionaries in `board.gd` define canvas, dots, paper, text, accent and connection colors. Card typography and margins are in `card.gd`; the demo shell is in `demo/main.gd`.

The three SVG illustrations are original, editable vector assets. No raster image generator was used. AI assisted with code, vector markup, sample writing and documentation; disclose that accurately on your product page.

## Saves and validation

Saves contain the schema version, case ID, card positions and undirected links. They are plain JSON. Invalid/wrong-case saves are rejected without replacing current state. Writes use a temporary file and rename to reduce partial-file risk. This does not provide cryptographic integrity, cloud storage or guaranteed recovery after power loss.

Save to `user://`, not `res://`. No network requests, accounts, telemetry, paid libraries or API keys are required by this project. The Godot engine and its export templates are separate downloads.

## Tests

From this folder, with Godot on your PATH:

```sh
godot --headless --path . --script res://tests/run_tests.gd
```

See `VALIDATION.md` for the exact tested version and limits. This initial release does not claim mobile, console or gamepad support. Browser demo HTML is a separate early prototype, not a Godot Web export.

## Included files

- `addons/caseboard/`: reusable scene, card UI, board UI and validation/state model.
- `demo/`: demo shell and two original fictional cases.
- `art/`: three editable SVG files.
- `tests/`: regression checks runnable in Godot.
- `store/`: suggested listing text and a separate browser prototype.
- `LICENSE.txt`, `VALIDATION.md`, `START-HERE-KA.md`.

Read the license before use. You may use the kit in completed commercial games, but may not redistribute it as a standalone asset pack.
