extends Control

onready var top_bar = $ScrollContainer
onready var item_container = $ScrollContainer/CenterContainer/HBoxContainer

var currently_selected_item = null
var currently_dragged_item = null


func _ready():
	oat_interaction_signals.connect("oat_environment_item_obtained", self, "item_obtained")
	oat_interaction_signals.connect("oat_inventory_item_selected", self, "item_selected")


func _input(event):
	if currently_dragged_item and Input.is_action_just_released("oat_inventory_item_dragging"):
		Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
		if (
			event is InputEventMouse and
			not top_bar.get_global_rect().has_point(event.global_position) and
			currently_dragged_item != currently_selected_item
		):
			oat_interaction_signals.emit_signal(
				"oat_inventory_item_used_on_inventory", currently_selected_item, currently_dragged_item
			)
		currently_dragged_item = null


func item_obtained(item_name):
	var item_button = TextureButton.new()
	item_button.texture_normal = oat_interaction_signals.inventory_items_textures[item_name]
	item_button.connect("pressed", self, "item_button_pressed", [item_name, ])
	item_button.connect("button_down", self, "item_button_down", [item_name, ])
	item_container.add_child(item_button)
	
	if not currently_selected_item:
		oat_interaction_signals.emit_signal("oat_inventory_item_selected", item_name)


func item_selected(item_name):
	currently_selected_item = item_name


func item_button_pressed(item_name):
	oat_interaction_signals.emit_signal("oat_inventory_item_selected", item_name)


func item_button_down(item_name):
	currently_dragged_item = item_name
	var texture = oat_interaction_signals.inventory_items_textures[item_name]
	# TODO: read texture size from config
	# TODO: use settings signals for setting cursor?
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, Vector2(32, 32))
