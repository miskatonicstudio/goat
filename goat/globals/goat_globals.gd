extends Node


func load_all():
	assert (goat.GAME_RESOURCES_DIRECTORY)
	# TODO: load all scripts from the "globals" directory
	var script_file = goat.GAME_RESOURCES_DIRECTORY + "/globals/global.gd"
	var script = load(script_file).new()
	script.name = "global_game_script"
	get_tree().root.add_child(script)


func reset():
	for child in get_tree().root.get_children():
		if child.name == "global_game_script":
			get_tree().root.remove_child(child)
			break
