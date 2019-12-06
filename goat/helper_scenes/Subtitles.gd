extends Control

onready var text_box = $TextBox
onready var text = $TextBox/Label


func _ready():
	goat.monologue.connect("started", self, "show_subtitles")
	goat.monologue.connect("finished", self, "hide_subtitles")


func show_subtitles(monologue_name):
	text.text = goat.monologue.get_transcript(monologue_name)
	text_box.show()


func hide_subtitles():
	text.text = ""
	text_box.hide()
