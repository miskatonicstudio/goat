extends Spatial

var computer_powered_up = false

onready var animation_player = $AnimationPlayer
onready var insert_sound = $Desk/BottomComputer/InsertSound


func _ready():
	demo.connect("generator_activated", self, "_on_generator_activated")
	goat_inventory.connect("item_used", self, "_on_item_used")


func _on_generator_activated():
	computer_powered_up = true


func _on_item_used(item_name, used_on_name):
	if item_name == "floppy_disk" and used_on_name == "computer":
		if not computer_powered_up:
			goat_voice.play("power_it_up_first")
			return
		goat_inventory.remove_item("floppy_disk")
		animation_player.play("insert_floppy_disk")
		insert_sound.play()
		goat_voice.prevent_default()


func _on_AnimationPlayer_animation_finished(_anim_name):
	demo.emit_signal("program_activated")
