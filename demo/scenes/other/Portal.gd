extends Spatial

# State: off, on, ready, active
var state = "off"
var food_eaten = false

onready var led = $CSGTorus/LED
onready var portal = $CSGTorus/Portal
onready var the_other_side_sound = $CSGTorus/Portal/TheOtherSideSound


func _ready():
	goat.connect("interactive_item_activated", self, "item_activated")
	goat.connect("inventory_item_used", self, "item_used")
	demo.connect("program_uploaded", self, "program_uploaded")
	demo.connect("remote_pressed", self, "remote_pressed")


func item_activated(item_name, _position):
	if item_name == "generator" and state == "off":
		led.material = load("res://demo/materials/portal_on.material")
		state = "on"
	if item_name == "portal":
		if food_eaten:
			demo.emit_signal("portal_entered")
			goat.monologue.play("another_world_awaits")
		else:
			goat.monologue.play("long_journey")


func item_used(item_name):
	if item_name == "pizza":
		food_eaten = true


func program_uploaded():
	if state == "on":
		led.material = load(
			"res://demo/materials/portal_ready.material"
		)
		state = "ready"


func remote_pressed():
	if state == "off" or state == "on":
		goat.monologue.play("upload_coords_first")
	if state == "ready":
		led.material = load(
			"res://demo/materials/portal_active.material"
		)
		# "Activate" = move the portal
		portal.translation = Vector3(0, 0, 0)
		the_other_side_sound.play()
		state = "active"
		goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)
		goat.monologue.play("finally_active")
