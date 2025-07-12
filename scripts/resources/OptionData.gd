extends Resource
class_name OptionData

@export_group("General Settings")
@export_range(1, 5, 1) var TextScrollSpeed:int = 3

@export_subgroup("Volume")
@export_range(0, 1, 0.01) var MusicVolume:float = 1 ## Changes the overall volume of background music. Default is 100%.
@export_range(0, 1, 0.01) var SFXVolume:float = 1 ## Changes the overall volume of sound effects. Default is 100%.
@export_range(0, 1, 0.01) var VoiceVolume:float = 1 ## Changes the overall volume of voicelines. Default is 100%.

@export_group("Keybinds")
