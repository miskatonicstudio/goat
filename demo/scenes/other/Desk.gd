extends Spatial

onready var animation_player = $AnimationPlayer
onready var floppy_insert_sound = $Desk/BottomComputer/FloppyInsertSound


func _ready():
	goat_inventory.connect("item_used", self, "_on_item_used")


func _on_item_used(item_name, used_on_name):
	if item_name == "floppy_disk" and used_on_name == "computer":
		if not demo.power_on:
			goat_voice.play("power_it_up_first")
			return
		goat_inventory.remove_item("floppy_disk")
		animation_player.play("insert_floppy_disk")
		floppy_insert_sound.play()
		goat_voice.prevent_default()


func _on_AnimationPlayer_animation_finished(_anim_name):
	demo.emit_signal("floppy_inserted")
