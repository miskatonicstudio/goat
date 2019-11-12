extends Spatial

var door_open = false


func _ready():
	oat_interaction_signals.connect("oat_game_mode_changed", self, "notify", ["Game mode changed: "])
	oat_interaction_signals.connect("oat_environment_item_selected", self, "notify", ["Selected: "])
	oat_interaction_signals.connect("oat_environment_item_deselected", self, "notify", ["Deselected: "])
	oat_interaction_signals.connect("oat_environment_item_activated", self, "notify", ["Activated: "])
	oat_interaction_signals.connect("oat_environment_item_obtained", self, "notify", ["Obtained: "])
	oat_interaction_signals.connect("oat_inventory_item_selected", self, "notify", ["Selected: "])
	oat_interaction_signals.connect("oat_inventory_item_removed", self, "notify", ["Removed: "])
	oat_interaction_signals.connect("oat_inventory_item_used", self, "notify", ["Used: "])
	oat_interaction_signals.connect("oat_inventory_item_used_on_inventory", self, "notify2", ["Used inventory: "])
	oat_interaction_signals.connect("oat_inventory_item_used_on_environment", self, "notify2", ["Used environment: "])
	oat_interaction_signals.connect("oat_inventory_item_replaced", self, "notify2", ["Replaced: "])
	
	oat_interaction_signals.connect("oat_environment_item_activated", self, "activate")
	oat_interaction_signals.connect("oat_inventory_item_used", self, "use_item")
	oat_interaction_signals.connect("oat_inventory_item_used_on_inventory", self, "use_item_on_inventory")
	oat_interaction_signals.connect("oat_inventory_item_used_on_environment", self, "use_item_on_environment")
	
	# TODO: put it in a custom global file
	oat_interaction_signals.inventory_items_textures["pen"] = load("res://demo/pen.png")
	oat_interaction_signals.inventory_items_textures["ball"] = load("res://demo/ball.png")
	oat_interaction_signals.inventory_items_textures["ball_on_a_stick"] = load("res://demo/ball_on_a_stick.png")
	oat_interaction_signals.inventory_items_textures["cube"] = load("res://demo/cube.png")
	oat_interaction_signals.inventory_items_textures["square"] = load("res://demo/square.png")
	oat_interaction_signals.inventory_items_textures["remote"] = load("res://demo/remote.png")
	
	oat_interaction_signals.inventory_items_models["pen"] = load("res://demo/InventoryItemPen.tscn")
	oat_interaction_signals.inventory_items_models["ball"] = load("res://demo/InventoryItemBall.tscn")
	oat_interaction_signals.inventory_items_models["ball_on_a_stick"] = load("res://demo/InventoryItemBallOnAStick.tscn")
	oat_interaction_signals.inventory_items_models["cube"] = load("res://demo/InventoryItemCube.tscn")
	oat_interaction_signals.inventory_items_models["square"] = load("res://demo/InventoryItemSquare.tscn")
	oat_interaction_signals.inventory_items_models["remote"] = load("res://demo/InventoryItemRemote.tscn")


func notify(item_name, text):
	$Notification.text = text + str(item_name)
	print($Notification.text)
	$Timer.start()


func notify2(item_name1, item_name2, text):
	$Notification.text = text + item_name1 + " => " + item_name2
	print($Notification.text)
	$Timer.start()


func use_item_on_inventory(item_name1, item_name2):
	# TODO: extract logic of joining objects?
	if item_name1 == "pen" and item_name2 == "ball" or item_name1 == "ball" and item_name2 == "pen":
		oat_interaction_signals.emit_signal("oat_inventory_item_replaced", item_name2, "ball_on_a_stick")
		oat_interaction_signals.emit_signal("oat_inventory_item_removed", item_name1)


func use_item_on_environment(inventory_item_name, environment_item_name):
	if inventory_item_name == "ball_on_a_stick" and environment_item_name == "prism":
		oat_interaction_signals.emit_signal("oat_inventory_item_removed", "ball_on_a_stick")
		$UseItemOnEnvDemo/BallOnAStick.show()
		$UseItemOnEnvDemo/AnimationPlayer.play("pulse_light")


func use_item(item_name):
	if item_name == "cube":
		oat_interaction_signals.emit_signal("oat_inventory_item_replaced", item_name, "square")
	if item_name == "square":
		oat_interaction_signals.emit_signal("oat_inventory_item_removed", "square")


func _on_Timer_timeout():
	$Notification.text = ""


func activate(item_name):
	if item_name == "button_2":
		if door_open:
			$AnimationPlayer.play_backwards("open_door")
		else:
			$AnimationPlayer.play("open_door")
		door_open = not door_open
	if item_name == "button_1":
		$AnimationPlayer.play("drop_crate")
