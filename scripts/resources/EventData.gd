extends Resource
class_name EventData

enum EventType {
	# general use
	GENERAL_PRINT_TEXT, ## Debug action. Simply prints the text on the interactable data.
	
	# area related
	AREA_LOAD_AREA, ## Calls the area module to load a new area.
	
	# dialogue related
	DIALOGUE_READ_DIALOGUE, ## Calls the dialogue module to iterate through a dialogue tree.
}

@export var event_type:EventType ## Chooses which event to perform through the event module.
@export var event_data:Dictionary[String, Variant] ## Data to pass as arguments for the chosen event.

## Determines when the event will trigger automatically. Only used during dialogue lines.
##[br][br]
##[b]None:[/b] The event does not trigger automatically during the dialogue.
##[br][br][b]On Start:[/b] The event triggers immediately before the dialogue line is processed.
##[br][br][b]On End:[/b] The event triggers immediately after the dialogue is processed.
##[br][br][b]On Continue:[/b] The event triggers after the dialogue is processed, and after the player confirms to move to the next line. 
@export_enum("None", "On Start", "On End", "On Continue") var EventTriggerCondition = "None"
