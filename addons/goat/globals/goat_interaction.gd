extends Node

"""
Handles interactive objects logic. Objects in front of the player and in range
are selected. A selected object can be activated. A point at which the
interaction takes place is also stored and sent with proper signals. That
information is not relevant to e.g. a light switch, but can be used for 3D
interactive screens.

Moreover, objects can be assigned to a category. Each category can hold only
one currently selected object.
"""

signal object_selected (object_name, point)
signal object_deselected (object_name)
signal object_activated (object_name, point)
signal object_activated_alternatively (object_name, point)
signal object_enabled (object_name)
signal object_disabled (object_name)

# Stores selected objects and corresponding points in each category
var _selected = {}


func get_selected_object(category: String):
	"""
	Returns the name of the currently selected object in given category.
	If no object is currently selected, returns null.
	"""
	return _get_selected_by_key(category, "object")


func get_selected_point(category: String):
	"""
	Returns the point of interaction with the currently selected object in given
	category. If no object is currently selected, returns null.
	"""
	return _get_selected_by_key(category, "point")


func select_object(object_name: String, point: Vector3, category: String):
	"""
	Marks the object as currently selected in given category, storing its name
	and the point of interaction. If another object is currently selected,
	deselects it first and sends a proper signal.
	"""
	assert (object_name != null)
	
	var current_object = get_selected_object(category)
	var current_point = get_selected_point(category)
	# Deselect current object if necessary
	if current_object and current_object != object_name:
		deselect_object(category)
	# Do not send the signal if neither the object nor the point changed
	if current_point == point:
		return
	_selected[category] = {
		"object": object_name,
		"point": point
	}
	emit_signal("object_selected", object_name, point)


func deselect_object(category: String):
	"""If there is an object selected in given category, deselects it"""
	var current_object = get_selected_object(category)
	if current_object:
		_selected.erase(category)
		emit_signal("object_deselected", current_object)


func activate_object(category: String):
	var current_object = get_selected_object(category)
	if current_object:
		var point = get_selected_point(category)
		emit_signal("object_activated", current_object, point)


func alternatively_activate_object(category: String):
	var current_object = get_selected_object(category)
	if current_object:
		var point = get_selected_point(category)
		emit_signal("object_activated_alternatively", current_object, point)


func enable_object(object_name):
	emit_signal("object_enabled", object_name)


func disable_object(object_name):
	emit_signal("object_disabled", object_name)


func _get_selected_by_key(category: String, key: String):
	assert (category != null)
	if _selected.has(category):
		return _selected[category][key]
	else:
		return null
