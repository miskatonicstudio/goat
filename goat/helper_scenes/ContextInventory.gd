extends Control

const CAPACITY = 8

var INVENTORY_BUTTON_STYLE_NORMAL = load("res://goat/styles/inventory_slot_normal.tres")
var INVENTORY_BUTTON_STYLE_HOVER = load("res://goat/styles/inventory_slot_hover.tres")
var INVENTORY_BUTTON_STYLE_FOCUS = load("res://goat/styles/inventory_slot_focus.tres")

var number_of_items = 0
var environment_item_name = null

onready var item_button_container = $CenterContainer/Center


func _ready():
	goat.connect("game_mode_changed", self, "game_mode_changed")
	goat.connect("interactive_item_selected", self, "interactive_item_selected")
	goat.connect("interactive_item_deselected", self, "interactive_item_deselected")
	goat.connect("inventory_item_obtained", self, "item_obtained")
	goat.connect("inventory_item_removed", self, "item_removed")
	goat.connect("inventory_item_replaced", self, "item_replaced")
	
	while item_button_container.get_child_count() > 0:
		var button = item_button_container.get_children().pop_back()
		item_button_container.remove_child(button)
		button.queue_free()
	
	adjust_buttons()


func game_mode_changed(new_game_mode):
	if new_game_mode == goat.GAME_MODE_CONTEXT_INVENTORY:
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
		show()
	else:
		hide()


func interactive_item_selected(item_name):
	if goat.game_mode == goat.GAME_MODE_EXPLORING:
		environment_item_name = item_name


func interactive_item_deselected(item_name):
	if goat.game_mode == goat.GAME_MODE_EXPLORING:
		if item_name == environment_item_name:
			environment_item_name = null


func item_obtained(item_name):
	# Game developers should ensure this never happens
	if number_of_items >= CAPACITY:
		return
	
	add_item_button(item_name)
	adjust_buttons()
	number_of_items += 1


func item_removed(item_name):
	var removed_item = get_tree().get_nodes_in_group(
		"goat_context_inventory_item_button_" + item_name
	).pop_front()
	
	item_button_container.remove_child(removed_item)
	removed_item.queue_free()
	number_of_items -= 1
	adjust_buttons()


func item_replaced(item_name_replaced, item_name_replacing):
	var replaced_item = get_tree().get_nodes_in_group(
		"goat_context_inventory_item_button_" + item_name_replaced
	).pop_front()
	
	
	var insert_position = replaced_item.get_index()
	add_item_button(item_name_replacing, insert_position)
	item_button_container.remove_child(replaced_item)
	replaced_item.queue_free()
	adjust_buttons()


func item_button_pressed(item_name):
	goat.emit_signal("inventory_item_used_on_environment", item_name, environment_item_name)
	goat.emit_signal(
		"inventory_item_{}_used_on_environment_{}".format([item_name, environment_item_name], "{}")
	)
	goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)


func _on_ExitButton_pressed():
	goat.emit_signal("game_mode_changed", goat.GAME_MODE_EXPLORING)


func add_item_button(item_name=null, insert_position=null):
	if insert_position == null:
		insert_position = number_of_items
	
	var button_pivot = Control.new()
	button_pivot.rect_size = Vector2(0, 0)
	button_pivot.rect_position = Vector2(0, -100)
	button_pivot.rect_pivot_offset = Vector2(0, 100)
	
	var item_button = Button.new()
	# Account for 2x2 pixel frame and 64x64 pixel icon
	item_button.rect_min_size = Vector2(68, 68)
	item_button.rect_position = Vector2(-34, -34)
	item_button.rect_pivot_offset = Vector2(34, 34)
	item_button.focus_mode = Control.FOCUS_NONE
	
	item_button.set("custom_styles/pressed", INVENTORY_BUTTON_STYLE_FOCUS)
	item_button.set("custom_styles/normal", INVENTORY_BUTTON_STYLE_NORMAL)
	item_button.set("custom_styles/hover", INVENTORY_BUTTON_STYLE_HOVER)
	item_button.set("custom_styles/disabled", INVENTORY_BUTTON_STYLE_NORMAL)
	
	if item_name:
		item_button.icon = goat.inventory_items_textures[item_name]
		item_button.connect("pressed", self, "item_button_pressed", [item_name, ])
		item_button.connect("button_down", self, "item_button_down", [item_name, ])
		button_pivot.add_to_group("goat_context_inventory_item_button_" + item_name)
	else:
		item_button.disabled = true
	
	button_pivot.add_child(item_button)
	
	item_button_container.add_child(button_pivot)
	item_button_container.move_child(button_pivot, insert_position)


func adjust_buttons():
	# Add buttons if there are some missing
	while item_button_container.get_child_count() < CAPACITY:
		add_item_button()
	# Get rid of excess items
	while item_button_container.get_child_count() > CAPACITY:
		var last_button = item_button_container.get_children().pop_back()
		item_button_container.remove_child(last_button)
		last_button.queue_free()
	
	for button_pivot in item_button_container.get_children():
		button_pivot.rect_rotation = 360.0 / CAPACITY * button_pivot.get_index()
		var actual_button = button_pivot.get_children().pop_front()
		actual_button.rect_rotation = -button_pivot.rect_rotation