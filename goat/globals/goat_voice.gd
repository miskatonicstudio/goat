class_name GoatVoice
extends Node

"""
Plays audio (currently intended for the voice of the protagonist). Stores sounds
and associated transcripts. Supports "default" audio: a lisf of files that will
be played by default if a meaningless action is performed (e.g. an item
combination that doesn't make sense is attempted). This is not intended to play
environment sounds or background music.
"""

signal started (audio_name)
signal finished (audio_name, interrupted)

# Actual audio player
var _audio_player := AudioStreamPlayer.new()
# Delays playing the default audio, so it can be replaced by a specific one
var _default_audio_scheduled := false
# Sound files and transcripts associated with audio names
var _audio_mapping := {}
# Currently playing sound, required for sending a signal if interrupted
var _currently_playing_audio_name = null
# List of audio names to play if a meaningless action is performed
var _default_audio_names := []


func _ready():
	# Randomize to get better results when playing random audio
	randomize()
	add_child(_audio_player)
	_audio_player.bus = "Music"
	_audio_player.connect("finished", self, "_on_audio_player_finished")


func _process(_delta):
	if _default_audio_scheduled:
		play_default()


func register(audio_name: String, transcript: String) -> void:
	"""
	Registers an audio file and associates it with a transcript. Reads files
	from the `voice` directory (audio_name and file name have to match).
	Currently only supports OGG files.
	"""
	assert(not _audio_mapping.has(audio_name))
	
	var sound_path := "res://{}/voice/{}.ogg".format(
		[goat.GAME_RESOURCES_DIRECTORY, audio_name], "{}"
	)
	var sound := load(sound_path)
	# Disable loop mode
	if sound is AudioStreamSample:
		sound.loop_mode = AudioStreamSample.LOOP_DISABLED
	elif sound is AudioStreamOGGVorbis:
		sound.loop = false
	
	_audio_mapping[audio_name] = {"sound": sound, "transcript": transcript}


func play(audio_names) -> void:
	"""
	Plays an audio file with the given name. If and array of names is given,
	chooses one at random. If audio is already playing, interrupts it.
	"""
	prevent_default()
	stop()
	var audio_name: String;
	if audio_names is Array:
		audio_name = audio_names[randi() % audio_names.size()]
	else:
		audio_name = audio_names
	assert(audio_name in _audio_mapping)
	_currently_playing_audio_name = audio_name
	_audio_player.stream = _audio_mapping[audio_name]["sound"]
	_audio_player.play()
	emit_signal("started", audio_name)


func stop() -> void:
	if _audio_player.playing:
		emit_signal("finished", _currently_playing_audio_name, true)
		_audio_player.stop()


func play_default() -> void:
	"""Plays one of the default audio files"""
	if _default_audio_names:
		play(_default_audio_names)
	_default_audio_scheduled = false


func prevent_default() -> void:
	"""Prevents default audio from playing"""
	_default_audio_scheduled = false


func reset() -> void:
	"""Clears all registered audio files and configuration"""
	_audio_mapping.clear()
	_default_audio_names.clear()


func set_default_audio_names(default_audio_names: Array) -> void:
	"""
	Set the names of default audio files. Each of those files has to be
	registered first.
	"""
	_default_audio_names = default_audio_names


func get_transcript(audio_name: String) -> String:
	"""Returns localized transcript associated with the given audio name"""
	return tr(_audio_mapping[audio_name]["transcript"])


func connect_default(signal_object: Object, signal_name: String) -> void:
	"""
	Configures default audio files to be played when signal_object emits
	signal_name. This can be called several times to play default audio in
	different situations.
	"""
	signal_object.connect(signal_name, self, "_schedule_default")


func _schedule_default(_arg1=null, _arg2=null, _arg3=null, _arg4=null):
	"""
	Schedules a default audio, but doesn't play it yet, allowing a more specific
	audio to be played first instead. Arguments are ignored to allow this
	method to handle different signals.
	"""
	_default_audio_scheduled = true


func _on_audio_player_finished():
	emit_signal("finished", _currently_playing_audio_name, false)
	_currently_playing_audio_name = null
