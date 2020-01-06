extends Spatial

onready var animation_player = $AnimationPlayer



func _ready():
	animation_player.play("start_game")
	# warning-ignore:return_value_discarded
	demo.connect("portal_entered", animation_player, "play", ["end_game"])
	# warning-ignore:return_value_discarded
	animation_player.connect("animation_finished", self, "animation_finished")
	# This is only for demonstration purpose
	# warning-ignore:return_value_discarded
	goat.connect("game_mode_changed", self, "notify", ["Game mode changed: "])
	# warning-ignore:return_value_discarded
	goat.connect("interactive_item_selected", self, "notify", ["Selected: "])
	# warning-ignore:return_value_discarded
	goat.connect("interactive_item_deselected", self, "notify", ["Deselected: "])
	# warning-ignore:return_value_discarded
	goat.connect("interactive_item_activated", self, "notify2", ["Activated: "])
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_obtained", self, "notify", ["Obtained: "])
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_selected", self, "notify", ["Selected (inv): "])
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_removed", self, "notify", ["Removed: "])
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_used", self, "notify", ["Used: "])
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_used_on_inventory", self, "notify2", ["Used inventory: "])
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_used_on_environment", self, "notify2", ["Used environment: "])
	# warning-ignore:return_value_discarded
	goat.connect("inventory_item_replaced", self, "notify2", ["Replaced: "])


func notify(arg, text):
	print(text + str(arg))


func notify2(arg1, arg2, text):
	print(text + arg1 + " => " + str(arg2))


func animation_finished(animation_name):
	if animation_name == "end_game":
		get_tree().change_scene("res://demo/Credits.tscn")
