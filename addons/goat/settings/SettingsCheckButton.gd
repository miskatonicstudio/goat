extends CheckButton

export (String) var settings_section
export (String) var settings_key


func _ready():
	if settings_section and settings_key:
		pressed = goat_settings.get_value(settings_section, settings_key)


func _on_SettingsCheckButton_pressed():
	if settings_section and settings_key:
		goat_settings.set_value(settings_section, settings_key, pressed)
