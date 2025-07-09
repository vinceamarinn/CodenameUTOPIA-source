@tool
extends Resource
class_name CharStateArray

@export var character_state_array:Array[CharState] ## Array of character states.
@export var on_enter_dialogue:DialogueArray ## Dialogue array that plays at the start of the state.
