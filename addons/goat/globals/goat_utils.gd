extends Node


func list_directory(path):
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin() # TODOGODOT4 fill missing arguments https://github.com/godotengine/godot/pull/40547
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: ", path)
	return files


func load_text_file(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	return content


func add_translations(translation_directory_path):
	for file in list_directory(translation_directory_path):
		if file.ends_with(".translation"):
			var position = ResourceLoader.load(translation_directory_path + file)
			TranslationServer.add_translation(position)
	print("Translations added, source folder: " + translation_directory_path)


func remove_translations(translation_directory_path):
	for file in list_directory(translation_directory_path):
		if file.ends_with(".translation"):
			var position = ResourceLoader.load(translation_directory_path + file)
			TranslationServer.remove_translation(position)
	print("Translations removed, source folder: " + translation_directory_path)
