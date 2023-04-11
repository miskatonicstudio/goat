extends HSlider

export (String) var settings_section
export (String) var settings_key


func _ready():
	if settings_section and settings_key:
		value = goat_settings.get_value(settings_section, settings_key)


func _on_SettingsSlider_value_changed(value):
	if settings_section and settings_key:
		goat_settings.set_value(settings_section, settings_key, value)
