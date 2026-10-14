# Caseboard Starter Kit — Godot Evidence Board

**Suggested starting price: $4.99 USD. This is a pricing experiment, not an earnings forecast.**

## Description to paste into your itch.io page

Build a small detective game's evidence board without writing the card, connection and save logic from scratch.

Caseboard Starter Kit is an editable Godot 4 project and reusable scene component. Arrange clue cards, connect evidence, check author-defined deductions and restore saved board layouts.

### Included

- Draggable, keyboard-focusable clue cards.
- Undirected connections: select two cards to link; repeat to unlink.
- JSON case format with author-defined required connections.
- Strict deductions or deductions that allow extra links.
- Save/load of card positions and connections, with invalid-save validation.
- Three editable color palettes: Archive, Blueprint and Noir.
- Two original, short fictional sample cases.
- Optional project-image support and three editable SVG illustrations.
- Reusable board scene, full GDScript source and integration guide.
- Automated regression checks.

### Getting started

Import `project.godot` in Godot 4.5.1 and press F5. To integrate with an existing game, copy `addons/caseboard/`, instance `board.tscn` in a ScrollContainer, load your case JSON and connect the `case_solved` signal.

### Scope and compatibility

54 automated checks passed in Godot 4.5.1 on Linux in headless mode. Visual inspection and physical input-device testing have not been completed. This is an initial source kit, not a fully visually verified release. It is a small 2D scene component, not a no-code editor plugin or a complete detective game. It does not provide dialogue, inventories, automatic story writing, networking, gamepad support or localization. There is no claim of testing on Windows, macOS, mobile, console or Godot Web exports. Other Godot versions have not been validated.

Case content is edited in JSON. The built-in board is fixed-size and scrollable. Keep card text short; extend the UI for long descriptions.

The optional HTML browser prototype is a separate concept preview. It is not an exported Godot build and has fewer features than the source project.

### License

Use and modify the kit in your own commercial or personal games. Attribution is optional. Do not redistribute or resell the kit as a standalone asset/template. Full terms are in LICENSE.txt.

### AI disclosure

AI assisted with GDScript code, documentation, fictional cases and vector SVG markup. The project was then executed and checked in Godot; see VALIDATION.md for the exact coverage and limitations. No raster image generator was used.

## Page setup notes (do not paste as product description)

- Kind: downloadable game asset/source project.
- Relevant tags to select from available itch.io tags: Godot, User Interface (UI), Detective, Mystery, sourcecode, 2D. Use only relevant tags; do not claim unsupported engines.
- Upload this ZIP as the paid source package.
- A browser preview can be packaged separately: rename `browser-prototype.html` to `index.html` in its own ZIP and clearly label it a concept preview. Keep the source kit as a separate download.
- `cover.png` is a product illustration, not a screenshot. Actual Godot screenshots still need to be captured after graphical testing. Do not substitute the HTML prototype as a Godot screenshot.
- Provide the exact engine version and tested limitations.
- Do not claim popularity, purchase counts, guaranteed game compatibility or sales.
- Complete your own payment/tax setup and verify receipt options before treating sales income as available for withdrawal.
