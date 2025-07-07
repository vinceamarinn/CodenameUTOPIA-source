extends Resource
class_name SaveData

const RESOURCE_NAME = "SaveData"

@export_group("Story Data")
@export var CurrentChapter:int = 0 ## Tracks the current chapter of the game.
@export var CurrentState:String = "" ## Tracks the current state name of the game.
@export var PlayerCharacter:GeneralModule.PlayableChars = GeneralModule.PlayableChars.YUUTO ## Tracks your currently selected playable character in overworld sections.

@export_group("State Data")
@export var CurrentMap:String = "" ## Tracks the area in which you last saved your game.
@export var CurrentMusic:String = "" ## Tracks the song that was playing when you last saved your game.
@export var CharacterStateOverride:Array[String] = [] ## Tracks any changes in the character list of a given area.

@export_group("Player Data")
@export var ClueInventory:Array[Clue] = []
