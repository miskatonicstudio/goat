class_name InteractiveScreen
extends StaticBody

"""
Represents a flat screen with interactive content. Actual content is provided
by 'Content' node that needs to be added as a child. The 'object_selected'
signal will be passed to content as mouse movement. The 'object_activated'
signal will be passed to content as LMB click.
"""

export (String) var unique_name
export (Vector2) var content_size = Vector2(100, 100)
export (float, 0, 16) var emission_energy = 1.0
export (bool) var unshaded = false

onready var screen_surface = $ScreenSurface
onready var viewport = $Viewport
onready var interaction_icon = $InteractionIcon
# A 2D node with screen's content should be added as a child 
onready var content = get_node("Content")


func _ready():
	add_to_group("goat_interactive_object_" + unique_name)
	
	goat_interaction.connect("object_selected", self, "_on_object_selected")
	goat_interaction.connect("object_deselected", self, "_on_object_deselected")
	goat_interaction.connect("object_activated", self, "_on_object_activated")
	goat_interaction.connect(
		"object_activated_alternatively", self,
		"_on_object_activated_alternatively"
	)
	
	# Content is moved to the Viewport
	content.rect_size = content_size
	viewport.size = content_size
	remove_child(content)
	viewport.add_child(content)
	
	# Duplicate the existing material and set a viewport texture
	var new_material = screen_surface.material_override.duplicate(true)
	var tex = viewport.get_texture()
	tex.flags = 7
	new_material.albedo_texture = tex
	new_material.flags_unshaded = unshaded
	if emission_energy:
		new_material.emission_enabled = true
		new_material.emission_texture = tex
		new_material.emission_energy = emission_energy
	screen_surface.material_override = new_material


func _on_object_selected(object_name, point):
	if object_name != unique_name:
		return
	
	if not interaction_icon.visible:
		interaction_icon.show()
	interaction_icon.translation = screen_surface.to_local(point)
	
	var screen_coordinates = _convert_to_screen_coordinates(point)
	# Creates a mouse motion event
	var event = InputEventMouseMotion.new()
	event.global_position = screen_coordinates
	event.position = screen_coordinates
	viewport.input(event)


func _on_object_deselected(object_name):
	if object_name == unique_name:
		interaction_icon.hide()


func _on_object_activated(object_name, point):
	if object_name != unique_name:
		return
	
	# Screen activation should not play default audio
	goat_voice.prevent_default()
	var screen_coordinates = _convert_to_screen_coordinates(point)
	var event = InputEventMouseButton.new()
	# Creates 2 mouse button events: button pressed and button released
	event.button_index = BUTTON_LEFT
	event.global_position = screen_coordinates
	event.position = screen_coordinates
	# Press the button
	event.pressed = true
	event.button_mask = 1
	viewport.input(event)
	# Release the button
	event.pressed = false
	event.button_mask = 0
	viewport.input(event)


func _on_object_activated_alternatively(object_name, _point):
	if object_name == unique_name:
		goat.game_mode = goat.GameMode.CONTEXT_INVENTORY


func _convert_to_screen_coordinates(global_point):
	# Converts to local point where z = 0 and x and y are between -0.5 and 0.5
	var local_point = screen_surface.to_local(global_point)
	# Converts to screen space ranging from (0, 0) to viewport.size
	return Vector2(local_point.x + 0.5, 0.5 - local_point.y) * viewport.size
