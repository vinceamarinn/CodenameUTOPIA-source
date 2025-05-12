extends Resource
class_name OptionData

const RESOURCE_NAME = "OptionData"

@export_group("General Settings")
@export_subgroup("Volume")
var music_volume:float = 1
var sfx_volume:float = 1
var voice_volume:float = 1

@export_range(0, 1, 0.01) var MusicVolume:float: ## Changes the overall volume of background music. Default is 100%.
	get: return music_volume
	set(value):
		music_volume = clamp(value, 0, 1)

@export_range(0, 1, 0.01) var SFXVolume:float: ## Changes the overall volume of sound effects. Default is 100%.
	get: return sfx_volume
	set(value):
		sfx_volume = clamp(value, 0, 1)

@export_range(0, 1, 0.01) var VoiceVolume:float: ## Changes the overall volume of voicelines. Default is 100#.
	get: return voice_volume
	set(value):
		voice_volume = clamp(value, 0, 1)

@export_group("Keybinds")
