extends Spatial


func _ready():
	goat.connect("interactive_item_activated", self, "item_activated")


func item_activated(item_name, _position):
	if item_name == "remote_button":
		$AnimationPlayer.play("press_button")
		# TODO: send a signal: portal activated
