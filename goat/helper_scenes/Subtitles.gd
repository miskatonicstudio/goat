extends Control

onready var text_box = $TextBox
onready var text = $TextBox/Label


func _ready():
	goat_voice.connect("started", self, "show_subtitles")
	goat_voice.connect("finished", self, "hide_subtitles")


func show_subtitles(audio_name):
	"""Show a bottom bar with subtitles"""
	text.text = goat_voice.get_transcript(audio_name)
	text_box.show()


func hide_subtitles(_audio_name, interrupted):
	"""Hides subtitles, but only if audio was played fully"""
	if not interrupted:
		text.text = ""
		text_box.hide()
