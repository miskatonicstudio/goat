extends Node


func list_directory(path):
	var files = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				files.append(file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: ", path)
	return files


func load_text_file(path):
	var file = File.new()
	file.open(path, File.READ)
	var content = file.get_as_text()
	file.close()
	return content
