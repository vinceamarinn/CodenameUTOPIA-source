extends Node

#game tree goodies we need
@onready var GameMain = get_node("/root/GameMain")

@onready var audio_busses:Node = get_node("/root/GameMain/AudioBusses")
@onready var music_player:AudioStreamPlayer = audio_busses.get_node("MusicPlayer")
@onready var sfx_player:AudioStreamPlayer = audio_busses.get_node("SFXPlayer")
@onready var voice_player:AudioStreamPlayer = audio_busses.get_node("VoicePlayer")

# This module handles more generic things that do not need their own specified module, or things that don't fall into any specific module.
# It also stores global variables like the character list, for everyone's use.

enum Characters { ## Very important list of all registered characters. Used in any resources that require you to select a character.
	#region Main Characters - the 16 participants of the game & the enforcer.
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
	#endregion
	
	#region Alt. Characters - alternative versions of characters (something like Yuuto with pajamas on instead, for example).
	SHIZUKA,
	#endregion
	
	#region Secondary Characters - characters who appear in the story besides the main characters with a good amount of appearances.
	EDWIN,
	SCHAEFFER,
	#endregion
	
	#region Tertiary Characters - characters who only appear in the story for a few specific scenes.
	KAORU,
	#endregion
}

enum PlayableChars { ## Enum list of characters you are able to play as.
	YUUTO,
	YUUKA
}

const DEATH_REGISTRY:Dictionary = { ## Acts as the game's internal death registry. Used for the funny pre-trial 4th wall breaking bit.
	# it's read as: by trial <key>, these people have died: [names]
	# so for example, by trial 2, naomi, shiro and ryuji have died
	1: ["naomi"],
	2: ["shiro", "ryuji"],
	3: ["sukai", "ayana", "ren"],
	4: ["reina", "daiya"],
	5: ["lance", "kazuhito", "yuuto"],
	6: ["sebastian"],
}

var known_names_list:Dictionary = { ## Dictionary assigning every character to their known name.
	#region # Main Characters
	Characters.YUUTO: tr("Yuuto Katashi"),
	Characters.YUUKA: tr("Yuuka Katashi"),
	Characters.LANCE: tr("Lance Katsunosuke"),
	Characters.KAZUHITO: [tr("'Kazuhito'"), tr("Kazuhito Kobayashi")],
	Characters.SUKAI: tr("Sukai Manato"),
	Characters.RYUJI: tr("Ryuji Ryuichi"),
	Characters.SHIRO: tr("Shiro Sakamoto"),
	Characters.AYANA: tr("Ayana Susume"),
	Characters.REINA: tr("Reina Watanabe"),
	Characters.REN: tr("Ren Watanabe"),
	Characters.GOKI: tr("Gōki Yoshiaki"),
	Characters.DAIYA: tr("Daiya Adelaide"),
	Characters.NAOMI: tr("Naomi Anttonen"),
	Characters.WILLOW: tr("Willow Asher"),
	Characters.IKUE: tr("Ikue Fuyumi"),
	Characters.SEBASTIAN: tr("Sebastian Kagaku"),
	Characters.MADAME: tr("The Madame"),
	#endregion
	
	#region # Alt. Characters
	Characters.SHIZUKA: tr("Shizuka Yukino"),
	#endregion
	
	#region # Secondary Characters
	Characters.EDWIN: tr("Edwin Winfield"),
	Characters.SCHAEFFER: tr("'Schaeffer'"),
	#endregion
	
	#region # Tertiary Characters
	Characters.KAORU: tr("Kaoru Nakajima"),
	#endregion
}

var song_database:Dictionary = {} ## Stores song metadata from scripts/metadata/music.json. Gets filled in when the module boots.

func debug_message(sender:String, type:String, reason:String, content:String)  -> void: ## Creates a detailed log message in the output through a print. Includes the script that reported it, the type of the message, and its content. Types include - Warning, Error, and Info (not case sensitive).
	var msg = "[" + type.to_upper() + "] " + reason + " " + content + " (sent by " + sender + ")"
	
	match type.to_lower():
		"error":
			push_error(msg)
		"warning":
			push_warning(msg)
		"info":
			print(msg)
	print("shoulda done the message")

