extends Node

##### AUDIO MODULE #####
# Handles everything related to playing & stopping music, sounds and voicelines.

#game tree goodies we need
@onready var GameMain = get_node("/root/GameMain")
@onready var audio_busses:Node = get_node("/root/GameMain/AudioBusses")

# load audio busses
@onready var music_player:AudioStreamPlayer = audio_busses.get_node("MusicPlayer")
@onready var sfx_player:AudioStreamPlayer = audio_busses.get_node("SFXPlayer")
@onready var voice_player:AudioStreamPlayer = audio_busses.get_node("VoicePlayer")

# important variables
var song_database:Dictionary = {} ## Stores song metadata from scripts/metadata/music.json. Gets filled in when the module boots.

func play_music(music:AudioStream) -> void: ## Plays the provided music track.
	# stop and fade out the previous track if a track is already playing
	if music_player.playing:
		await stop_music(3)
		await get_tree().create_timer(.5).timeout
	
	# play the music! and update it on the data module
	music_player.stream = music
	music_player.play()
	
	# get song name and update the current state's music
	var song_name = GeneralModule.get_file_name(music)
	DataStateModule.game_data.CurrentMusic = song_name
	
	# display song metadata if available
	if song_database.has(song_name):
		# get song data
		var song_data = song_database[song_name]
		var title = song_data.get("title", "Unknown title...")
		var artist = song_data.get("artist", "Unknown artist...")
		
		# print song data
		print("♪ Now Playing: ", title, " by ", artist)

func stop_music(fade_time:float) -> void: ## Stops currently playing music.
	# if music is not playing, dont do anything
	if not music_player.playing: return
	
	# clear current music in game state
	DataStateModule.game_data.CurrentMusic = ""
	
	# create fade out effect
	var volume_tween = create_tween().set_parallel(true)
	volume_tween.tween_property(music_player, "volume_linear", 0, fade_time)
	await volume_tween.finished
	
	# stop the music and revert the tween
	music_player.stop()
	music_player.volume_linear = 1

func play_sfx(sfx:AudioStream) -> void: ## Plays the provided sound effect.
	sfx_player.stream = sfx
	sfx_player.play()

func play_voiceline(voiceline:AudioStream) -> void: ## Plays the provided voiceline.
	voice_player.stream = voiceline
	voice_player.play()

func _ready() -> void: ## Setup.
	# load song database
	song_database = GeneralModule.load_metadata_file("music.json")
