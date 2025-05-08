extends Node

var game_data:SaveData = SaveData.new()
var option_data:OptionData = OptionData.new()

func save_data(data_file): ## Saves the game.
	pass

func load_data(data_file:String): ## Loads selected save data file.
	pass

func _ready() -> void:
	ServiceLocator.register_service("DataModule", self) # registers module in service locator automatically
