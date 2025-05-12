extends Resource
class_name SaveData

const RESOURCE_NAME = "SaveData"

@export_group("Story Data")
@export var CurrentChapter:int = 0
@export var CurrentState:String = ""
@export var CurrentMap:String = ""
@export var PlayerCharacter:GeneralModule.PlayableChars = GeneralModule.PlayableChars.YUUTO

@export_group("Player Data")
@export var ClueInventory:Array[Clue] = []
