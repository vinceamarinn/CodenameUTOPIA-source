extends Resource
class_name DialogueTree

@export var dialogue_tree:Array[DialogueArray] ## The dialogue tree. Not much to say here.
## Determines the behavior of the tree once it reaches its final dialogue array. [br][br]Setting it to false means the tree will repeat the final array of dialogue upon repeated interactions, while setting it to true will start the tree again from the start.
@export var loop_tree:bool = false
var array_tracker:int = 0 ## Tracks which array of dialogue should be played and read through. The loop_tree variable essentially changes the logic of this value.
