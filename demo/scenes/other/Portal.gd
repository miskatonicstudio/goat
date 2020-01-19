extends Spatial

onready var portal_light_material = $CSGTorus/LED.material
onready var portal = $CSGTorus/Portal
onready var the_other_side_sound = $CSGTorus/Portal/TheOtherSideSound
onready var animation_player = $AnimationPlayer


func _ready():
	goat_interaction.connect("object_activated", self, "_on_object_activated")
	demo.connect("generator_activated", self, "_on_generator_activated")
	demo.connect("coords_uploaded", self, "_on_coords_uploaded")
	demo.connect("remote_activated", self, "_on_remote_activated")


func _on_object_activated(object_name, _point):
	# Portal is only available after coords are uploaded and remote is pressed
	if object_name == "portal":
		if demo.portal_status != demo.PortalStatus.OPEN:
			goat_voice.prevent_default()
			return
		
		if demo.food_eaten:
			demo.portal_status = demo.PortalStatus.ENTERED
			demo.emit_signal("portal_entered")
			goat_voice.play("another_world_awaits")
		else:
			goat_voice.play("eat_something_first")


func _on_generator_activated():
	# Generator can be activated only once
	portal_light_material.emission = Color("c87808")


func _on_coords_uploaded():
	# Coords can be uploaded only once, and after generator is activated
	portal_light_material.emission = Color("93f740")
	demo.portal_status = demo.PortalStatus.READY


func _on_remote_activated():
	if demo.portal_status == demo.PortalStatus.READY:
		portal_light_material.emission = Color("21dada")
		demo.portal_status = demo.PortalStatus.OPEN
		# Move the portal up, so it can be interacted with
		portal.translation = Vector3(0, 0, 0)
		animation_player.play("portal_light")
		the_other_side_sound.play()
		# Exit inventory mode to show that the portal is active
		goat.game_mode = goat.GameMode.EXPLORING
		goat_voice.play("finally_active")
