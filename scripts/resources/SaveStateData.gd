extends Resource
class_name SaveStateData

@export var WARNING:String = "" ## String that contains a warning message. It gets applied during saving, so users have a disclaimer before attempting to edit their save file.

@export_group("Story Data")
@export var CurrentChapter:int = 0 ## Tracks the current chapter of the game.
@export var CurrentState:String = "sigmund" ## Traawdscks the current state name of the game.
@export var PlayerCharacter:GeneralModule.PlayableChars = GeneralModule.PlayableChars.YUUTO ## Tracks your currently selected playable character in overworld sections.

#story flags
@export var StoryFlags:Dictionary = { ## Contains a dictionary of story-specific flags, to track whether certain things have been achieved.
	"IsTrial" : false, ## Tracks whether you're in a trial or not.
	"DeathRegistry" : [], ## Tracks the deaths of characters who have died. You can edit back in your favorite characters lmaooooooo
}

@export_group("Game State Data")
@export var CurrentMap:String = "TestArea" ## Tracks the area in which you last saved your game.
@export var CurrentMusic:String = "Beautiful1" ## Tracks the song that was playing when you last saved your game.
@export var RemovedCharacters:Dictionary[String, Array] = {} ## Stores the names of any characters who were removed from the last-saved area state.

@export_group("Player Data")
@export var ClueInventory:Array[Clue] = [] ## Tracks your current clue inventory.
