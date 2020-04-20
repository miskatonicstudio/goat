extends OptionButton

onready var popup = get_popup()


func _ready():
	var loaded_locales = TranslationServer.get_loaded_locales()
	loaded_locales.sort()
	var added_locales = []
	
	for locale in loaded_locales:
		if locale in added_locales:
			continue
		added_locales.append(locale)
		var locale_name = TranslationServer.get_locale_name(locale)
		popup.add_item(locale_name)
		var index = popup.get_item_count() - 1
		popup.set_item_metadata(index, locale)
		if locale == goat_settings.get_value("gui", "language"):
			selected = index
	
	popup.set("custom_fonts/font", load("res://goat/fonts/settings_font.tres"))
	popup.set(
		"custom_styles/hover",
		load("res://goat/styles/settings_language_hover.tres")
	)
	popup.set(
		"custom_styles/panel",
		load("res://goat/styles/settings_language_background.tres")
	)
	popup.set("custom_constants/vseparation", 12)


func _on_SettingsLanguageButton_item_selected(id):
	var locale = popup.get_item_metadata(id)
	goat_settings.set_value("gui", "language", locale)
