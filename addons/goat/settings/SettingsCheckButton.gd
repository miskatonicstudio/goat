extends CheckButton

@export var settings_section = ""
@export var settings_key = ""


func _ready():
	if not settings_section.is_empty() and not settings_key.is_empty():
		button_pressed = goat_settings.get_value(settings_section, settings_key)


func _on_SettingsCheckButton_pressed():
	if not settings_section.is_empty() and not settings_key.is_empty():
		goat_settings.set_value(settings_section, settings_key, button_pressed)
