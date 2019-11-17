extends StaticBody

export (String) var unique_name

onready var screen_surface = $ScreenSurface
onready var viewport = $Viewport
onready var content = get_node("Content")


func _ready():
	remove_child(content)
	viewport.add_child(content)
	viewport.size = content.rect_size
	screen_surface.material_override = screen_surface.material_override.duplicate(true)
	screen_surface.material_override.albedo_texture = viewport.get_texture()
	goat.connect("oat_interactive_screen_activated", self, "screen_activated")


func screen_activated(screen_name, position):
	if screen_name != unique_name:
		return
	var local_position = screen_surface.to_local(position)
	var screen_coordinates = Vector2(local_position.x + 0.5, 0.5 - local_position.y) * viewport.size
	var ev = InputEventMouseButton.new()
	ev.button_index = BUTTON_LEFT
	ev.global_position = screen_coordinates
	ev.position = screen_coordinates
	# Press the button
	ev.pressed = true
	ev.button_mask = 1
	viewport.input(ev)
	# Release the button
	ev.pressed = false
	ev.button_mask = 0
	viewport.input(ev)
