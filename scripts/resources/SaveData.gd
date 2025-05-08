extends Resource
class_name SaveData

@export_group("Story Data")
@export var CurrentChapter:int
@export var CurrentState:String
@export var PlayerCharacter:GeneralModule.PlayableChars

@export_group("Player Data")
@export var ClueInventory:Array[Clue] = []
