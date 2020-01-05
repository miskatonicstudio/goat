tool
extends VBoxContainer

export (String) var label_text = "" setget set_label_text
export (String) var settings_section
export (String) var settings_key
export (float) var min_value
export (float) var max_value

onready var slider = $Slider
onready var label = $Label


func _ready():
	label.text = label_text
	if min_value:
		slider.min_value = min_value
	if max_value:
		slider.max_value = max_value
	if settings_section and settings_key:
		slider.value = goat.settings.get_value(settings_section, settings_key)


func set_label_text(new_label_text):
	label_text = new_label_text
	if is_inside_tree():
		label.text = new_label_text


func _on_Slider_value_changed(_value):
	if settings_section and settings_key:
		goat.settings.set_value(settings_section, settings_key, slider.value)
