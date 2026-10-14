extends Control
const BoardScene = preload("res://addons/caseboard/board.tscn")
var board
var title_label: Label
var brief_label: Label
var status_label: Label
var count_label: Label
var link_button: Button
var case_picker: OptionButton
var theme_picker: OptionButton
const CASES := ["res://demo/cases/observatory.json", "res://demo/cases/last_delivery.json"]

func _ready() -> void:
	var backdrop := ColorRect.new()
	backdrop.color = Color("101b21")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right", "top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 24)
	add_child(margin)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 14)
	margin.add_child(layout)
	var eyebrow := Label.new()
	eyebrow.text = "CASEBOARD / GODOT STARTER KIT"
	eyebrow.add_theme_font_size_override("font_size", 13)
	eyebrow.add_theme_color_override("font_color", Color("e9b96d"))
	layout.add_child(eyebrow)
	var header := HBoxContainer.new()
	layout.add_child(header)
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 30)
	title_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title_label)
	case_picker = OptionButton.new()
	case_picker.add_item("The Observatory Key")
	case_picker.add_item("The Last Delivery")
	case_picker.item_selected.connect(_choose_case)
	header.add_child(case_picker)
	theme_picker = OptionButton.new()
	for theme_name in ["Archive", "Blueprint", "Noir"]:
		theme_picker.add_item(theme_name)
	theme_picker.item_selected.connect(func(index: int): board.set_palette(theme_picker.get_item_text(index)))
	header.add_child(theme_picker)
	brief_label = Label.new()
	brief_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	brief_label.add_theme_color_override("font_color", Color("b9cac8"))
	layout.add_child(brief_label)
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 10)
	layout.add_child(toolbar)
	link_button = make_button("Link mode: OFF", toolbar)
	link_button.toggle_mode = true
	link_button.toggled.connect(func(enabled: bool):
		board.set_link_mode(enabled)
		link_button.text = "Link mode: ON" if enabled else "Link mode: OFF"
	)
	make_button("Save", toolbar).pressed.connect(func(): board.save_board(save_path()))
	make_button("Load", toolbar).pressed.connect(func(): board.load_board(save_path()))
	make_button("Reset", toolbar).pressed.connect(func(): board.reset_board())
	make_button("Check deduction", toolbar).pressed.connect(func(): board.submit_solution())
	count_label = Label.new()
	count_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	toolbar.add_child(count_label)
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	layout.add_child(scroll)
	board = BoardScene.instantiate()
	scroll.add_child(board)
	board.message.connect(func(text: String): status_label.text = text)
	board.board_changed.connect(func(): count_label.text = "%d clues / %d links" % [board.cards.size(), board.model.links.size()])
	status_label = Label.new()
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status_label.custom_minimum_size.y = 40
	status_label.add_theme_color_override("font_color", Color("e9b96d"))
	layout.add_child(status_label)
	var help := Label.new()
	help.text = "DRAG: move cards   |   LINK MODE: select two cards; repeat to unlink   |   TAB + ARROWS: move focused card   |   ENTER: select"
	help.add_theme_font_size_override("font_size", 12)
	help.add_theme_color_override("font_color", Color("99adaa"))
	help.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	layout.add_child(help)
	_choose_case(0)

func make_button(text: String, parent: Node) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 40
	parent.add_child(button)
	return button

func _choose_case(index: int) -> void:
	link_button.set_pressed_no_signal(false)
	link_button.text = "Link mode: OFF"
	board.set_link_mode(false)
	if board.load_case(CASES[index]):
		title_label.text = board.model.case_data["title"]
		brief_label.text = board.model.case_data["brief"]
		status_label.text = "Arrange the clues, link your evidence, then check your deduction."

func save_path() -> String:
	return "user://caseboard_" + board.model.case_data["id"] + ".json"
