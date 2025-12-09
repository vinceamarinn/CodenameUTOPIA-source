extends Resource
class_name OptionData

@export_group("General Settings")

@export_group("Text Settings")
@export var DialogueLogLimit:int = 100 ## Determines how many lines of dialogue can be stored in the dialogue logs. Reduce this number to save memory.

@export_subgroup("Text Scrolling Settings")
@export_range(1, 5, 1) var TextScrollSpeed:int = 3 ## Controls how fast the text scrolls during dialogue.
@export var Autoscroll:bool = false ## Determines whether or not dialogue text automatically continues after a few seconds.
@export_range(0.5, 2.5, 0.5) var AutoscrollTimer:float = 1.5 ## Determines how long it takes for the autoscroll to continue.

@export_subgroup("Text Color Settings")


@export_group("Visual Settings")
@export var MaxFPS:int = 60 ## Maximum FPS counter the game may have.
@export var FPSCounter:bool = false ## Displays your current framerate.
@export_enum("Enabled", "Adaptive", "Disabled") var VSync:String = "Adaptive" ## Determines the behavior of V-Sync. V-Sync attempts to adapt the game's frame rate with the monitor's refresh rate, eliminating some visual artifacts (such as screen tearing), but sacrificing a little performance.
@export_enum("Windowed", "Fullscreen", "BorderlessFullscreen") var WindowMode:String = "BorderlessFullscreen" ## Sets the mode of the game window.

@export_group("Audio Settings")
@export_range(0, 1, 0.01) var MasterVolume:float = 1 ## Changes the volume of the entire game.
@export_range(0, 1, 0.01) var MusicVolume:float = 1 ## Changes the overall volume of background music. Default is 100%.
@export_range(0, 1, 0.01) var SFXVolume:float = 1 ## Changes the overall volume of sound effects. Default is 100%.
@export_range(0, 1, 0.01) var VoiceVolume:float = 1 ## Changes the overall volume of voicelines. Default is 100%.

@export_group("Keybind Settings")


@export_group("Language Settings")
@export var Language:String = "en" ## Language of the game text.
