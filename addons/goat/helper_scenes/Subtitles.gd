extends Control

@onready var bottom_text = $MarginContainer/BottomText
@onready var example_response = $MarginContainer/Responses/ExampleResponse
@onready var responses_container = $MarginContainer/Responses


func show_responses(responses):
	for response in responses:
		var response_button = example_response.duplicate()
		response_button.text = response.text
		response_button.button_down.connect(self.select_response.bind(response))
		responses_container.add_child(response_button)
		response_button.show()
	bottom_text.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func select_response(response):
	for i in range(1, responses_container.get_child_count()):
		responses_container.get_child(i).queue_free()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	goat_voice.select_response(response)


func _ready():
	goat_voice.responses.connect(self.show_responses)
	goat_voice.started.connect(self.show_subtitles)
	goat_voice.finished.connect(self.hide_subtitles)
	goat_settings.connect(
		"value_changed_gui_subtitles", self._on_subtitles_settings_changed
	)


func show_subtitles(text):
	"""Show a bottom bar with subtitles"""
	bottom_text.text = text
	if goat_settings.get_value("gui", "subtitles") and bottom_text.text:
		bottom_text.show()


func hide_subtitles(_text):
	"""Hide subtitles"""
	bottom_text.text = ""
	bottom_text.hide()


func _on_subtitles_settings_changed():
	"""
	Changes the visibility of subtitles, but only if they should be displayed
	at the moment.
	"""
	if bottom_text.text:
		bottom_text.visible = goat_settings.get_value("gui", "subtitles")
