extends RefCounted
## Case data and save validation, independent of the UI.

const SCHEMA_VERSION := 1
const MAX_CARDS := 40
const MAX_SAVE_BYTES := 262144
var case_data: Dictionary = {}
var positions: Dictionary = {}
var links: Array[String] = []
var last_error := ""

func fail(message: String) -> bool:
	last_error = message
	return false

func number_ok(value: Variant) -> bool:
	return (value is int or value is float) and is_finite(float(value))

func point_ok(point: Variant) -> bool:
	return point is Array and point.size() == 2 and number_ok(point[0]) and number_ok(point[1]) and float(point[0]) >= 0.0 and float(point[0]) <= 1200.0 and float(point[1]) >= 0.0 and float(point[1]) <= 740.0

func valid_id(value: Variant) -> bool:
	if not value is String or value.is_empty() or value.length() > 64:
		return false
	for character in value:
		if not character in "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_-":
			return false
	return true

func pair(a: String, b: String) -> String:
	return a + "|" + b if a < b else b + "|" + a

func load_case_file(path: String) -> bool:
	if not FileAccess.file_exists(path):
		return fail("Case file not found.")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_SAVE_BYTES:
		return fail("Case file could not be read or is too large.")
	return set_case(JSON.parse_string(file.get_as_text()))

func set_case(data: Variant) -> bool:
	if not data is Dictionary:
		return fail("Case must be a JSON object.")
	if data.get("schema_version") != SCHEMA_VERSION or not valid_id(data.get("id")):
		return fail("Unsupported case version or invalid case ID.")
	for field in ["title", "brief", "success_text"]:
		if not data.get(field) is String or data[field].is_empty() or data[field].length() > 4000:
			return fail("Missing or invalid case text: " + field)
	var cards: Variant = data.get("cards")
	if not cards is Array or cards.is_empty() or cards.size() > MAX_CARDS:
		return fail("Cases need 1 to 40 cards.")
	var ids: Dictionary = {}
	var new_positions: Dictionary = {}
	for card in cards:
		if not card is Dictionary or not valid_id(card.get("id")) or ids.has(card["id"]):
			return fail("Invalid or duplicate card ID.")
		for field in ["title", "body", "kind"]:
			if not card.get(field) is String or card[field].length() > 2000:
				return fail("Invalid card text.")
		if not point_ok(card.get("position")):
			return fail("Card position must be inside the board.")
		var image: Variant = card.get("image", "")
		if not image is String:
			return fail("Image must be a resource path.")
		if not image.is_empty() and (not image.begins_with("res://") or ".." in image or not image.get_extension().to_lower() in ["png", "jpg", "jpeg", "webp", "svg"]):
			return fail("Images must be project image resources.")
		ids[card["id"]] = true
		new_positions[card["id"]] = Vector2(float(card["position"][0]), float(card["position"][1]))
	var rules: Variant = data.get("required_links")
	if not rules is Array or rules.is_empty() or rules.size() > 780:
		return fail("Add at least one required link.")
	var seen: Dictionary = {}
	for rule in rules:
		if not rule is Array or rule.size() != 2 or not rule[0] is String or not rule[1] is String:
			return fail("Required links must contain two card IDs.")
		if not ids.has(rule[0]) or not ids.has(rule[1]) or rule[0] == rule[1]:
			return fail("Required link refers to an unknown or identical card.")
		var key := pair(rule[0], rule[1])
		if seen.has(key):
			return fail("Duplicate required link.")
		seen[key] = true
	if not data.get("strict_solution", true) is bool:
		return fail("strict_solution must be true or false.")
	case_data = data.duplicate(true)
	positions = new_positions
	links.clear()
	last_error = ""
	return true

func toggle_link(a: String, b: String) -> bool:
	if a == b or not positions.has(a) or not positions.has(b):
		return fail("Choose two different known cards.")
	var key := pair(a, b)
	if links.has(key):
		links.erase(key)
	else:
		links.append(key)
	last_error = ""
	return true

func move_card(id: String, point: Vector2) -> bool:
	if not positions.has(id) or not point.is_finite():
		return fail("Invalid movement.")
	positions[id] = point.clamp(Vector2.ZERO, Vector2(1200, 740))
	return true

func check_solution() -> Dictionary:
	if case_data.is_empty():
		return {"solved": false, "missing": 0, "extra": 0}
	var required: Array[String] = []
	for rule in case_data["required_links"]:
		required.append(pair(rule[0], rule[1]))
	var missing := 0
	var extra := 0
	for key in required:
		if not links.has(key):
			missing += 1
	for key in links:
		if not required.has(key):
			extra += 1
	return {"solved": missing == 0 and (extra == 0 or not case_data.get("strict_solution", true)), "missing": missing, "extra": extra}

func snapshot() -> Dictionary:
	var points: Dictionary = {}
	for id in positions:
		var p: Vector2 = positions[id]
		points[id] = [p.x, p.y]
	return {"schema_version": SCHEMA_VERSION, "case_id": case_data.get("id", ""), "positions": points, "links": links.duplicate()}

func restore(data: Variant) -> bool:
	if not data is Dictionary or data.get("schema_version") != SCHEMA_VERSION or data.get("case_id") != case_data.get("id"):
		return fail("Save is invalid or belongs to another case.")
	var points: Variant = data.get("positions")
	var saved_links: Variant = data.get("links")
	if not points is Dictionary or points.size() != positions.size() or not saved_links is Array or saved_links.size() > 780:
		return fail("Invalid save structure.")
	var new_positions: Dictionary = {}
	var new_links: Array[String] = []
	for id in positions:
		if not points.has(id) or not point_ok(points[id]):
			return fail("Invalid saved card position.")
		new_positions[id] = Vector2(float(points[id][0]), float(points[id][1]))
	for key in saved_links:
		if not key is String:
			return fail("Invalid saved connection.")
		var ends: PackedStringArray = key.split("|")
		if ends.size() != 2 or not positions.has(ends[0]) or not positions.has(ends[1]) or ends[0] == ends[1] or key != pair(ends[0], ends[1]) or new_links.has(key):
			return fail("Invalid or duplicate saved connection.")
		new_links.append(key)
	positions = new_positions
	links = new_links
	last_error = ""
	return true

func save_file(path: String) -> bool:
	if case_data.is_empty() or not path.begins_with("user://") or ".." in path:
		return fail("Choose a user:// save path after loading a case.")
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		return fail("Could not open save file.")
	file.store_string(JSON.stringify(snapshot(), "\t"))
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return fail("Save write failed.")
	if DirAccess.rename_absolute(temporary, path) != OK:
		return fail("Could not finish save file.")
	last_error = ""
	return true

func load_save(path: String) -> bool:
	if not path.begins_with("user://") or ".." in path:
		return fail("Use a user:// save path.")
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return fail("No readable save file found.")
	if file.get_length() > MAX_SAVE_BYTES:
		return fail("Save file is too large.")
	return restore(JSON.parse_string(file.get_as_text()))
