extends Control

onready var top_bar = $ScrollContainer
onready var item_container = $ScrollContainer/CenterContainer/HBoxContainer

var currently_selected_item = null
var currently_dragged_item = null


func _ready():
	goat.connect("oat_environment_item_obtained", self, "item_obtained")
	goat.connect("oat_inventory_item_selected", self, "item_selected")
	goat.connect("oat_inventory_item_removed", self, "item_removed")
	goat.connect("oat_inventory_item_replaced", self, "item_replaced")


func _input(event):
	if currently_dragged_item and Input.is_action_just_released("oat_inventory_item_dragging"):
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
		if (
			event is InputEventMouse and
			not top_bar.get_global_rect().has_point(event.global_position) and
			currently_dragged_item != currently_selected_item
		):
			goat.emit_signal(
				"oat_inventory_item_used_on_inventory", currently_dragged_item, currently_selected_item
			)
		currently_dragged_item = null


func item_obtained(item_name, insert_after=null):
	var item_button = TextureButton.new()
	item_button.texture_normal = goat.inventory_items_textures[item_name]
	item_button.connect("pressed", self, "item_button_pressed", [item_name, ])
	item_button.connect("button_down", self, "item_button_down", [item_name, ])
	item_button.add_to_group("oat_inventory_item_icon_" + item_name)
	
	if insert_after:
		item_container.add_child_below_node(insert_after, item_button)
	else:
		item_container.add_child(item_button)
	
	if not currently_selected_item:
		goat.emit_signal("oat_inventory_item_selected", item_name)


func item_selected(item_name):
	currently_selected_item = item_name


func item_removed(item_name):
	var removed_item = get_tree().get_nodes_in_group("oat_inventory_item_icon_" + item_name).pop_front()
	
	if item_name == currently_selected_item:
		var index = removed_item.get_index()
		# TODO: handle empty inventory case!
		if index + 1 < item_container.get_child_count():
			index = index + 1
		else:
			index = index - 1
		item_container.get_children()[index].emit_signal("pressed")
	removed_item.queue_free()


func item_replaced(item_name_replaced, item_name_replacing):
	var replaced_item = get_tree().get_nodes_in_group("oat_inventory_item_icon_" + item_name_replaced).pop_front()
	item_obtained(item_name_replacing, replaced_item)
	replaced_item.queue_free()
	goat.emit_signal("oat_inventory_item_selected", item_name_replacing)


func item_button_pressed(item_name):
	if item_name != currently_selected_item:
		goat.emit_signal("oat_inventory_item_selected", item_name)


func item_button_down(item_name):
	currently_dragged_item = item_name
	var texture = goat.inventory_items_textures[item_name]
	# TODO: read texture size from config
	# TODO: use settings signals for setting cursor?
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, Vector2(32, 32))


func _on_UseButton_pressed():
	goat.emit_signal("oat_inventory_item_used", currently_selected_item)
