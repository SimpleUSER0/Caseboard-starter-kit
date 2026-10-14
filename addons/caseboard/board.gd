extends Control
## Instance board.tscn, call load_case(), connect case_solved to your game.
signal board_changed
signal case_solved(case_id: String)
signal message(text: String)
const Model = preload("res://addons/caseboard/model.gd")
const Card = preload("res://addons/caseboard/card.gd")
const PALETTES := {
	"Archive": {"background": Color("233238"), "grid": Color("34454c"), "paper": Color("eadfc8"), "ink": Color("233238"), "accent": Color("b88646"), "line": Color("e9b96d")},
	"Blueprint": {"background": Color("102e48"), "grid": Color("1e4260"), "paper": Color("d8eaf4"), "ink": Color("123249"), "accent": Color("3a799c"), "line": Color("82cef2")},
	"Noir": {"background": Color("211f28"), "grid": Color("34313c"), "paper": Color("d9d4dd"), "ink": Color("292433"), "accent": Color("8e4c66"), "line": Color("df8baf")}
}
@export_enum("Archive", "Blueprint", "Noir") var palette_name := "Archive"
var model = Model.new()
var cards: Dictionary = {}
var link_mode := false
var selected_id := ""

func _ready() -> void:
	custom_minimum_size = Vector2(1500, 1000)
	queue_redraw()

func load_case(path: String) -> bool:
	if not model.load_case_file(path):
		message.emit(model.last_error)
		return false
	_rebuild()
	board_changed.emit()
	return true

func _rebuild() -> void:
	for card in cards.values():
		remove_child(card)
		card.queue_free()
	cards.clear()
	selected_id = ""
	var palette: Dictionary = PALETTES.get(palette_name, PALETTES["Archive"])
	for data in model.case_data.get("cards", []):
		var card = Card.new()
		card.name = "Card_" + data["id"]
		add_child(card)
		card.setup(data, palette)
		card.position = model.positions[data["id"]]
		card.link_mode = link_mode
		card.activated.connect(_activate)
		card.moved.connect(_move)
		cards[data["id"]] = card
	queue_redraw()

func set_palette(value: String) -> void:
	if PALETTES.has(value):
		palette_name = value
		_rebuild()

func set_link_mode(enabled: bool) -> void:
	link_mode = enabled
	selected_id = ""
	for card in cards.values():
		card.link_mode = enabled
		card.dragging = false
		card.set_selected(false)
	message.emit("Select two cards to toggle their connection." if enabled else "Drag cards to arrange the board.")

func _activate(id: String) -> void:
	if not link_mode:
		return
	if selected_id.is_empty():
		selected_id = id
		cards[id].set_selected(true)
		message.emit("Select a second card. Select the same card to cancel.")
	else:
		if selected_id != id:
			model.toggle_link(selected_id, id)
			board_changed.emit()
			message.emit("Connection updated. Repeat the pair to remove it.")
		cards[selected_id].set_selected(false)
		selected_id = ""
	queue_redraw()

func _move(id: String, point: Vector2) -> void:
	if model.move_card(id, point):
		cards[id].position = model.positions[id]
		queue_redraw()
		board_changed.emit()

func _draw() -> void:
	var palette: Dictionary = PALETTES.get(palette_name, PALETTES["Archive"])
	draw_rect(Rect2(Vector2.ZERO, size), palette["background"])
	for x in range(0, int(size.x), 28):
		for y in range(0, int(size.y), 28):
			draw_circle(Vector2(x, y), 1.0, palette["grid"])
	for key in model.links:
		var ends: PackedStringArray = key.split("|")
		var a: Control = cards[ends[0]]
		var b: Control = cards[ends[1]]
		draw_line(a.position + a.size / 2.0, b.position + b.size / 2.0, palette["line"], 3.0, true)

func save_board(path: String) -> bool:
	var result: bool = model.save_file(path)
	message.emit("Board saved." if result else model.last_error)
	return result

func load_board(path: String) -> bool:
	if not model.load_save(path):
		message.emit(model.last_error)
		return false
	_rebuild()
	board_changed.emit()
	message.emit("Saved board restored.")
	return true

func reset_board() -> void:
	if not model.case_data.is_empty():
		model.set_case(model.case_data.duplicate(true))
		_rebuild()
		board_changed.emit()
		message.emit("Board reset. Existing save has not been deleted.")

func submit_solution() -> bool:
	var result: Dictionary = model.check_solution()
	if result["solved"]:
		message.emit(model.case_data["success_text"])
		case_solved.emit(model.case_data["id"])
	else:
		message.emit("Not solved yet. %d required links missing; %d extra links." % [result["missing"], result["extra"]])
	return result["solved"]
