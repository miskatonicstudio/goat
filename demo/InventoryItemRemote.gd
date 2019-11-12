extends Spatial


func _ready():
	oat_interaction_signals.connect("oat_environment_item_activated", self, "item_activated")


func item_activated(item_name):
	if item_name == "remote_button":
		$AnimationPlayer.play("press_button")
