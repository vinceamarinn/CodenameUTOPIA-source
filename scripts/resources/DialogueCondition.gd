extends Resource
class_name DialogueCondition

enum ConditionTypes { ## Stores the list of valid condition types.
	FLAG,
	PLAYER_IS,
	HAS_CLUE
}

enum FailActions { ## Stores the list of valid failure actions.
	SKIP,
	BREAK,
	JUMP_TO
}

## Type of condition that needs to be met for the dialogue asset to be processed.
##[br][br][b]Flag:[/b] This asset will only be read if the provided flag is true/false.
##[br][b]Player Is:[/b] This asset will only be read if the player character matches the required character. Useful for internal monologue.
##[br][b]Has Clue:[/b] This asset will only be read if the player has a certain Clue in their Clue Inventory.
@export var ConditionType:ConditionTypes = ConditionTypes.FLAG

## Dictates what happens if the condition is not met.
##[br][br][b]Skip:[/b] The Dialogue module will skip to the next line in the queue.
##[br][b]Break:[/b] The processing will be aborted altogether.
##[br][b]Jump To:[/b] The dialogue will jump from the current Dialogue dictionary key to the specified one.
@export var FailAction:FailActions = FailActions.SKIP

@export_group("Condition Data")
@export var FlagName:String ## Name of the story flag to check the value of, if the condition type is Flag.
@export var FlagValue:bool ## Boolean value of the story flag that the condition check will pass with, if the condition type is Flag.
@export var RequiredPlayer:GeneralModule.PlayableChars ## Required Player character for the condition check to pass, if the condition type is PlayerIs.
@export var RequiredClueName:String ## Name of the required clue for the condition check to pass, if the condition type is HasClue.
@export var JumpToKey:String ## The dictionary key to jump to, if DoOnFail is set to JumpTo.
