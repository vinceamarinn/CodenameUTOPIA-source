extends Node

#game tree goodies we need
@onready var GameMain = get_node("/root/GameMain")

@export var game_data:SaveStateData = SaveStateData.new()
@export var option_data:OptionData = OptionData.new()

func get_data_path(data_file:Resource) -> String: ## Returns the default save data path.
	return "user://" + GeneralModule.get_file_name(data_file.get_script()) + ".tres"
	# default path example: user://SaveStateData.tres

func get_chapter_state_name() -> String: ## Returns the chapter + state combo based on the current data. Used primarily to feed the area module information on which area state to load.
	return "CH" + str(game_data.CurrentChapter) + "_" + game_data.CurrentState
	# area/state example: CH69_sigma_fortnite_balls

func check_if_trial() -> bool: ## Verifies if the game is currently in trial mode (indicating we're in-a courtroom trial).
	return game_data.StoryFlags["IsTrial"] == true

func start_trial(trial_ID:int) -> void: ## Initiates the Trial Handler in order to begin a new trial. If the number provided is '0', it will load the current chapter's trial.
	var trial_handler = GeneralModule.load_script_into_node("trial/TrialHandler.gd", GameMain) # loads trial handler into new node at GameMain
	
	# if the trial ID is 0, the trial handler will load the trial of the current chapter
	if trial_ID == 0:
		trial_ID = game_data.CurrentChapter
	
	trial_handler.initialize_trial(trial_ID, false) # initializes the trial handler

func save_data(data_file:Resource) -> bool: ## Saves the game.
	# define warning in the save data (for anyone who tries to edit it)
	data_file.WARNING = "[DISCLAIMER]\nYou, yes - you!\nEditing the following file may cause PERMANENT damage to your save file and corrupt it completely, which will make you lose ALL of your progress!\nIf you still want to edit the information in these files, do so at your own risk.\nAlso, do not EVER download save files from untrustworthy sources! If you need a new save file, please get one from an official source.\nOtherwise, you'll run the risk of running into a save file that may inject harmful software & things of the sort into your device!\n\nAnd if you still stuck around after the warning, well... good luck with the editing!\n"
	
	# attempt to save to file
	var err = ResourceSaver.save(data_file, get_data_path(data_file))
	
	# if failed, log error
	if err != OK:
		GeneralModule.debug_message("DataStateModule - save_data()", "error", "Failed to save the " + data_file.resource_name + " data resource!", "Something went wrong with the Resource Saver.")
		return false
	
	# no error! confirm data has saved!
	return true

func load_data(data_file:Resource) -> bool: ## Loads selected save data file.
	var data_path = get_data_path(data_file) # get data path of provided data file
	if not FileAccess.file_exists(data_path): # if we cant find it, return false
		GeneralModule.debug_message("DataStateModule - load_data()", "error", "Failed to load the " + data_file.resource_name + " data resource!", "The file doesn't exist, there's no save to load.")
		return false
	
	# attempt to load data from file
	var loaded_data = ResourceLoader.load(data_path)
	if loaded_data == null:
		GeneralModule.debug_message("DataStateModule - save_data()", "error", "Failed to load the " + data_file.resource_name + " data resource!", "Something went wrong with the Resource Loader.")
		return false
	
	# load the corresponding data into the module's existing data
	if data_file == game_data:
		game_data = loaded_data
	elif data_file == option_data:
		option_data = loaded_data
	
	return true # if everything goes right then return true

func _ready() -> void:
	ServiceLocator.register_service("DataModule", self) # registers module in service locator automatically
	var err = load_data(game_data)
	print("save data loaded successfully? ", err)
	var err2 = load_data(option_data)
	print("option data loaded successfully? ", err2)
	
	print("are we in a trial? ", check_if_trial())
	if err:
		var state_name = get_chapter_state_name() # get current area/state
		AreaModule.load_area(game_data.CurrentMap, state_name, true, true, false) # load area from state
		
		if game_data.CurrentMusic != "": # load current music and play it
			GeneralModule.play_music(load("res://audio/music/" + game_data.CurrentMusic + ".ogg")) # play last saved music
	
	# update kazuhito's name based on story flags
	var known_names_list = GeneralModule.known_names_list
	var kazuhito_names = known_names_list[GeneralModule.Characters.KAZUHITO]
	if game_data.StoryFlags.has("KazuhitoRevealed"):
		known_names_list[GeneralModule.Characters.KAZUHITO] = kazuhito_names[1]
		print("kazuhito is revealed")
	else:
		known_names_list[GeneralModule.Characters.KAZUHITO] = kazuhito_names[0]
		print("kazuhito is hidden")
	
	#TranslationServer.set_locale("pt")
