extends Node3D


func _process(_delta):
	if goat.ENABLE_INVENTORY_ICON_ROTATION:
		var seconds = Time.get_ticks_msec() * 0.001
		%Pivot.rotation_degrees.y = (
			360.0 * seconds / goat.INVENTORY_ICON_ROTATION_PER_SECOND
		)


func make_icon_texture(model_scene_path):
	var scene = load(model_scene_path).instantiate()
	scene.set_script(null)
	for c in %Pivot.get_children():
		%Pivot.remove_child(c)
	%Pivot.add_child(scene)
	return %SubViewport.get_texture()
