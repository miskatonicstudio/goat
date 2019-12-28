extends Spatial

# State: off, on, ready, active
var state = "off"
onready var led = $CSGTorus/LED


func _ready():
	goat.connect("interactive_item_activated", self, "item_activated")
	demo.connect("program_uploaded", self, "program_uploaded")
	demo.connect("remote_pressed", self, "remote_pressed")


func item_activated(item_name, _position):
	if item_name == "generator" and state == "off":
		led.material = load("res://demo/workshop/materials/portal_on.material")
		state = "on"


func program_uploaded():
	if state == "on":
		led.material = load("res://demo/workshop/materials/portal_ready.material")
		state = "ready"


func remote_pressed():
	if state == "ready":
		led.material = load("res://demo/workshop/materials/portal_active.material")
		state = "active"
