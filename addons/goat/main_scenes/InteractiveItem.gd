@tool
extends StaticBody3D

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
	HAND,
	DIALOGUE,
}

@export var unique_name: String
@export var item_type : ItemType = ItemType.NORMAL
# This will only be used by items with type INVENTORY
@export var inventory_item_name : String
@export var collision_shape : Shape3D = BoxShape3D.new(): set = set_collision_shape
@export var sounds : Array[AudioStream] : set = set_sounds

@onready var interaction_icon = $InteractionIcon
@onready var random_audio_player = $RandomAudioPlayer
@onready var collision_shape_node = $CollisionShape3D

const COLLISION_MASK_LAYER = 2

var _orig_cast_shadow_settings = {}

func _ready():
	if ("_activated_" + unique_name) in goat_state._variables and item_type == ItemType.INVENTORY:
		queue_free()
		return
	
	if ("_put_down_" + unique_name) in goat_state._variables and item_type == ItemType.HAND:
		global_transform = goat_state.get_value("_put_down_" + unique_name)
	
	# This would make it easier to find the item
	add_to_group("goat_interactive_object_" + unique_name)
	collision_shape_node.shape = collision_shape
	random_audio_player.streams = sounds
	
	goat_interaction.connect("object_selected", self._on_object_selected)
	goat_interaction.connect("object_deselected", self._on_object_deselected)
	goat_interaction.connect("object_activated", self._on_object_activated)
	goat_interaction.connect("object_disabled", self._on_object_disabled)
	goat_interaction.connect("object_enabled", self._on_object_enabled)
	goat_interaction.connect(
		"object_activated_alternatively", self._on_object_activated_alternatively
	)
	# Store original `cast_shadow` settings of all geometry instances
	for child in get_children():
		if is_instance_of(child, GeometryInstance3D):
			_orig_cast_shadow_settings[child] = child.cast_shadow


func set_collision_shape(new_shape):
	collision_shape = new_shape
	if is_inside_tree():
		collision_shape_node.shape = collision_shape


func set_sounds(new_sounds):
	sounds = new_sounds
	# Disable sound loop
	for sound in sounds:
		if sound is AudioStreamWAV:
			sound.loop_mode = AudioStreamWAV.LOOP_DISABLED
		elif sound is AudioStreamOggVorbis:
			sound.loop = false
	if is_inside_tree():
		random_audio_player.stream = sounds


func _on_object_selected(object_name, _point):
	if object_name == unique_name:
		interaction_icon.show()


func _on_object_deselected(object_name):
	if object_name == unique_name:
		interaction_icon.hide()


func _on_object_activated(object_name, _point):
	if object_name != unique_name:
		return
	
	if item_type == ItemType.DIALOGUE:
#		# TODO: use a dedicated field for this
		goat_voice.start_dialogue(inventory_item_name)
		return
	
	# Items other than NORMAL can only be used once
	if item_type != ItemType.NORMAL:
		_set_enabled(false)
	
	_play_sound()
	
	if item_type == ItemType.INVENTORY:
		# INVENTORY items should not play default audio
		goat_voice.prevent_default()
		goat_inventory.add_item(inventory_item_name)
		goat_state._register_variable("_activated_" + unique_name, true)
		# Hide the item, but keep it until the sound is played
		hide()
	elif item_type == ItemType.HAND:
		goat_voice.prevent_default()
		_pick_up()


func _on_object_activated_alternatively(object_name, _point):
	if object_name != unique_name:
		return
	
	# Inventory items don't show context inventory, instead they are picked up
	if item_type == ItemType.INVENTORY:
		_on_object_activated(object_name, _point)
	else:
		goat.game_mode = goat.GameMode.CONTEXT_INVENTORY


func _on_object_enabled(object_name):
	if object_name != unique_name:
		return
	
	_set_enabled(true)


func _on_object_disabled(object_name):
	if object_name != unique_name:
		return
	
	_set_enabled(false)


func _play_sound():
	if random_audio_player.streams:
		random_audio_player.play()
	else:
		# Make sure that "after sound" logic is executed
		_remove_if_inventory_item()


func _on_RandomAudioPlayer_finished():
	_remove_if_inventory_item()


func _remove_if_inventory_item():
	if item_type == ItemType.INVENTORY:
		get_parent().remove_child(self)
		call_deferred("queue_free")


func _set_enabled(enabled):
	if enabled:
		collision_layer = COLLISION_MASK_LAYER
		collision_mask = COLLISION_MASK_LAYER
		add_to_group("goat_interactive_objects")
	else:
		collision_layer = 0
		collision_mask = 0
		remove_from_group("goat_interactive_objects")
		interaction_icon.hide()


func _pick_up():
	var hand = get_tree().get_nodes_in_group("goat_player_hand")[0]
	var orig_transform = global_transform
	
	get_parent().remove_child(self)
	hand.add_child(self)
	
	var tween = create_tween()
	tween.tween_property(self, "global_transform", orig_transform, 0)
	tween.tween_property(self, "global_transform", hand.global_transform, 0.2)
	tween.tween_callback(self._put_in_hand)
	
	# Force raycast update
	goat.game_mode = goat.GameMode.EXPLORING


func _put_in_hand():
	"""
	Player can move while an item is placed in its hand. This method ensures that,
	at the end of interpolation, the item will end up exacly at the hand's position.
	"""
	_set_cast_shadow(false)
	var hand = get_tree().get_nodes_in_group("goat_player_hand")[0]
	global_transform = hand.global_transform


func _put_down(surface: Node3D, global_point: Vector3):
	"""
	Removes this item from Player's hand and places it in the `global_point`,
	as a child of `surface`.
	"""
	_set_cast_shadow(true)
	var hand = get_tree().get_nodes_in_group("goat_player_hand")[0]
	assert(self.item_type == self.ItemType.HAND)
	assert(get_parent() == hand)
	
	# Create a temp node, to easily read final position and rotation
	var temp_node = Node3D.new()
	surface.add_child(temp_node)
	temp_node.position = surface.to_local(global_point)
	temp_node.global_rotation = Vector3(0, hand.global_rotation.y, 0)
	var dest_position = temp_node.global_position
	var dest_rotation = temp_node.global_rotation
	var dest_scale = Vector3(1, 1, 1)
	# Store the location where this item was placed
	goat_state._register_variable("_put_down_" + unique_name, temp_node.global_transform)
	temp_node.queue_free()
	
	var orig_transform = global_transform
	hand.remove_child(self)
	surface.add_child(self)
	
	var tween = create_tween()
	# Item has a new parent, but the interpolation should start from the same global point
	tween.tween_property(self, "global_transform", orig_transform, 0)
	# Interpolate rotation and position rather than global_transform, for smooth movement
	tween.tween_property(self, "global_rotation", dest_rotation, 0)
	tween.tween_property(self, "global_position", dest_position, 0.2)
	# Activate the item once it is placed on the surface
	tween.tween_callback(self._set_enabled.bind(true))
	
	# Scale has to be interpolated simultaneously
	var tween_scale = create_tween()
	tween_scale.tween_property(self, "scale", hand.scale, 0)
	tween_scale.tween_property(self, "scale", dest_scale, 0.2)
	
	# Force raycast update
	goat.game_mode = goat.GameMode.EXPLORING


func _set_cast_shadow(enabled: bool):
	for child in _orig_cast_shadow_settings.keys():
		if enabled:
			# Restore the original `cast_shadow` value
			child.cast_shadow = _orig_cast_shadow_settings[child]
		else:
			child.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
