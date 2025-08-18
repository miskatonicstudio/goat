@tool
extends Control


func _ready() -> void:
	refresh_items()


func refresh_items():
	var items = ProjectSettings.get_setting("goat/inventory/items", [])
	%ItemList.clear()
	for item in items:
		var item_name = item.get_file().get_basename()
		%ItemList.add_item(item_name)


func _on_item_list_visibility_changed() -> void:
	refresh_items()


func _on_item_list_item_selected(index: int) -> void:
	var item_scene_path = ProjectSettings.get_setting("goat/inventory/items", [])[index]
	if %Pivot.get_child_count() > 0:
		var current_item_scene = %Pivot.get_child(0)
		%Pivot.remove_child(current_item_scene)
		current_item_scene.queue_free()
	var new_item_scene = load(item_scene_path).instantiate()
	%Pivot.rotation = Vector3(0, 0, 0)
	%Pivot.add_child(new_item_scene)


func _on_sub_viewport_container_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and event.button_mask:
		var angle_horizontal = deg_to_rad(event.relative.x)
		var angle_vertical = deg_to_rad(event.relative.y)
		%Pivot.rotate_y(angle_horizontal)
		%Pivot.rotate_x(angle_vertical)
