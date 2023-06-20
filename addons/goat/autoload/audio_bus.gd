extends Node


func _enter_tree():
	for name in ["GoatEffects", "GoatMusic"]:
		var idx = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, name)
		AudioServer.set_bus_solo(idx, false)
		AudioServer.set_bus_mute(idx, false)
		AudioServer.set_bus_bypass_effects(idx, false)
		AudioServer.set_bus_volume_db(idx, 0.0)
		AudioServer.set_bus_send(idx, "Master")
		print("Added GOAT audio bus: ", name, ", index: ", idx)


func _exit_tree():
	for index in range(AudioServer.bus_count - 1, 0, -1):
		var name = AudioServer.get_bus_name(index)
		if name.begins_with("Goat"):
			AudioServer.remove_bus(index)
			print("Removed GOAT audio bus: ", name, ", index: ", index)
