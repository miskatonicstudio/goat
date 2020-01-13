extends Spatial

onready var animation_player = $AnimationPlayer


func _ready():
	goat.connect("interactive_item_activated", self, "item_activated")


func item_activated(item_name, _position):
	if item_name == "floppy_shutter":
		goat_voice.prevent_default()
		if not animation_player.is_playing():
			animation_player.play("move_shutter")
