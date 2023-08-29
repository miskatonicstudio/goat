extends HSlider

@export var settings_section = ""
@export var settings_key = ""


func _ready():
	if not settings_section.is_empty() and not settings_key.is_empty():
		value = goat_settings.get_value(settings_section, settings_key)


func _on_SettingsSlider_value_changed(value):
	if not settings_section.is_empty() and not settings_key.is_empty():
		goat_settings.set_value(settings_section, settings_key, value)
