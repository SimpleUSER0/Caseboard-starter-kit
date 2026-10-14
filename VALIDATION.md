# Validation — v0.1.0

Date: 14 October 2026 UTC (15 October in Georgia).

Engine: **Godot 4.5.1 stable, official Linux x86_64 standard build**, commit f62fdbde1.

## Completed

- Headless editor import of the project and SVG resources.
- Headless startup of the full demo scene, without script/runtime errors.
- **54/54 automated checks passed** in the actual Godot engine, not a simulated JavaScript environment.
- Model checks: valid sample cases; canonical undirected links; toggle/removal; self/unknown link rejection; both sample solutions; strict/lenient solution behavior; movement bounds and non-finite rejection.
- Save checks: actual disk write/read; exact round trip; wrong-case rejection; invalid coordinates, unknown/duplicate/noncanonical links and malformed state rejection; invalid restoration leaves live state unchanged; source-resource overwrite rejection.
- Scene checks: six cards created; selected state; connection flow; success signal; positions synchronized; saved layout reconstructed; three palettes preserve state; sample card dimensions remain within reserved canvas bounds; keyboard events route from card UI to model.

## Not completed / not claimed

- Graphical screenshot and visual layout inspection. The environment could not open a graphical display. No file in this kit is represented as a real Godot screenshot.
- Human mouse/keyboard usability testing; automated tests are not equivalent to a person using a real input device.
- Windows, macOS, other Godot versions, mobile, console, physical gamepads, screen-reader usability, or Web exports.
- Scale/performance benchmarking for the 40-card validation limit.
- Marketplace publication, indexing, sales or payment receipt.

The SVG/PNG cover is a product illustration, not a runtime screenshot. The bundled browser prototype is an earlier separate HTML implementation, not a Godot Web build. The kit should not be described as fully visually verified or cross-platform tested.

Run the included regression suite:

```sh
godot --headless --path . --script res://tests/run_tests.gd
```

Before calling the listing production-ready, visually inspect the F5 demo in Godot and check real dragging, keyboard focus, scrolling, theme changes, both cases and saving/loading. Add actual runtime screenshots to the listing once this is done.
