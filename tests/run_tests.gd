extends SceneTree
const Model = preload("res://addons/caseboard/model.gd")
const BoardScene = preload("res://addons/caseboard/board.tscn")
var checks := 0
var failures := 0

func check(value: bool, label: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: " + label)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var model = Model.new()
	check(model.load_case_file("res://demo/cases/observatory.json"), "sample case loads")
	check(model.positions.size() == 6, "six cards")
	check(not model.check_solution()["solved"], "empty board unsolved")
	check(model.toggle_link("mara", "camera"), "valid link")
	check(model.toggle_link("camera", "mara"), "reverse toggles same pair")
	check(model.links.is_empty(), "link removed")
	check(not model.toggle_link("mara", "mara"), "self link rejected")
	check(not model.toggle_link("mara", "unknown"), "unknown link rejected")
	model.toggle_link("mara", "camera")
	model.toggle_link("mara", "note")
	check(model.check_solution()["solved"], "correct case solved")
	model.toggle_link("mara", "desk")
	check(not model.check_solution()["solved"], "extra link rejected by strict rule")
	model.case_data["strict_solution"] = false
	check(model.check_solution()["solved"], "optional extra links supported")
	model.case_data["strict_solution"] = true
	model.toggle_link("mara", "desk")
	check(model.move_card("mara", Vector2(-10, 9999)), "movement accepted")
	check(model.positions["mara"] == Vector2(0, 740), "movement clamped")
	check(not model.move_card("mara", Vector2(INF, 0)), "infinite movement rejected")
	var original: Dictionary = model.snapshot()
	check(model.save_file("user://caseboard_test.json"), "disk save")
	model.links.clear()
	check(model.load_save("user://caseboard_test.json"), "disk restore")
	check(model.snapshot() == original, "state round trip exact")
	var invalid: Dictionary = original.duplicate(true)
	invalid["case_id"] = "wrong_case"
	check(not model.restore(invalid), "wrong case save rejected")
	check(model.snapshot() == original, "invalid restore transactional")
	invalid = original.duplicate(true)
	invalid["positions"]["mara"] = [90000, 0]
	check(not model.restore(invalid), "out of bounds save rejected")
	invalid = original.duplicate(true)
	invalid["links"] = ["camera|mara", "camera|mara"]
	check(not model.restore(invalid), "duplicate save links rejected")
	invalid = original.duplicate(true)
	invalid["links"] = ["camera|unknown"]
	check(not model.restore(invalid), "unknown save link rejected")
	invalid = original.duplicate(true)
	invalid["links"] = ["mara|camera"]
	check(not model.restore(invalid), "noncanonical pair rejected")
	check(not model.restore(null), "malformed JSON rejected")
	var broken: Dictionary = model.case_data.duplicate(true)
	broken["cards"][1]["id"] = broken["cards"][0]["id"]
	check(not model.set_case(broken), "duplicate card case rejected")
	check(model.snapshot() == original, "invalid case preserves state")
	broken = model.case_data.duplicate(true)
	broken["required_links"] = [["mara", "missing"]]
	check(not model.set_case(broken), "broken solution rule rejected")
	broken = model.case_data.duplicate(true)
	broken["cards"][0]["image"] = "user://private.png"
	check(not model.set_case(broken), "image outside project rejected")
	check(not model.save_file("res://overwrite.json"), "save cannot overwrite project")
	check(model.load_case_file("res://demo/cases/last_delivery.json"), "second case loads")
	for rule in model.case_data["required_links"]:
		model.toggle_link(rule[0], rule[1])
	check(model.check_solution()["solved"], "second case solution")
	check(not model.restore(original), "cross-case save rejected")
	var board = BoardScene.instantiate()
	root.add_child(board)
	check(board.load_case("res://demo/cases/observatory.json"), "board scene loads")
	check(board.cards.size() == 6, "board creates six interactive cards")
	await process_frame
	board.set_link_mode(true)
	board._activate("mara")
	check(board.cards["mara"].selected, "selection visible")
	board._activate("camera")
	check(board.model.links.size() == 1 and board.selected_id.is_empty(), "selection creates link and clears")
	board._activate("mara")
	board._activate("note")
	var solved_events: Array = []
	board.case_solved.connect(func(id: String): solved_events.append(id))
	check(board.submit_solution(), "board submits correct deduction")
	check(solved_events == ["observatory"], "game integration signal emitted")
	board._move("camera", Vector2(777, 222))
	check(board.cards["camera"].position == Vector2(777, 222), "visual card moves with model")
	check(board.save_board("user://caseboard_board_test.json"), "board save")
	board.reset_board()
	check(board.model.links.is_empty(), "reset clears current links")
	check(board.load_board("user://caseboard_board_test.json"), "board restore")
	check(board.cards["camera"].position == Vector2(777, 222), "board restore moves UI")
	for palette in ["Archive", "Blueprint", "Noir"]:
		board.set_palette(palette)
		check(board.cards.size() == 6 and board.model.links.size() == 2, "palette preserves state: " + palette)
	await process_frame
	for card in board.cards.values():
		check(card.size.x <= 300 and card.size.y <= 260, "sample card fits declared board bounds")
	var card = board.cards["mara"]
	var before: Vector2 = card.position
	var event := InputEventKey.new()
	event.keycode = KEY_RIGHT
	event.pressed = true
	card._gui_input(event)
	check(card.position == before + Vector2(10, 0), "keyboard movement routed through actual card")
	board.set_link_mode(true)
	var enter := InputEventKey.new()
	enter.keycode = KEY_ENTER
	enter.pressed = true
	card._gui_input(enter)
	check(board.selected_id == "mara", "keyboard link selection routed through card")
	board.queue_free()
	await process_frame
	for file in ["user://caseboard_test.json", "user://caseboard_board_test.json"]:
		DirAccess.remove_absolute(file)
	print("CASEBOARD CHECKS: %d passed / %d total" % [checks - failures, checks])
	quit(0 if failures == 0 else 1)
