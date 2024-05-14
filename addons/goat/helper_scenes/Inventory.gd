extends Control

const SIDE_SCREEN_MARGIN = 80

@onready var viewport_container = $SubViewportContainer
@onready var viewport = $SubViewportContainer/SubViewport
@onready var ray_cast = $SubViewportContainer/SubViewport/Inventory3D/Camera3D/RayCast3D
@onready var camera = $SubViewportContainer/SubViewport/Inventory3D/Camera3D
@onready var pivot = $SubViewportContainer/SubViewport/Inventory3D/Pivot
@onready var hidden_pivot = $SubViewportContainer/SubViewport/Inventory3D/HiddenPivot
@onready var inventory_items = $InventoryItems

var original_mouse_position = null


func _ready():
	# Setting own_world here, otherwise 3D world will not be shown in Editor
	viewport.own_world_3d = true
	
	goat.connect("game_mode_changed", self._on_game_mode_changed)
	goat_inventory.connect("item_selected", self._on_item_selected)
	goat_inventory.connect("item_added", self._on_item_added)
	goat_inventory.connect("item_removed", self._on_item_removed)
	goat_inventory.connect("item_replaced", self._on_item_replaced)
	goat_voice.connect("started", self._on_voice_changed)
	goat_voice.connect("finished", self._on_voice_changed)
	
	inventory_items.connect(
		"rotation_reset_requested", self._on_rotation_reset_requested
	)
	_initialize_inventory_items()


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
			var angle_horizontal = deg_to_rad(event.relative.x * mouse_sensitivity)
			var angle_vertical = deg_to_rad(event.relative.y * mouse_sensitivity)
			selected_item.rotate_y(angle_horizontal)
			selected_item.rotate_x(angle_vertical)
			goat_inventory._config[selected_item_name]["transform"] = selected_item.transform
	
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
	Input.warp_mouse(original_mouse_position)
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


func _initialize_inventory_items():
	for item_name in goat_inventory.get_items():
		_on_item_added(item_name)
	
	_on_item_selected(goat_inventory.get_selected_item())


func _on_item_added(item_name):
	var added_item = goat_inventory.get_item_model(item_name).instantiate()
	added_item.add_to_group("goat_inventory_items")
	added_item.add_to_group("goat_inventory_item_" + item_name)
	added_item.hide()
	hidden_pivot.add_child(added_item)
	added_item.transform = goat_inventory._config[item_name]["transform"]


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
		ray_cast.target_position = ray_vector * 4


func _on_rotation_reset_requested():
	var selected_item = pivot.get_child(0)
	var tween = _create_tween()
	tween.tween_property(selected_item, "rotation_degrees", Vector3(), 0.5)


func _on_voice_changed(_audio_name):
	if goat.game_mode != goat.GameMode.INVENTORY:
		return
	
	if goat_voice.is_playing():
		_disable_mouse()
	else:
		_enable_mouse()


func _create_tween():
	return create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
