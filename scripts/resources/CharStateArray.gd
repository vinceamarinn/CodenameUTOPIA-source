@tool
extends Resource
class_name CharStateArray

@export var character_state_array:Array[CharState] ## Array of character states.
@export var global_offset:Vector3 = Vector3(0,0,0) ## Sets the global position offset, added on top of the character offsets.
@export var on_enter_event:EventData ## Event that fires once the area is loaded.
