extends Node

var game_data:SaveData = SaveData.new()
var option_data:OptionData = OptionData.new()

func get_data_path(data_file:Resource) -> String: ## Returns the default save data path.
	return "user://" + data_file.get("RESOURCE_NAME") + ".tres"

func set_property(data_file:Resource, property:String, new_value) -> void: ## Sets the new value of a data structure's property.
	if not property in data_file: return # don't execute if property is not found
	if data_file.get(property) == new_value: return # don't execute if the value is unchanged
	
	data_file.set(property, new_value)

func save_data(data_file:Resource) -> bool: ## Saves the game.
	var err = ResourceSaver.save(data_file, get_data_path(data_file))
	return(err == OK) # returns the result of the saving process

func load_data(data_file:Resource) -> bool: ## Loads selected save data file.
	if not ResourceLoader.exists(get_data_path(data_file)): return false # if we cant find it, return false
	
	var loaded_data = SafeResourceLoader.load(get_data_path(data_file)) # use safe resource loading plugin to check for malicious code
	if loaded_data == null: return false # bad code found, don't run
	
	for property in loaded_data.get_property_list():
		if not "type" in property or not (property["usage"] & PROPERTY_USAGE_SCRIPT_VARIABLE): continue # filters out anything that isn't an explicitly defined variable in the resource
		
		var property_name = property["name"]
		set_property(data_file, property_name, loaded_data.get(property_name))
	
	return true # if everything goes right then return true

func _ready() -> void:
	ServiceLocator.register_service("DataModule", self) # registers module in service locator automatically
	
	# TESTING
	print(game_data.CurrentChapter)
	print(option_data.MusicVolume)
	
	set_property(game_data, "CurrentChapter", 3)
	
	print("saving game...")
	var savegame = save_data(game_data)
	print("saving successful? ", savegame)
	print("loading game...")
	var loadgame = load_data(game_data)
	print("loading successful? ", loadgame)
	
	set_property(option_data, "MusicVolume", -2)
	set_property(option_data, "SFXVolume", 3)
	set_property(option_data, "VoiceVolume", 0.5)
	
	print("saving options...")
	var saveoption = save_data(option_data)
	print("saving successful? ", saveoption)
	print("loading options...")
	var loadoption = load_data(option_data)
	print("loading successful? ", loadoption)
