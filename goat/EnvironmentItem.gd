tool
extends StaticBody

export (String) var unique_name
# TODO: replace all flags with an enum?
export (bool) var single_use = false
export (bool) var inventory_item = false
export (Shape) var collision_shape = BoxShape.new() setget set_collision_shape
onready var model = get_node("Model")


# TODO: rename this scene to "InteractiveItem"
func _ready():
	$CollisionShape.shape = collision_shape
	# TODO: this will probably not work for objects with emission
	model.material_override.emission_enabled = true
	model.material_override.emission = Color.white
	model.material_override.emission_energy = 0.0
	
	oat_interaction_signals.connect("oat_environment_item_selected", self, "select")
	oat_interaction_signals.connect("oat_environment_item_deselected", self, "deselect")
	oat_interaction_signals.connect("oat_environment_item_activated", self, "activate")


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
			# TODO: prevent deselecting twice, here and in RayCast3D
			oat_interaction_signals.emit_signal("oat_environment_item_deselected", item_name)
		if inventory_item:
			oat_interaction_signals.emit_signal("oat_environment_item_obtained", unique_name)
			get_parent().remove_child(self)
			queue_free()
