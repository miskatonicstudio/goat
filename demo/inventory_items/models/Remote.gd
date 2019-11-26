extends Spatial


func _ready():
	goat.connect("interactive_item_activated", self, "item_activated")
	$Screen.material_override.albedo_texture = $Viewport.get_texture()


func item_activated(item_name):
	if item_name == "remote_button":
		$AnimationPlayer.play("press_button")
		$Screen.material_override.albedo_color = Color.white
		$Viewport/VideoPlayer.play()


func _on_VideoPlayer_finished():
	$Screen.material_override.albedo_color = Color.black
