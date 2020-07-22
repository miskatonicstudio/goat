extends Control

onready var text_box = $TextBox
onready var text = $TextBox/Label


func _ready():
	goat_voice.connect("started", self, "show_subtitles")
	goat_voice.connect("finished", self, "hide_subtitles")
	goat_settings.connect(
		"value_changed_gui_subtitles", self, "_on_subtitles_settings_changed"
	)


func show_subtitles(audio_name):
	"""Show a bottom bar with subtitles"""
	text.text = goat_voice.get_transcript(audio_name)
	if goat_settings.get_value("gui", "subtitles"):
		text_box.show()


func hide_subtitles(_audio_name):
	"""Hide subtitles"""
	text.text = ""
	text_box.hide()


func _on_subtitles_settings_changed():
	"""
	Changes the visibility of subtitles, but only if they should be displayed
	at the moment.
	"""
	if text.text:
		text_box.visible = goat_settings.get_value("gui", "subtitles")
