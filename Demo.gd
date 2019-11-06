extends Spatial


func _ready():
	oat_interaction_signals.connect("oat_environment_item_selected", self, "notify", ["Selected: "])
	oat_interaction_signals.connect("oat_environment_item_deselected", self, "notify", ["Deselected: "])


func notify(item_name, text):
	$Notification.text = text + item_name
	$Timer.start()


func _on_Timer_timeout():
	$Notification.text = ""