func get_file_name(file) -> String: ## Gets the name of a file from its path.
	return file.resource_path.get_file().get_basename()

func load_minigame(minigame_path:String, node_parent:Node) -> Node: ## Attaches a chosen minigame handler script to a new base node in order to load it. Returns said node.
	var new_path = "res://scripts/" + minigame_path # gets the script's name
	
	# creates the holder node & loads requested script
	var new_node = Node.new()
	var new_script = load(new_path)
	
	# names the node & attaches the script to it
	new_node.name = get_file_name(new_script)
	new_node.set_script(new_script)
	
	# parents the script holder node to the requested parent node
	node_parent.add_child(new_node)
	
	# returns the script holder node
	return new_node

func stop_music(fade_time:float) -> void: ## Stops currently playing music.
	if not music_player.playing: return # if music is not playing, dont do anything
	
	# create fade out effect
	var volume_tween = create_tween().set_parallel(true)
	volume_tween.tween_property(music_player, "volume_linear", 0, fade_time)
	await volume_tween.finished
	
	# stop the music, update the music in the game data, revert the tween
	music_player.stop()
	music_player.volume_linear = 1
	DataStateModule.game_data.CurrentMusic = ""

func play_music(music:AudioStream) -> void: ## Plays the provided music track.
	# stop and fade out the previous track if a track is already playing
	if music_player.playing:
		await stop_music(3)
		await get_tree().create_timer(.5).timeout
	
	# play the music! and update it on the data module
	music_player.stream = music
	music_player.play()
	
	# get song name and update the current state's music
	var song_name = get_file_name(music)
	DataStateModule.game_data.CurrentMusic = song_name
	
	# display song metadata if available
	if song_database.has(song_name):
		# get song data
		var song_data = song_database[song_name]
		var title = song_data.get("title", "Unknown title...")
		var artist = song_data.get("artist", "Unknown artist...")
		
		# print song data
		print("♪ Now Playing: ", title, " by ", artist)

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

func get_character_known_name(char_info:Characters) -> String: ## Returns the selected character's known name.
	return known_names_list[char_info]

func get_enum_string(my_enum:Dictionary, enum_id:int) -> String:
	return my_enum.keys()[enum_id]

func get_resource_properties(resource:Resource): ## Returns the valid properties of a given resource.
	var property_array = [] # stores found properties
	
	for property in resource.get_property_list():
		if not "type" in property or not (property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE) or not (property["usage"] & PROPERTY_USAGE_STORAGE): continue # filters out anything that isn't an explicitly defined variable in the resource
		property_array.append(property) # adds to list of valid properties
	
	return property_array # returns simple list of every found property

func load_song_database(): ## Loads the music.json metadata file into the song database. Doesn't return it, as this information is used here - there's no need.
	var metadata = FileAccess.open("res://scripts/metadata/music.json", FileAccess.READ)
	
	if metadata:
		var json = JSON.new()
		var parse_result = json.parse(metadata.get_as_text())
		
		if parse_result == OK:
			song_database = json.data
		else:
			debug_message("GeneralModule - load_song_database()", "error", "Failed to parse the song data JSON!", json.get_error_message())
	else:
		debug_message("GeneralModule - load_song_database()", "error", "Failed to load the song database!", "Could not find the music.json metadata file!")

func get_developer_credits() -> Dictionary: ## Loads the dev_credits.json metadata file, and returns it.
	var dev_name_list = {}
	var metadata = FileAccess.open("res://scripts/metadata/dev_credits.json", FileAccess.READ)
	
	if metadata:
		var json = JSON.new()
		var parse_result = json.parse(metadata.get_as_text())
		
		if parse_result == OK:
			dev_name_list = json.data
		else:
			debug_message("GeneralModule - get_developer_credits()", "error", "Failed to parse the developer crediting list JSON!", json.get_error_message())
	else:
		debug_message("GeneralModule - get_developer_credits()", "error", "Failed to load the developer crediting list!", "Could not find the dev_credits.json metadata file!")
	
	return dev_name_list

func _ready() -> void:
	load_song_database()
	ServiceLocator.register_service("GeneralModule", self) # registers module in service locator automatically
