extends Control

const SIDE_SCREEN_MARGIN = 80

onready var viewport_container = $ViewportContainer
onready var viewport = $ViewportContainer/Viewport
onready var ray_cast = $ViewportContainer/Viewport/Inventory3D/Camera/RayCast3D
onready var camera = $ViewportContainer/Viewport/Inventory3D/Camera
onready var pivot = $ViewportContainer/Viewport/Inventory3D/Pivot
onready var hidden_pivot = $ViewportContainer/Viewport/Inventory3D/HiddenPivot
onready var inventory_items = $InventoryItems
onready var tween = $Tween

var original_mouse_position = null


func _ready():
	# Setting own_world here, otherwise 3D world will not be shown in Editor
	viewport.own_world = true
	
	goat.connect("game_mode_changed", self, "_on_game_mode_changed")
	goat_inventory.connect("item_selected", self, "_on_item_selected")
	goat_inventory.connect("item_added", self, "_on_item_added")
	goat_inventory.connect("item_removed", self, "_on_item_removed")
	goat_inventory.connect("item_replaced", self, "_on_item_replaced")
	goat_voice.connect("started", self, "_on_voice_changed")
	goat_voice.connect("finished", self, "_on_voice_changed")
	
	inventory_items.connect(
		"rotation_reset_requested", self, "_on_rotation_reset_requested"
	)
	
	_on_Inventory_resized()


func _input(event):
	if goat.game_mode != goat.GameMode.INVENTORY or goat_voice.is_playing():
		return
	
	if Input.is_action_pressed("goat_rotate_inventory"):
		var selected_item_name = goat_inventory.get_selected_item()
		if event is InputEventMouseMotion and selected_item_name:
			var selected_item = _get_item(selected_item_name)
			var mouse_sensitivity = goat_settings.get_value(
				"controls", "mouse_sensitivity"
			)
			var angle_horizontal = deg2rad(event.relative.x * mouse_sensitivity)
			var angle_vertical = deg2rad(event.relative.y * mouse_sensitivity)
			selected_item.rotate_y(angle_horizontal)
			selected_item.rotate_x(angle_vertical)
	
	if Input.is_action_just_pressed("goat_rotate_inventory"):
		_disable_mouse()
	elif Input.is_action_just_released("goat_rotate_inventory"):
		_enable_mouse()
	elif (
		Input.is_action_just_pressed("goat_toggle_inventory") or
		Input.is_action_just_pressed("goat_dismiss")
	):
		goat.game_mode = goat.GameMode.EXPLORING


func _get_item(item_name: String) -> Node:
	var item_group = "goat_inventory_item_" + item_name
	return get_tree().get_nodes_in_group(item_group).front()


func _reparent(node: Node, new_parent: Node) -> void:
	node.get_parent().remove_child(node)
	new_parent.add_child(node)


func _disable_mouse():
	original_mouse_position = get_global_mouse_position()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	goat_interaction.deselect_object(ray_cast.category)
	ray_cast.enabled = false


func _enable_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	Input.warp_mouse_position(original_mouse_position)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	ray_cast.enabled = true


func _on_game_mode_changed(new_game_mode):
	var inventory_mode = new_game_mode == goat.GameMode.INVENTORY
	ray_cast.enabled = inventory_mode
	if inventory_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		show()
	else:
		hide()


func _on_item_added(item_name):
	var added_item = goat_inventory.get_item_model(item_name).instance()
	added_item.add_to_group("goat_inventory_items")
	added_item.add_to_group("goat_inventory_item_" + item_name)
	added_item.hide()
	hidden_pivot.add_child(added_item)


func _on_item_selected(item_name):
	# Hide all items
	for item in get_tree().get_nodes_in_group("goat_inventory_items"):
		_reparent(item, hidden_pivot)
	# Item deselected, nothing to do here
	if item_name == null:
		return
	# Select the new item
	var selected_item = _get_item(item_name)
	selected_item.show()
	_reparent(selected_item, pivot)


func _on_item_removed(item_name):
	_get_item(item_name).queue_free()


func _on_item_replaced(replaced_item_name, replacing_item_name):
	# For 3D items order doesn't matter
	_on_item_added(replacing_item_name)
	_on_item_removed(replaced_item_name)


func _on_ViewportContainer_gui_input(event):
	if goat.game_mode != goat.GameMode.INVENTORY or goat_voice.is_playing():
		return
	
	# We are currently rotating the item
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		return
	
	if event is InputEventMouseMotion:
		var ray_vector = camera.project_ray_normal(event.position)
		ray_cast.cast_to = ray_vector * 4


func _on_Inventory_resized():
	# CenterContainer doesn't work correctly with ViewportContainer
	if viewport:
		var s = min(rect_size.x - 2 * SIDE_SCREEN_MARGIN, rect_size.y)
		var size = Vector2(s, s)
		viewport.size = size
		viewport_container.rect_size = size
		viewport_container.rect_position = (rect_size - size) / 2


func _on_rotation_reset_requested():
	var selected_item = pivot.get_child(0)
	tween.interpolate_property(
		selected_item, "rotation_degrees", null, Vector3(), 0.5,
		Tween.TRANS_CIRC, Tween.EASE_IN_OUT
	)
	tween.start()


func _on_voice_changed(_audio_name):
	if goat.game_mode != goat.GameMode.INVENTORY:
		return
	
	if goat_voice.is_playing():
		_disable_mouse()
	else:
		_enable_mouse()
