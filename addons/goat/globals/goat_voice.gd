extends Node

"""
Plays audio (currently intended for the voice of the protagonist). Stores sounds
and associated transcripts. Supports "default" audio: a list of files that will
be played by default if a meaningless action is performed (e.g. an item
combination that doesn't make sense is attempted). This is not intended to play
environment sounds or background music.
"""

signal started (audio_name)
signal finished (audio_name)
signal responses (responses)

# Delays playing the default audio, so it can be replaced by a specific one
var _default_audio_scheduled := false
# Sound files and transcripts associated with audio names
var _audio_mapping := {}
# List of audio names to play if a meaningless action is performed
var _default_audio_names := []

# TODO: document new variables
var _waiting_for_response = false
var _temporary_game_states: Array = []
var _current_dialogue_resource = null
var _current_dialogue_line = null
var _dialogue_timer := Timer.new()
var _dialogue_audio_player := AudioStreamPlayer.new()


func start_dialogue(dialogue_name):
	prevent_default()
	var game_resources_directory = goat.get_game_resources_directory()
	assert (game_resources_directory, "No game resources directory is configured")
	var path = game_resources_directory + "/goat/dialogues/goat.dialogue"
	Engine.get_singleton("DialogueManager").show_dialogue_balloon(
		load(path), dialogue_name
	)


func start(dialogue_resource, title, extra_game_states = []) -> void:
	"""This is a hook for Dialogue Manager"""
	_temporary_game_states =  [self] + extra_game_states
	_current_dialogue_resource = dialogue_resource
	_process_dialogue_line(title)


func select_response(response):
	_process_dialogue_line(response.next_id)
	_waiting_for_response = false


func _process_dialogue_line(line_id):
	var previous_dialogue_text = null
	if _current_dialogue_line:
		if _current_dialogue_line.responses and not _waiting_for_response:
			# Don't finish the dialogue until a response is selected
			_waiting_for_response = true
			responses.emit(_current_dialogue_line.responses)
			return
		previous_dialogue_text = _current_dialogue_line.text
	_current_dialogue_line = _current_dialogue_resource.get_next_dialogue_line(
		line_id, _temporary_game_states
	)
	if not _current_dialogue_line:
		_current_dialogue_resource = null
	
	if previous_dialogue_text:
		finished.emit(previous_dialogue_text)
	
	if _current_dialogue_line:
		var line_text = _current_dialogue_line.text
		var key = _current_dialogue_line.translation_key
		var time = max(1.0, len(line_text) * 0.1)
		if key in _audio_mapping:
			if _audio_mapping[key]["sound"]:
				_dialogue_audio_player.stream = _audio_mapping[key]["sound"]
				_dialogue_audio_player.play()
			if _audio_mapping[key]["time"]:
				time = _audio_mapping[key]["time"]
		_dialogue_timer.start(time)
		started.emit(line_text)


func _on_dialogue_finished():
	_process_dialogue_line(_current_dialogue_line.next_id)


func _ready():
	# Randomize to get better results when playing random audio
	randomize()
	add_child(_dialogue_timer)
	add_child(_dialogue_audio_player)
	_dialogue_audio_player.bus = "GoatMusic"
	_dialogue_timer.one_shot = true
	_dialogue_timer.connect("timeout", self._on_dialogue_finished)
	
	# TODO: allow for configuring this per game
	goat_voice.connect_default(goat_inventory.item_used)
	goat_voice.connect_default(goat_interaction.object_activated)


func _process(_delta):
	if _default_audio_scheduled:
		play_default()


func _input(_event):
	if is_playing() and Input.is_action_just_pressed("goat_dismiss"):
		stop()


func _init():
	if not goat.get_game_resources_directory():
		print("No voice loaded")
		return
	var voice_directory = goat.get_game_resources_directory() + "/goat/voice/"
	var files = goat_utils.list_directory(voice_directory)
	for file in files:
		if file.ends_with(".import"):
			# Godot export workaround
			if not OS.is_debug_build():
				var actual_file = file.replace(".import", "")
				var basename = actual_file.get_basename()
				_register(actual_file)
			else:
				continue
		var basename = file.get_basename()
		if file.ends_with(".txt"):
			var content = goat_utils.load_text_file(voice_directory + file)
			var seconds = float(content.strip_edges())
			_register(basename, seconds)
		else:
			_register(file)


func _register(audio_file_name: String, time: float = 0) -> void:
	"""
	Registers an audio file and associates it with a transcript. Reads files
	from the `voice` directory. By default the name of the registered audio will
	be the same as the name of the audio file (`audio_file_name`) without the
	extension. It can also be set manually, by using the `audio_name` argument.
	If `time` is not 0, this method will not attempt to read the audio file.
	Instead, it will register the transcript and the duration is should be
	"played" (for the purpose of showing the subtitles).
	"""
	var audio_name = audio_file_name.get_file().get_basename()
	assert(not _audio_mapping.has(audio_name))
	
	var sound = null
	
	if not time:
		var sound_path := "{}/goat/voice/{}".format(
			[goat.get_game_resources_directory(), audio_file_name], "{}"
		)
		sound = load(sound_path)
		# Disable loop mode
		if sound is AudioStreamWAV:
			sound.loop_mode = AudioStreamWAV.LOOP_DISABLED
		elif sound is AudioStreamOggVorbis:
			sound.loop = false
		time = sound.get_length()
	
	_audio_mapping[audio_name] = {"time": time, "sound": sound}


func play_default() -> void:
	"""Plays one of the default audio files"""
	if _default_audio_names:
		var dialogue_name = _default_audio_names[
			randi() % _default_audio_names.size()
		]
		start_dialogue(dialogue_name)
	_default_audio_scheduled = false


func stop() -> void:
	if is_playing():
		_dialogue_audio_player.stop()
		_dialogue_timer.stop()
	if _current_dialogue_resource and not _waiting_for_response:
		_process_dialogue_line(_current_dialogue_line.next_id)


func prevent_default() -> void:
	"""Prevents default audio from playing"""
	_default_audio_scheduled = false


func set_default_audio_names(default_audio_names: Array) -> void:
	"""
	Set the names of default audio files. Each of those files has to be
	registered first.
	"""
	_default_audio_names = default_audio_names


func connect_default(trigger_signal: Signal) -> void:
	"""
	Configures default audio files to be played when trigger_signal is emitted.
	Can be called several times to play default audio in different situations.
	"""
	trigger_signal.connect(self._schedule_default)


func is_playing() -> bool:
	return _current_dialogue_resource != null


func _schedule_default(_arg1=null, _arg2=null, _arg3=null, _arg4=null) -> void:
	"""
	Schedules a default audio, but doesn't play it yet, allowing a more specific
	audio to be played first instead. Arguments are ignored to allow this
	method to handle different signals.
	"""
	_default_audio_scheduled = true
