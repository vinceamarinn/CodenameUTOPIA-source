extends Resource
class_name SaveStateData

@export_group("Story Data")
@export var CurrentChapter:int = 0 ## Tracks the current chapter of the game.
@export var CurrentState:String = "" ## Tracks the current state name of the game.
@export var PlayerCharacter:GeneralModule.PlayableChars = GeneralModule.PlayableChars.YUUTO ## Tracks your currently selected playable character in overworld sections.

@export_group("Game State Data")
@export var CurrentMap:String = "" ## Tracks the area in which you last saved your game.
@export var CurrentMusic:String = "" ## Tracks the song that was playing when you last saved your game.
@export var RemovedCharacters:Dictionary[String, Array] = {} ## Stores the names of any characters who were removed from the last-saved area state.

@export_group("Progression Flag Data")
@export var KazuhitoRevealed:bool = false ## Determines whether or not Kazuhito has ever revealed his true name.

@export_group("Player Data")
@export var ClueInventory:Array[Clue] = [] ## Tracks your current clue inventory.
