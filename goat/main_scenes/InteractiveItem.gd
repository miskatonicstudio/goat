tool
extends StaticBody

const ITEM_MODE_NORMAL = 0
const ITEM_MODE_SINGLE_USE = 1
const ITEM_MODE_INVENTORY = 2

enum ItemMode {
	ITEM_MODE_NORMAL,
	ITEM_MODE_SINGLE_USE,
	ITEM_MODE_INVENTORY,
}

export (String) var unique_name
export (String) var inventory_item_name
export (ItemMode) var item_mode = ITEM_MODE_NORMAL
export (Shape) var collision_shape = BoxShape.new() setget set_collision_shape
export (AudioStream) var sound = null setget set_sound

onready var icon_interact = $IconInteract
onready var player = $Player


func _ready():
	add_to_group("goat_interactive_item_" + unique_name)
	goat.register_unique_name(unique_name)
	if inventory_item_name:
		goat.register_unique_name(inventory_item_name)
	$CollisionShape.shape = collision_shape
	player.stream = sound
	
	# warning-ignore:return_value_discarded
	goat.connect("interactive_item_selected", self, "select")
	# warning-ignore:return_value_discarded
	goat.connect("interactive_item_deselected", self, "deselect")
	# warning-ignore:return_value_discarded
	goat.connect("interactive_item_activated", self, "activate")


func set_collision_shape(new_shape):
	collision_shape = new_shape
	if is_inside_tree():
		$CollisionShape.shape = collision_shape


func set_sound(new_sound):
	sound = new_sound
	# Disable sound loop
	if sound is AudioStreamSample:
		sound.loop_mode = AudioStreamSample.LOOP_DISABLED
	elif sound is AudioStreamOGGVorbis:
		sound.loop = false
	if is_inside_tree():
		player.stream = sound


func select(item_name, _position):
	if item_name == unique_name:
		icon_interact.show()


func deselect(item_name):
	if item_name == unique_name:
		icon_interact.hide()


func activate(item_name, _position):
	if item_name != unique_name:
		return
	play_sound()
	# Disable collision detection
	if item_mode != ITEM_MODE_NORMAL:
		collision_layer = 0
	if item_mode == ITEM_MODE_INVENTORY:
		goat.emit_signal("inventory_item_obtained", inventory_item_name)
		goat.emit_signal("inventory_item_obtained_" + inventory_item_name)
		# Hide the item, but keep it until the sound is played
		hide()


func play_sound():
	if player.stream:
		player.play()
	else:
		# Make sure that "after sound" logic is executed
		_on_Player_finished()


func remove():
	get_parent().remove_child(self)
	call_deferred("queue_free")


func _on_Player_finished():
	# Remove the entire item, if it was obtained
	if item_mode == ITEM_MODE_INVENTORY:
		remove()


func is_inventory_item():
	return item_mode == ITEM_MODE_INVENTORY
