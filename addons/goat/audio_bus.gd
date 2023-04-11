extends Node
 
const AUDIO_BUSES = ["Music", "Effects"]


func _enter_tree():
	for name in AUDIO_BUSES:
		var idx = AudioServer.bus_count
		AudioServer.add_bus(idx)
		AudioServer.set_bus_name(idx, name)
		AudioServer.set_bus_solo(idx, false)
		AudioServer.set_bus_mute(idx, false)
		AudioServer.set_bus_bypass_effects(idx, false)
		AudioServer.set_bus_volume_db(idx, 0.0)
		AudioServer.set_bus_send(idx, "Master")
	print("GOAT audio buses added")


func _exit_tree():
	for name in AUDIO_BUSES:
		var idx = AudioServer.get_bus_index(name)
		AudioServer.remove_bus(idx)
	print("GOAT audio buses removed")
