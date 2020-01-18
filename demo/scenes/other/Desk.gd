extends Spatial

var computer_powered_up = false

onready var monitor = $Desk/Monitor
onready var interactive_screen = $Desk/Monitor/InteractiveScreen
onready var animation_player = $AnimationPlayer
onready var sound = $Desk/BottomComputer/TopComputer/InteractiveItem/InsertSound


func _ready():
	goat_interaction.connect("object_activated", self, "_on_object_activated")
	goat_inventory.connect("item_used", self, "_on_item_used")


func _on_object_activated(object_name, _point):
	if object_name == "generator":
		# Set computer screen's material (surface: 1)
		monitor.set_surface_material(
			1, load("res://demo/materials/computer_screen_on.material")
		)
		computer_powered_up = true


func _on_item_used(item_name, used_on_name):
	if item_name == "floppy_disk" and used_on_name == "computer":
		if not computer_powered_up:
			goat_voice.play("power_it_up_first")
			return
		if interactive_screen.visible:
			return
		goat_inventory.remove_item("floppy_disk")
		animation_player.play("insert_floppy_disk")
		sound.play()
		goat_voice.prevent_default()


func _on_AnimationPlayer_animation_finished(_anim_name):
	interactive_screen.show()
	demo.emit_signal("program_activated")
