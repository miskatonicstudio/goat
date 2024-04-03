extends Node


func list_directory(path):
	var dir = DirAccess.open(path)
	return dir.get_files()


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
