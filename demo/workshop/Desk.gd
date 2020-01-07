extends Spatial

var computer_powered_up = false


func _ready():
	goat.connect("interactive_item_activated", self, "item_activated")
	goat.connect("inventory_item_used_on_environment", self, "item_used_on_environment")


func item_activated(item_name, _position):
	if item_name == "generator":
		var computer_screen_on = load(
			"res://demo/workshop/materials/computer_screen_on.material"
		)
		# Set computer screen's material (surface: 1)
		$Desk/Monitor.set_surface_material(1, computer_screen_on)
		computer_powered_up = true


func item_used_on_environment(inventory_item, environment_item):
	if inventory_item == "floppy_disk" and environment_item == "computer":
		if not computer_powered_up:
			return
		if $Desk/Monitor/InteractiveScreen.visible:
			return
		# Play an empty monologue to prevent playing the default
		goat.monologue.play()
		$Desk/BottomComputer/TopComputer/InteractiveItem/AudioStreamPlayer3D.play()
		$AnimationPlayer.play("insert_floppy_disk")
		goat.emit_signal("inventory_item_removed", "floppy_disk")


func _on_AnimationPlayer_animation_finished(_anim_name):
	$Desk/Monitor/InteractiveScreen.show()
	demo.emit_signal("program_activated")
