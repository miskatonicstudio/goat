extends Spatial

var door_open = false


func _ready():
	goat.connect("oat_game_mode_changed", self, "notify", ["Game mode changed: "])
	goat.connect("oat_environment_item_selected", self, "notify", ["Selected: "])
	goat.connect("oat_environment_item_deselected", self, "notify", ["Deselected: "])
	goat.connect("oat_environment_item_activated", self, "notify", ["Activated: "])
	goat.connect("oat_environment_item_obtained", self, "notify", ["Obtained: "])
	goat.connect("oat_inventory_item_selected", self, "notify", ["Selected: "])
	goat.connect("oat_inventory_item_removed", self, "notify", ["Removed: "])
	goat.connect("oat_inventory_item_used", self, "notify", ["Used: "])
	goat.connect("oat_inventory_item_used_on_inventory", self, "notify2", ["Used inventory: "])
	goat.connect("oat_inventory_item_used_on_environment", self, "notify2", ["Used environment: "])
	goat.connect("oat_inventory_item_replaced", self, "notify2", ["Replaced: "])
	
	goat.connect("oat_environment_item_activated", self, "activate")
	goat.connect("oat_inventory_item_used", self, "use_item")
	goat.connect("oat_inventory_item_used_on_inventory", self, "use_item_on_inventory")
	goat.connect("oat_inventory_item_used_on_environment", self, "use_item_on_environment")
	
	# TODO: do not send item selected signal when item is first added, instead send it when inventory is open?
	goat.connect_monologue("oat_inventory_item_selected", load("res://demo/sounds/short.ogg"))
	goat.connect_monologue("oat_inventory_item_used", load("res://demo/sounds/long.ogg"))
	
	# TODO: put it in a custom global file
	goat.inventory_items_textures["pen"] = load("res://demo/inventory_items/icons/pen.png")
	goat.inventory_items_textures["ball"] = load("res://demo/inventory_items/icons/ball.png")
	goat.inventory_items_textures["ball_on_a_stick"] = load("res://demo/inventory_items/icons/ball_on_a_stick.png")
	goat.inventory_items_textures["cube"] = load("res://demo/inventory_items/icons/cube.png")
	goat.inventory_items_textures["square"] = load("res://demo/inventory_items/icons/square.png")
	goat.inventory_items_textures["remote"] = load("res://demo/inventory_items/icons/remote.png")
	goat.inventory_items_textures["console"] = load("res://demo/inventory_items/icons/console.png")
	
	goat.inventory_items_models["pen"] = load("res://demo/inventory_items/models/Pen.tscn")
	goat.inventory_items_models["ball"] = load("res://demo/inventory_items/models/Ball.tscn")
	goat.inventory_items_models["ball_on_a_stick"] = load("res://demo/inventory_items/models/BallOnAStick.tscn")
	goat.inventory_items_models["cube"] = load("res://demo/inventory_items/models/Cube.tscn")
	goat.inventory_items_models["square"] = load("res://demo/inventory_items/models/Square.tscn")
	goat.inventory_items_models["remote"] = load("res://demo/inventory_items/models/Remote.tscn")
	goat.inventory_items_models["console"] = load("res://demo/inventory_items/models/Console.tscn")


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
		goat.emit_signal("oat_inventory_item_replaced", item_name2, "ball_on_a_stick")
		goat.emit_signal("oat_inventory_item_removed", item_name1)


func use_item_on_environment(inventory_item_name, environment_item_name):
	if inventory_item_name == "ball_on_a_stick" and environment_item_name == "prism":
		goat.emit_signal("oat_inventory_item_removed", "ball_on_a_stick")
		$UseItemOnEnvDemo/BallOnAStick.show()
		$UseItemOnEnvDemo/AnimationPlayer.play("pulse_light")


func use_item(item_name):
	if item_name == "cube":
		goat.emit_signal("oat_inventory_item_replaced", item_name, "square")
	if item_name == "square":
		goat.emit_signal("oat_inventory_item_removed", "square")


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
