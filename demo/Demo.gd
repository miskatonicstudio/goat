extends Spatial

var door_open = false


func _ready():
	goat.set_game_resources_directory("demo")
	
	goat.register_unique_name("ball_on_a_stick")
	goat.register_unique_name("square")
	
	goat.register_inventory_item("pen")
	goat.register_inventory_item("ball")
	goat.register_inventory_item("ball_on_a_stick")
	goat.register_inventory_item("remote")
	goat.register_inventory_item("cube")
	goat.register_inventory_item("square")
	goat.register_inventory_item("console")
	
	goat.register_monologue("short")
	goat.register_monologue("long")
	
	goat.connect_monologue("inventory_item_used_cube", "short")
	goat.connect_monologue("inventory_item_ball_on_a_stick_used_on_environment_prism", "long")
	
	goat.connect("game_mode_changed", self, "notify", ["Game mode changed: "])
	goat.connect("interactive_item_selected", self, "notify", ["Selected: "])
	goat.connect("interactive_item_deselected", self, "notify", ["Deselected: "])
	goat.connect("interactive_item_activated", self, "notify2", ["Activated: "])
	goat.connect("inventory_item_obtained", self, "notify", ["Obtained: "])
	goat.connect("inventory_item_selected", self, "notify", ["Selected (inv): "])
	goat.connect("inventory_item_removed", self, "notify", ["Removed: "])
	goat.connect("inventory_item_used", self, "notify", ["Used: "])
	goat.connect("inventory_item_used_on_inventory", self, "notify2", ["Used inventory: "])
	goat.connect("inventory_item_used_on_environment", self, "notify2", ["Used environment: "])
	goat.connect("inventory_item_replaced", self, "notify2", ["Replaced: "])
	
	goat.connect("interactive_item_activated", self, "activate")
	goat.connect("inventory_item_used", self, "use_item")
	goat.connect("inventory_item_used_on_inventory", self, "use_item_on_inventory")
	goat.connect("inventory_item_used_on_environment", self, "use_item_on_environment")
	
	goat.connect("inventory_item_pen_used_on_environment_button_2", self, "pen_on_button_2")


func notify(item_name, text):
	$Notification.text = text + str(item_name)
	print($Notification.text)
	$Timer.start()


func notify2(item_name1, item_name2, text):
	$Notification.text = text + item_name1 + " => " + str(item_name2)
	print($Notification.text)
	$Timer.start()


func use_item_on_inventory(item_name1, item_name2):
	if item_name1 == "pen" and item_name2 == "ball" or item_name1 == "ball" and item_name2 == "pen":
		goat.emit_signal("inventory_item_replaced", item_name2, "ball_on_a_stick")
		goat.emit_signal("inventory_item_removed", item_name1)


func use_item_on_environment(inventory_item_name, environment_item_name):
	if inventory_item_name == "ball_on_a_stick" and environment_item_name == "prism":
		goat.emit_signal("inventory_item_removed", "ball_on_a_stick")
		$UseItemOnEnvDemo/BallOnAStick.show()
		$UseItemOnEnvDemo/AnimationPlayer.play("pulse_light")


func use_item(item_name):
	if item_name == "cube":
		goat.emit_signal("inventory_item_replaced", item_name, "square")
	if item_name == "square":
		goat.emit_signal("inventory_item_removed", "square")


func _on_Timer_timeout():
	$Notification.text = ""


func activate(item_name, _position):
	if item_name == "button_2":
		if door_open:
			$AnimationPlayer.play_backwards("open_door")
		else:
			$AnimationPlayer.play("open_door")
		door_open = not door_open
	if item_name == "button_1":
		$AnimationPlayer.play("drop_crate")


func pen_on_button_2():
	print("Custom signal: pen on button_2")
