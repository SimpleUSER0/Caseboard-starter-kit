extends PanelContainer
## Focusable evidence card. Mouse dragging and keyboard movement share one signal.
signal activated(card_id: String)
signal moved(card_id: String, point: Vector2)
var card_id := ""
var link_mode := false
var dragging := false
var drag_offset := Vector2.ZERO
var selected := false
var paper := Color("eadfc8")
var ink := Color("233238")
var accent := Color("b88646")

func setup(data: Dictionary, palette: Dictionary) -> void:
	card_id = data["id"]
	paper = palette["paper"]
	ink = palette["ink"]
	accent = palette["accent"]
	custom_minimum_size = Vector2(260, 220)
	size = custom_minimum_size
	focus_mode = Control.FOCUS_ALL
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tooltip_text = "Drag to move. Tab + arrows to move. Enter to link in link mode."
	var column := VBoxContainer.new()
	column.custom_minimum_size.x = 228
	column.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_theme_constant_override("separation", 8)
	add_child(column)
	var kind := Label.new()
	kind.text = data["kind"].to_upper()
	kind.add_theme_font_size_override("font_size", 12)
	kind.add_theme_color_override("font_color", accent)
	kind.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(kind)
	var title_label := Label.new()
	title_label.custom_minimum_size.x = 228
	title_label.text = data["title"]
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	title_label.add_theme_font_size_override("font_size", 22)
	title_label.add_theme_color_override("font_color", ink)
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(title_label)
	var image: String = data.get("image", "")
	if not image.is_empty() and ResourceLoader.exists(image):
		var texture := load(image) as Texture2D
		if texture != null:
			var illustration := TextureRect.new()
			illustration.texture = texture
			illustration.custom_minimum_size = Vector2(220, 72)
			illustration.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			illustration.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			illustration.mouse_filter = Control.MOUSE_FILTER_IGNORE
			column.add_child(illustration)
	var body := Label.new()
	body.custom_minimum_size.x = 228
	body.text = data["body"]
	body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_theme_font_size_override("font_size", 15)
	body.add_theme_color_override("font_color", ink)
	body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	column.add_child(body)
	focus_entered.connect(_style)
	focus_exited.connect(_style)
	_style()

func _style() -> void:
	var panel := StyleBoxFlat.new()
	panel.bg_color = paper
	panel.border_color = accent
	panel.border_width_top = 5
	panel.border_width_left = 3 if selected else 0
	panel.border_width_right = 3 if selected else 0
	panel.border_width_bottom = 3 if selected else 0
	panel.corner_radius_top_left = 5
	panel.corner_radius_top_right = 5
	panel.corner_radius_bottom_left = 5
	panel.corner_radius_bottom_right = 5
	panel.content_margin_left = 16
	panel.content_margin_right = 16
	panel.content_margin_top = 14
	panel.content_margin_bottom = 16
	panel.shadow_color = Color(0, 0, 0, 0.3)
	panel.shadow_size = 6
	add_theme_stylebox_override("panel", panel)
	if has_focus():
		panel.set_border_width_all(3)

func set_selected(value: bool) -> void:
	selected = value
	_style()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			grab_focus()
			if link_mode:
				activated.emit(card_id)
			else:
				dragging = true
				drag_offset = get_parent().get_local_mouse_position() - position
				move_to_front()
		else:
			dragging = false
		accept_event()
	elif event is InputEventMouseMotion and dragging:
		moved.emit(card_id, get_parent().get_local_mouse_position() - drag_offset)
		accept_event()
	elif event is InputEventKey and event.pressed:
		var delta := Vector2.ZERO
		match event.keycode:
			KEY_LEFT: delta.x = -1
			KEY_RIGHT: delta.x = 1
			KEY_UP: delta.y = -1
			KEY_DOWN: delta.y = 1
			KEY_ENTER, KEY_SPACE:
				if link_mode:
					activated.emit(card_id)
		if delta != Vector2.ZERO:
			moved.emit(card_id, position + delta * (40 if event.shift_pressed else 10))
			accept_event()
		elif event.keycode in [KEY_ENTER, KEY_SPACE] and link_mode:
			accept_event()
