extends Spatial

enum Status {
	POWERED_OFF,
	POWERED_ON,
	READY_TO_ACTIVATE,
	ACTIVE
}

var status = Status.POWERED_OFF
var food_eaten = false

onready var led = $CSGTorus/LED
onready var portal = $CSGTorus/Portal
onready var the_other_side_sound = $CSGTorus/Portal/TheOtherSideSound
onready var animation_player = $AnimationPlayer


func _ready():
	goat_interaction.connect("object_activated", self, "_on_object_activated")
	goat_inventory.connect("item_used", self, "_on_item_used")
	demo.connect("program_uploaded", self, "_on_program_uploaded")
	demo.connect("remote_pressed", self, "_on_remote_pressed")


func _on_object_activated(object_name, _point):
	if object_name == "generator" and status == Status.POWERED_OFF:
		led.material = load("res://demo/materials/portal_on.material")
		status = Status.POWERED_ON
	# Portal is only available after coords are uploaded and remote is pressed
	if object_name == "portal":
		if food_eaten:
			demo.emit_signal("portal_entered")
			goat_voice.play("another_world_awaits")
		else:
			goat_voice.play("long_journey")


func _on_item_used(item_name, used_on_name):
	if item_name == "pizza" and used_on_name == "pizza":
		food_eaten = true


func _on_program_uploaded():
	if status == Status.POWERED_ON:
		led.material = load("res://demo/materials/portal_ready.material")
		status = Status.READY_TO_ACTIVATE


func _on_remote_pressed():
	if status == Status.POWERED_OFF or status == Status.POWERED_ON:
		goat_voice.play("upload_coords_first")
	if status == Status.READY_TO_ACTIVATE:
		led.material = load("res://demo/materials/portal_active.material")
		status = Status.ACTIVE
		# "Activate" = move the portal from below
		portal.translation = Vector3(0, 0, 0)
		animation_player.play("portal_light")
		the_other_side_sound.play()
		# Exit inventory mode to show that the portal is active
		goat.game_mode = goat.GameMode.EXPLORING
		goat_voice.play("finally_active")
