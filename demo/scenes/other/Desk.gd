extends Node3D

@onready var animation_player = $AnimationPlayer
@onready var floppy_insert_sound = $Model/FloppyInsertSound


func _ready():
	goat_inventory.connect("item_used", self._on_item_used)


func _on_item_used(item_name, used_on_name):
	if item_name == "floppy_disk" and used_on_name == "computer":
		if not goat_state.get_value("power_on"):
			goat_voice.start_dialogue("power_it_up_first")
			return
		goat_inventory.remove_item("floppy_disk")
		animation_player.play("insert_floppy_disk")
		floppy_insert_sound.play()
		goat_voice.prevent_default()
	if item_name == "floppy_disk" and used_on_name == "monitor":
		goat_voice.start_dialogue("floppy_on_monitor")


func _on_AnimationPlayer_animation_finished(_anim_name):
	goat_state.set_value("floppy_inserted", true)
