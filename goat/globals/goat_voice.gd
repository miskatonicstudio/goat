class_name GoatVoice
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

# Actual audio player
var _audio_player := AudioStreamPlayer.new()
var _audio_timer := Timer.new()
# Delays playing the default audio, so it can be replaced by a specific one
var _default_audio_scheduled := false
# Sound files and transcripts associated with audio names
var _audio_mapping := {}
# Currently playing sound, required for sending a signal when finished/skipped
var _currently_playing_audio_name = null
# List of audio names to play if a meaningless action is performed
var _default_audio_names := []
# Sequence of audio names to play next
var _current_audio_names_sequence := []


func _ready():
	# Randomize to get better results when playing random audio
	randomize()
	add_child(_audio_player)
	add_child(_audio_timer)
	_audio_player.bus = "Music"
	_audio_player.connect("finished", self, "_on_audio_finished")
	_audio_timer.one_shot = true
	_audio_timer.connect("timeout", self, "_on_audio_finished")


func _process(_delta):
	if _default_audio_scheduled:
		play_default()


func _input(_event):
	if is_playing() and Input.is_action_just_pressed("goat_dismiss"):
		stop()


func register(
	audio_file_name: String, transcript: String, time: float = 0,
	audio_name = null
) -> void:
	"""
	Registers an audio file and associates it with a transcript. Reads files
	from the `voice` directory. By default the name of the registered audio will
	be the same as the name of the audio file (`audio_file_name`) without the
	extension. It can also be set manually, by using the `audio_name` argument.
	If `time` is not 0, this method will not attempt to read the audio file.
	Instead, it will register the transcript and the duration is should be
	"played" (for the purpose of showing the subtitles).
	"""
	if audio_name == null:
		audio_name = audio_file_name.get_file().get_basename()
	assert(not _audio_mapping.has(audio_name))
	
	var sound = null
	
	if not time:
		var sound_path := "res://{}/voice/{}".format(
			[goat.GAME_RESOURCES_DIRECTORY, audio_file_name], "{}"
		)
		sound = load(sound_path)
		# Disable loop mode
		if sound is AudioStreamSample:
			sound.loop_mode = AudioStreamSample.LOOP_DISABLED
		elif sound is AudioStreamOGGVorbis:
			sound.loop = false
	
	_audio_mapping[audio_name] = {
		"transcript": transcript, "time": time, "sound": sound
	}


func play(audio_names) -> void:
	"""
	Plays an audio file with the given name. If an array of names is given,
	chooses one at random.
	"""
	_current_audio_names_sequence = []
	prevent_default()
	var audio_name: String;
	if audio_names is Array:
		audio_name = audio_names[randi() % audio_names.size()]
	else:
		audio_name = audio_names
	assert(audio_name in _audio_mapping)
	_currently_playing_audio_name = audio_name
	
	_play(audio_name)


func play_sequence(audio_names_sequence: Array) -> void:
	"""
	Plays a sequence of audio files with given names. The first file on the list
	is played immediately, each next is played after the previous file is played
	fully or is interrupted. The sequence sends normal `goat_voice` signals
	(`started`, `finished`) for each audio name on the list.
	"""
	prevent_default()
	assert(audio_names_sequence)
	audio_names_sequence = audio_names_sequence.duplicate()
	var first_audio_name = audio_names_sequence.pop_front()
	_current_audio_names_sequence = audio_names_sequence
	_play(first_audio_name)


func play_default() -> void:
	"""Plays one of the default audio files"""
	if _default_audio_names:
		play(_default_audio_names)
	_default_audio_scheduled = false


func stop() -> void:
	if is_playing():
		_audio_player.stop()
		_audio_timer.stop()
		_stop()


func prevent_default() -> void:
	"""Prevents default audio from playing"""
	_default_audio_scheduled = false


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


func is_playing() -> bool:
	return _audio_player.playing or not _audio_timer.is_stopped()


func _schedule_default(_arg1=null, _arg2=null, _arg3=null, _arg4=null) -> void:
	"""
	Schedules a default audio, but doesn't play it yet, allowing a more specific
	audio to be played first instead. Arguments are ignored to allow this
	method to handle different signals.
	"""
	_default_audio_scheduled = true


func _on_audio_finished() -> void:
	# Stopped audio player emits a signal, but the timer might still be active
	if not is_playing():
		_stop()


func _play(audio_name: String) -> void:
	"""Plays a single audio file with the given name"""
	if _audio_mapping[audio_name]["time"]:
		_audio_timer.start(_audio_mapping[audio_name]["time"])
	else:
		_audio_player.stream = _audio_mapping[audio_name]["sound"]
		_audio_player.play()
	emit_signal("started", audio_name)


func _stop() -> void:
	"""
	Resets currently playing audio name, sends `finished` signal. If there is
	another audio name in a sequence, plays it.
	"""
	var currently_playing_audio_name = _currently_playing_audio_name
	_currently_playing_audio_name = null
	emit_signal("finished", currently_playing_audio_name)
	
	if _current_audio_names_sequence:
		_play(_current_audio_names_sequence.pop_front())
