extends Spatial


func _ready():
	# warning-ignore:return_value_discarded
	goat.connect("interactive_item_activated", self, "activate")
	$Screen.material_override.albedo_texture = $Viewport.get_texture()


func activate(item_name, _position):
	if item_name == "remote_button":
		$AnimationPlayer.play("press_button")
		$Screen.material_override.albedo_color = Color.white
		$Viewport/VideoPlayer.play()


func _on_VideoPlayer_finished():
	$Screen.material_override.albedo_color = Color.black
