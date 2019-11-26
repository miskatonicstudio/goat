tool
extends StaticBody

export (String) var unique_name
export (bool) var single_use = false
export (bool) var inventory_item = false
export (Shape) var collision_shape = BoxShape.new() setget set_collision_shape
onready var model = get_node("Model")


func _ready():
	add_to_group("goat_interactive_item_" + unique_name)
	$CollisionShape.shape = collision_shape
	
	model.material_override.emission_enabled = true
	model.material_override.emission = Color.white
	model.material_override.emission_energy = 0.0
	
	goat.connect("environment_item_selected", self, "select")
	goat.connect("environment_item_deselected", self, "deselect")
	goat.connect("environment_item_activated", self, "activate")


func set_collision_shape(new_shape):
	collision_shape = new_shape
	if is_inside_tree():
		$CollisionShape.shape = collision_shape


func select(item_name):
	if item_name == unique_name:
		model.material_override.emission_energy = 0.2


func deselect(item_name):
	if item_name == unique_name:
		model.material_override.emission_energy = 0.0


func activate(item_name):
	if item_name == unique_name:
		if single_use:
			deselect(item_name)
			remove_from_group("goat_interactive_item")
			goat.emit_signal("environment_item_deselected", item_name)
		if inventory_item:
			goat.emit_signal("inventory_item_obtained", unique_name)
			get_parent().remove_child(self)
			queue_free()
