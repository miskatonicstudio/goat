extends Control

const CAPACITY = 8

var INVENTORY_BUTTON_STYLE_NORMAL = load("res://goat/styles/inventory_slot_normal.tres")
var INVENTORY_BUTTON_STYLE_HOVER = load("res://goat/styles/inventory_slot_hover.tres")
var INVENTORY_BUTTON_STYLE_FOCUS = load("res://goat/styles/inventory_slot_focus.tres")

var number_of_items = 0
var currently_selected_item = null
var currently_dragged_item = null
var item_button_group = ButtonGroup.new()

onready var top_bar = $TopBar
onready var item_button_container = $TopBar


func _ready():
	goat.connect("inventory_item_obtained", self, "item_obtained")
	goat.connect("inventory_item_selected", self, "item_selected")
	goat.connect("inventory_item_removed", self, "item_removed")
	goat.connect("inventory_item_replaced", self, "item_replaced")
	
	# Clear temp inventory slots
	while item_button_container.get_child_count():
		var button = item_button_container.get_children().pop_back()
		item_button_container.remove_child(button)
		button.queue_free()
	
	# Add proper inventory slots
	adjust_buttons()


func _input(event):
	if currently_dragged_item and Input.is_action_just_released("goat_drag_inventory"):
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
		if (
			event is InputEventMouse and
			not top_bar.get_global_rect().has_point(event.global_position) and
			currently_dragged_item != currently_selected_item
		):
			goat.emit_signal(
				"inventory_item_used_on_inventory", currently_dragged_item, currently_selected_item
			)
			goat.emit_signal(
				"inventory_item_{}_used_on_inventory_{}".format(
					[currently_dragged_item, currently_selected_item], "{}"
				)
			)
		currently_dragged_item = null


func item_obtained(item_name):
	# Game developers should ensure this never happens
	if number_of_items >= CAPACITY:
		return
	
	add_item_button(item_name)
	adjust_buttons()
	number_of_items += 1
	
	if not currently_selected_item:
		goat.emit_signal("inventory_item_selected", item_name)
		goat.emit_signal("inventory_item_selected_" + item_name)


func item_selected(item_name):
	if currently_selected_item == null:
		var item_button = get_tree().get_nodes_in_group(
			"goat_inventory_item_button_" + item_name
		).pop_front()
		item_button.pressed = true
	currently_selected_item = item_name


func item_removed(item_name):
	var removed_item = get_tree().get_nodes_in_group(
		"goat_inventory_item_button_" + item_name
	).pop_front()
	var index = removed_item.get_index()
	
	item_button_container.remove_child(removed_item)
	removed_item.queue_free()
	number_of_items -= 1
	
	adjust_buttons()
	
	# Select a new item if the current one was removed
	if item_name == currently_selected_item:
		currently_selected_item = null
		if number_of_items > 0:
			if index >= number_of_items:
				index = index - 1
			var new_item_name = item_button_container.get_children()[index].get_meta("item_name")
			goat.emit_signal("inventory_item_selected", new_item_name)
			goat.emit_signal("inventory_item_selected_" + new_item_name)


func item_replaced(item_name_replaced, item_name_replacing):
	var replaced_item = get_tree().get_nodes_in_group(
		"goat_inventory_item_button_" + item_name_replaced
	).pop_front()
	
	var insert_position = replaced_item.get_index()
	add_item_button(item_name_replacing, insert_position)
	item_button_container.remove_child(replaced_item)
	replaced_item.queue_free()
	if currently_selected_item == item_name_replaced:
		currently_selected_item = null
		goat.emit_signal("inventory_item_selected", item_name_replacing)
		goat.emit_signal("inventory_item_selected_" + item_name_replacing)


func item_button_pressed(item_name):
	if item_name != currently_selected_item:
		goat.emit_signal("inventory_item_selected", item_name)
		goat.emit_signal("inventory_item_selected_" + item_name)


func item_button_down(item_name):
	currently_dragged_item = item_name
	var texture = goat.inventory_items_textures[item_name]
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, Vector2(32, 32))


func _on_UseButton_pressed():
	goat.emit_signal("inventory_item_used", currently_selected_item)
	goat.emit_signal("inventory_item_used_" + currently_selected_item)


func _on_BackButton_pressed():
	goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)


func add_item_button(item_name=null, insert_position=null):
	if insert_position == null:
		insert_position = number_of_items
	
	var item_button = Button.new()
	# Account for 2x2 pixel frame and 64x64 pixel icon
	item_button.rect_min_size = Vector2(68, 68)
	item_button.toggle_mode = true
	item_button.focus_mode = Control.FOCUS_NONE
	item_button.group = item_button_group
	
	item_button.set("custom_styles/pressed", INVENTORY_BUTTON_STYLE_FOCUS)
	item_button.set("custom_styles/normal", INVENTORY_BUTTON_STYLE_NORMAL)
	item_button.set("custom_styles/hover", INVENTORY_BUTTON_STYLE_HOVER)
	item_button.set("custom_styles/disabled", INVENTORY_BUTTON_STYLE_NORMAL)
	item_button.set_meta("item_name", item_name)
	
	if item_name:
		item_button.icon = goat.inventory_items_textures[item_name]
		item_button.connect("pressed", self, "item_button_pressed", [item_name, ])
		item_button.connect("button_down", self, "item_button_down", [item_name, ])
		item_button.add_to_group("goat_inventory_item_button_" + item_name)
	else:
		item_button.disabled = true
	
	item_button_container.add_child(item_button)
	item_button_container.move_child(item_button, insert_position)


func adjust_buttons():
	# Add buttons if there are some missing
	while item_button_container.get_child_count() < CAPACITY:
		add_item_button()
	# Get rid of excess items
	while item_button_container.get_child_count() > CAPACITY:
		var last_button = item_button_container.get_children().pop_back()
		item_button_container.remove_child(last_button)
		last_button.queue_free()
