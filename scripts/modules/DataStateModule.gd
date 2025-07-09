extends Node

@export var game_data:SaveStateData = SaveStateData.new()
@export var option_data:OptionData = OptionData.new()

func get_data_path(data_file:Resource) -> String: ## Returns the default save data path.
	return "user://" + GeneralModule.get_file_name(data_file.get_script()) + ".cfg"
	# default path example: user://SaveStateData.cfg

func set_property(data_file:Resource, property:String, new_value) -> void: ## Sets the new value of a data structure's property.
	if not property in data_file: return # don't execute if property is not found
	if data_file.get(property) == new_value: return # don't execute if the value is unchanged
	
	data_file.set(property, new_value)

func save_data(data_file:Resource) -> bool: ## Saves the game.
	var config_file = ConfigFile.new() # create config file for editing
	var property_list = GeneralModule.get_resource_properties(data_file) # get properties of the data file
	
	for property in property_list:
		if property["name"] == "ClueInventory": # if array of objects that needs to be treated:
			var clue_array = [] # array to save later
			for clue in data_file.get(property["name"]):
				clue_array.append(clue.serialize()) # add serialized (converted to dictionary) versions of the clues in the inventory to the array
			
			config_file.set_value("Save State Data", property["name"], clue_array) # save the array into config file
		else: #if it needs no treatment:
			config_file.set_value("Save State Data", property["name"], data_file.get(property["name"])) # save property into config file
	
	config_file.save(get_data_path(data_file)) # save config to real file!
	return true

func load_data(data_file:Resource) -> bool: ## Loads selected save data file.
	var data_path = get_data_path(data_file) # get data path of provided data file
	if not FileAccess.file_exists(data_path): return false # if we cant find it, return false
	
	var config_file = ConfigFile.new() # open new config file
	var loaded_data = config_file.load(data_path) # load existing data file into empty config file
	if loaded_data != OK: return false # failed to load, don't run
	
	var property_list = GeneralModule.get_resource_properties(data_file) # get list of properties in the data file
	for property in property_list:
		var property_value = config_file.get_value("Save State Data", property["name"]) # get correspondant inside config file
		
		if property["name"] == "ClueInventory": # if array of objects that needs to be treated:
			var new_inv:Array[Clue] = [] # array to load later
			
			for clue_dict in property_value:
				new_inv.append(Clue.create_from_dict(clue_dict)) # re-convert any dictionary clues into actual clue objects
			
			set_property(data_file, property["name"], new_inv) # load the clue inventory
			
		else:
			set_property(data_file, property["name"], property_value) # load the property!
	
	if data_file == game_data: # if we're loading the game, run basic initialization process
		var state_name = GeneralModule.get_chapter_state_name() # get current area/state
		AreaModule.load_area(game_data.CurrentMap, state_name, game_data.PlayerCharacter) # load area from state
		
		if game_data.CurrentMusic != "": # load current music and play it
			GeneralModule.play_music(load("res://audio/music/" + game_data.CurrentMusic + ".ogg")) # play last saved music
	
	return true # if everything goes right then return true

func _ready() -> void:
	ServiceLocator.register_service("DataModule", self) # registers module in service locator automatically
	var err = load_data(game_data)
	print("save data loaded successfully? ", err)
