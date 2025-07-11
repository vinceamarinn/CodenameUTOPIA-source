extends Node
@onready var audio_busses:Node = get_node("/root/GameMain/AudioBusses")
@onready var music_player:AudioStreamPlayer = audio_busses.get_node("MusicPlayer")
@onready var sfx_player:AudioStreamPlayer = audio_busses.get_node("SFXPlayer")
@onready var voice_player:AudioStreamPlayer = audio_busses.get_node("VoicePlayer")

@onready var game_data = DataStateModule.game_data

# This module handles more generic things that do not need their own specified module, or things that don't fall into any specific module.
# It also stores global variables like the character list, for everyone's use.

enum Characters { ## Very important list of all registered characters. Used in any resources that require you to select a character.
	# Main Characters - the 16 participants of the game & the enforcer.
	YUUTO,
	YUUKA,
	LANCE,
	KAZUHITO,
	SUKAI,
	RYUJI,
	SHIRO,
	AYANA,
	REINA,
	REN,
	GOKI,
	DAIYA,
	NAOMI,
	WILLOW,
	IKUE,
	SEBASTIAN,
	MADAME,
	
	# Alt. Characters - alternative versions of characters (something like Yuuto with pajamas on instead, for example).
	SHIZUKA,
	
	# Secondary Characters - characters who appear in the story besides the main characters with a good amount of appearances.
	
	# Tertiary Characters - characters who only appear in the story for a few specific scenes.
}

enum PlayableChars { ## Enum list of characters you are able to play as.
	YUUTO,
	YUUKA
}

var known_name_list:Dictionary = { ## Dictionary assigning every character to their known name.
	# Main Characters
	Characters.YUUTO: "Yuuto Katashi",
	Characters.YUUKA: "Yuuka Katashi",
	Characters.LANCE: "Lance Katsunosuke",
	Characters.KAZUHITO: "'Kazuhito'",
	Characters.SUKAI: "Sukai Manato",
	Characters.RYUJI: "Ryuji Ryuichi",
	Characters.SHIRO: "Shiro Sakamoto",
	Characters.AYANA: "Ayana Susume",
	Characters.REINA: "Reina Watanabe",
	Characters.REN: "Ren Watanabe",
	Characters.GOKI: "Gōki Yoshiaki",
	Characters.DAIYA: "Daiya Adelaide",
	Characters.NAOMI: "Naomi Anttonen",
	Characters.WILLOW: "Willow Asher",
	Characters.IKUE: "Ikue Fuyumi",
	Characters.SEBASTIAN: "Sebastian Kagaku",
	Characters.MADAME: "The Madame",
	
	# Alt. Characters
	Characters.SHIZUKA: "Shizuka Yukino",
	
	# Secondary Characters
	
	# Tertiary Characters
}

func get_file_name(file) -> String: ## Gets the name of a file from its path.
	return file.resource_path.get_file().get_basename()

func stop_music(fade_time:int) -> void: ## Stops currently playing music.
	if not music_player.playing: return # if music is not playing, dont do anything
	
	# create fade out effect
	var volume_tween = create_tween().set_parallel(true)
	volume_tween.tween_property(music_player, "volume_linear", 0, fade_time)
	await volume_tween.finished
	
	# stop the music, update the music in the game data, revert the tween
	music_player.stop()
	music_player.volume_linear = 1
	game_data.CurrentMusic = ""
	
	# wait a little more (this is only usually relevant if the function is being called from the music playing function)
	await get_tree().create_timer(1).timeout

func play_music(music:AudioStream) -> void: ## Plays the provided music track.
	# stop and fade out the previous track if a track is already playing
	if music_player.playing:
		await stop_music(1.5)
	
	# play the music! and update it on the data module
	music_player.stream = music
	music_player.play()
	game_data.CurrentMusic = get_file_name(music)

func play_sfx(sfx:AudioStream) -> void: ## Plays the provided sound effect.
	sfx_player.stream = sfx
	sfx_player.play()

func play_voiceline(voiceline:AudioStream) -> void: ## Plays the provided voiceline.
	voice_player.stream = voiceline
	voice_player.play()

func get_character_name(char_ID:int) -> String: ## Returns the selected character's name from their enum ID.
	return Characters.keys()[char_ID].to_lower()

func get_character_ID(char_name:String) -> int: ## Returns the selected character's name from their enum ID.
	return Characters.keys().find(char_name.to_upper())

func get_chapter_state_name() -> String: ## Returns the chapter + state combo based on the current data. Used primarily to feed the area module information on which area state to load.
	return "CH" + str(game_data.CurrentChapter) + "_" + game_data.CurrentState
	# area/state example: CH69_sigma_fortnite_balls

func get_resource_properties(resource:Resource): ## Returns the valid properties of a given resource.
	var property_array = [] # stores found properties
	
	for property in resource.get_property_list():
		if not "type" in property or not (property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE) or not (property["usage"] & PROPERTY_USAGE_STORAGE): continue # filters out anything that isn't an explicitly defined variable in the resource
		property_array.append(property) # adds to list of valid properties
	
	return property_array # returns simple list of every found property

func _ready() -> void:
	ServiceLocator.register_service("GeneralModule", self) # registers module in service locator automatically
