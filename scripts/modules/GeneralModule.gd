extends Node

##### GENERAL MODULE #####
# Contains general-use functions that wouldn't warrant their own module, and also stores global game information such as the Character List.

#game tree goodies we need
@onready var GameMain = get_node("/root/GameMain")

@onready var audio_busses:Node = get_node("/root/GameMain/AudioBusses")
@onready var music_player:AudioStreamPlayer = audio_busses.get_node("MusicPlayer")
@onready var sfx_player:AudioStreamPlayer = audio_busses.get_node("SFXPlayer")
@onready var voice_player:AudioStreamPlayer = audio_busses.get_node("VoicePlayer")

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


func debug_message(sender:String, type:String, reason:String, content:String)  -> void: ## Creates a detailed log message in the output through a print. Includes the script that reported it, the type of the message, and its content. Types include - Warning, Error, and Info (not case sensitive).
	# estabilish default message format
	var msg = "[" + type.to_upper() + "] " + reason + " " + content + " (sent by " + sender + ")"
	
	# match logging method based on type (non case sensitive!)
	match type.to_lower():
		"error":
			push_error(msg)
		"warning":
			push_warning(msg)
		"info":
			print(msg)

func get_file_name(file:Variant) -> String: ## Gets the name of a file from its path.
	return file.resource_path.get_file().get_basename()

func load_minigame(minigame_path:String, node_parent:Node) -> Node: ## Attaches a chosen minigame handler script to a new base node in order to load it. Returns said node.
	# gets the script's name
	var new_path = "res://scripts/" + minigame_path
	
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

func get_character_name(char_ID:int) -> String: ## Returns the selected character's name from their enum ID.
	return Characters.keys()[char_ID].to_lower()

func get_character_ID(char_name:String) -> int: ## Returns the selected character's name from their enum ID.
	return Characters.keys().find(char_name.to_upper())

func get_character_known_name(char_info:Characters) -> String: ## Returns the selected character's known name.
	return known_names_list[char_info]

func get_enum_string(my_enum:Dictionary, enum_id:int) -> String: ## Returns the string name of an enum element.
	return my_enum.keys()[enum_id]

func get_resource_properties(resource:Resource): ## Returns the valid properties of a given resource.
	var property_array = [] # stores found properties
	
	for property in resource.get_property_list():
		if not "type" in property or not (property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE) or not (property["usage"] & PROPERTY_USAGE_STORAGE): continue # filters out anything that isn't an explicitly defined variable in the resource
		property_array.append(property) # adds to list of valid properties
	
	return property_array # returns simple list of every found property

func load_metadata_file(file_name) -> Dictionary: ## Loads the provided metadata .json file and returns its data as a dictionary. The dictionary will be empty if the data failed to load.
	var loaded_data = {}
	var metadata_file = FileAccess.open("res://scripts/metadata/" + file_name, FileAccess.READ)
	
	if metadata_file:
		# create new json reader, and check for valid data
		var json_reader = JSON.new()
		var parse_result = json_reader.parse(metadata_file.get_as_text())
		
		# load json data
		if parse_result == OK:
			loaded_data = json_reader.data
		else:
			debug_message("GeneralModule - load_metadata_file()", "error", "Failed to parse the " + file_name + " metadata file!", json_reader.get_error_message())
	else:
		debug_message("GeneralModule - load_metadata_file()", "error", "Failed to load the " + file_name + " metadata file!", "Could not find/load the file.")
	
	return loaded_data
