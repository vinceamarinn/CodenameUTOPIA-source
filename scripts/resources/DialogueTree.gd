extends Resource
class_name DialogueTree

@export var dialogue_tree:Array[DialogueArray] ## Array of dialogue arrays. Each dialogue array is one sequence of dialogue. The tree will iterate one array at a time.
@export var loop_tree:bool = false ## Makes the dialogue tree loop once it reaches the final array. If left false, attempting to repeat dialogue plays the final array. Will obviously have no effect if the tree is only one array long.
var array_tracker:int = 0 ## Tracks which array should be played. Automatically changes when dialogue iterates.
