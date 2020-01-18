tool
class_name InteractiveItem
extends StaticBody

"""
Represents a simple interactive object, e.g. a switch on a wall or a lever.
There are 3 types of items:
	* normal (can be used multiple times, e.g. a switch)
	* single use (can be used only once, e.g. a mirror that falls into pieces)
	* inventory (activating will remove it and add an inventory item)
"""

enum ItemType {
	NORMAL,
	SINGLE_USE,
	INVENTORY,
}

export (String) var unique_name
export (ItemType) var item_type = ItemType.NORMAL
# This will only be used by items with type INVENTORY
export (String) var inventory_item_name
export (Shape) var collision_shape = BoxShape.new() setget set_collision_shape
export (AudioStream) var sound = null setget set_sound

onready var interaction_icon = $InteractionIcon
onready var audio_player = $AudioPlayer
onready var collision_shape_node = $CollisionShape


func _ready():
	# This would make it easier to find the item
	add_to_group("goat_interactive_object_" + unique_name)
	collision_shape_node.shape = collision_shape
	audio_player.stream = sound
	
	goat_interaction.connect("object_selected", self, "_on_object_selected")
	goat_interaction.connect("object_deselected", self, "_on_object_deselected")
	goat_interaction.connect("object_activated", self, "_on_object_activated")
	goat_interaction.connect(
		"object_activated_alternatively", self,
		"_on_object_activated_alternatively"
	)


func set_collision_shape(new_shape):
	collision_shape = new_shape
	if is_inside_tree():
		collision_shape_node.shape = collision_shape


func set_sound(new_sound):
	sound = new_sound
	# Disable sound loop
	if sound is AudioStreamSample:
		sound.loop_mode = AudioStreamSample.LOOP_DISABLED
	elif sound is AudioStreamOGGVorbis:
		sound.loop = false
	if is_inside_tree():
		audio_player.stream = sound


func _on_object_selected(object_naem, _point):
	if object_naem == unique_name:
		interaction_icon.show()


func _on_object_deselected(object_name):
	if object_name == unique_name:
		interaction_icon.hide()


func _on_object_activated(object_name, _point):
	if object_name != unique_name:
		return
	
	if not collision_layer:
		return
	
	# Items other than NORMAL can only be used once
	if item_type != ItemType.NORMAL:
		collision_layer = 0
		collision_mask = 0
	
	_play_sound()
	
	if item_type == ItemType.INVENTORY:
		# INVENTORY items should not play default audio
		goat_voice.prevent_default()
		goat_inventory.add_item(inventory_item_name)
		# Hide the item, but keep it until the sound is played
		hide()


func _on_object_activated_alternatively(object_name, _point):
	if object_name != unique_name:
		return
	
	# Inventory items don't show context inventory, instead they are picked up
	if item_type == ItemType.INVENTORY:
		_on_object_activated(object_name, _point)
	else:
		goat.game_mode = goat.GameMode.CONTEXT_INVENTORY


func _play_sound():
	if audio_player.stream:
		audio_player.play()
	else:
		# Make sure that "after sound" logic is executed
		_remove_if_inventory_item()


func _on_AudioPlayer_finished():
	_remove_if_inventory_item()


func _remove_if_inventory_item():
	if item_type == ItemType.INVENTORY:
		get_parent().remove_child(self)
		call_deferred("queue_free")
