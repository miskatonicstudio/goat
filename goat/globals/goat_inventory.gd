class_name GoatInventory
extends Node

"""
Stores GOAT inventory items. Each item is represented by a unique name.
"""

# Only one item can be selected at the time
signal item_selected (item_name)
signal item_added (item_name)
signal item_removed (item_name)
signal item_replaced (replaced_item_name, replacing_item_name)
signal item_used (item_name, used_on_name)
# Emitted every time there is a change in inventory items
signal items_changed (new_items)

const CAPACITY := 8

var _items := []
var _selected_item = null
# Item names with corresponding icons and models
var _config := {}


func register_item(item_name: String) -> void:
	"""
	Adds an item to configuration, allowing it to be used in inventory scenes.
	This method should be called once for every inventory item, and the items
	should be configured once per game (not once per scene), since inventory
	is kept between different scenes.
	"""
	assert(not _config.has(item_name))
	
	var icon_path := "res://{}/inventory_items/icons/{}.png".format(
		[goat.GAME_RESOURCES_DIRECTORY, item_name], "{}"
	)
	# Comply with Godot scene naming standards
	var model_name := item_name.capitalize().replace(" ", "")
	var model_path := "res://{}/inventory_items/models/{}.tscn".format(
		[goat.GAME_RESOURCES_DIRECTORY, model_name], "{}"
	)
	
	# Do not load models yet, just keep the paths
	_config[item_name] = {
		"icon_path": icon_path,
		"model": model_path,
	}


func get_item_icon(item_name: String):
	"""Returns an icon (image) associated with the given item"""
	var icon = _config[item_name].get("icon")
	
	# If an icon was created earlier, use it
	if icon:
		return icon
	
	var icon_path = _config[item_name]["icon_path"]
	
	if File.new().file_exists(icon_path):
		# If an icon file was provided, use it
		icon = load(icon_path)
	else:
		# Otherwise create an icon using the model
		var icon_maker = load(
			"res://goat/helper_scenes/IconMaker.tscn"
		).instance()
		get_tree().root.add_child(icon_maker)
		icon = icon_maker.make_icon_texture(_config[item_name]["model"])
	
	_config[item_name]["icon"] = icon
	return icon


func get_item_model(item_name: String):
	"""Returns a 3D model (scene) associated with the given item"""
	return load(_config[item_name]["model"])


func reset() -> void:
	"""Clears inventory items, but keeps the configuration"""
	_items.clear()
	_selected_item = null


func get_items() -> Array:
	"""Returns all items as an array (order matters)"""
	return _items.duplicate()


func get_selected_item() -> String:
	"""Returns currrently selected item (can be null)"""
	return _selected_item


func select_item(item_name) -> void:
	"""
	Selects an item. The item has to be in the inventory. Null value is also
	accepted, if no item should be selected, e.g. if there are no items in the
	inventory. If the new item is different than the old one, sends a signal.
	"""
	assert (item_name == null or item_name in _items)
	if _selected_item != item_name:
		_selected_item = item_name
		emit_signal("item_selected", item_name)


func add_item(item_name: String) -> void:
	"""
	Adds an item to inventory, if there is enough space for it. Doesn't select
	an item (this is done by inventory, when it is first opened).
	"""
	assert (len(_items) < CAPACITY)
	_items.append(item_name)
	emit_signal("item_added", item_name)
	emit_signal("items_changed", _items)


func remove_item(item_name: String) -> void:
	"""Removes an item from inventory"""
	assert (item_name in _items)
	var item_index = _items.find(item_name)
	_items.erase(item_name)
	emit_signal("item_removed", item_name)
	emit_signal("items_changed", _items)
	# If selected item was removed, we need a new one
	if item_name == _selected_item:
		# If there are other items, select one of them
		if not _items.empty():
			if item_index >= len(_items):
				item_index -= 1
			select_item(_items[item_index])
		# Otherwise no item is selected
		else:
			select_item(null)


func replace_item(replaced_item_name: String, replacing_item_name: String):
	"""Replaces one item with another"""
	assert (replaced_item_name in _items)
	assert (not replacing_item_name in _items)
	
	var item_index = _items.find(replaced_item_name)
	_items[item_index] = replacing_item_name
	emit_signal("item_replaced", replaced_item_name, replacing_item_name)
	emit_signal("items_changed", _items)
	if replaced_item_name == _selected_item:
		select_item(replacing_item_name)


func use_item(item_name: String, used_on_name=null) -> void:
	"""
	Uses an item on another one. Doesn't change anything in the inventory, just
	emits signals. Both items can have the same value, which represents a
	situation of using an item on itself or just using an item
	(e.g. eating a pizza or unwrapping a package). If used_on_name is null,
	it will be set to item_name before signals are emitted.
	"""
	assert (item_name in _items)
	assert (item_name != null)
	
	if used_on_name == null:
		used_on_name = item_name
	
	emit_signal("item_used", item_name, used_on_name)
