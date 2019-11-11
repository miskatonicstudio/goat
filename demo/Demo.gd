extends Spatial

var door_open = false


func _ready():
	oat_interaction_signals.connect("oat_environment_item_selected", self, "notify", ["Selected: "])
	oat_interaction_signals.connect("oat_environment_item_deselected", self, "notify", ["Deselected: "])
	oat_interaction_signals.connect("oat_environment_item_activated", self, "notify", ["Activated: "])
	oat_interaction_signals.connect("oat_environment_item_obtained", self, "notify", ["Obtained: "])
	oat_interaction_signals.connect("oat_inventory_item_selected", self, "notify", ["Selected: "])
	oat_interaction_signals.connect("oat_inventory_item_used_on_inventory", self, "notify2", ["Used: "])
	
	oat_interaction_signals.connect("oat_environment_item_activated", self, "activate")
	
	# TODO: put it in a custom global file
	oat_interaction_signals.inventory_items_textures["pen"] = load("res://demo/pen.png")
	oat_interaction_signals.inventory_items_textures["ball"] = load("res://demo/ball.png")
	
	oat_interaction_signals.inventory_items_models["pen"] = load("res://demo/InventoryItemPen.tscn")
	oat_interaction_signals.inventory_items_models["ball"] = load("res://demo/InventoryItemBall.tscn")


func notify(item_name, text):
	$Notification.text = text + item_name
	$Timer.start()


func notify2(item_name1, item_name2, text):
	$Notification.text = text + item_name1 + " => " + item_name2
	$Timer.start()


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
