extends Resource
class_name DialogueTree

@export var TreeData:Array[DialogueDict] ## The dialogue tree. Not much to say here.
## Determines the behavior of the tree once it reaches its final dialogue array. [br][br]Setting it to false means the tree will repeat the final dictionary of dialogue upon repeated interactions, while setting it to true will start the tree again from the start.
@export var LoopTree:bool = false

var dict_tracker:int = 0 ## Tracks which dict of dialogue should be played and read through. The loop_tree variable essentially changes the logic of this value.

@export_group("Developer Extras")
@export_multiline var DeveloperNote:String = "" ## Just a holder for any necessary developer notes. Does nothing in practice.
