extends Resource
class_name EventData

enum EventType {
	# general use
	PRINT_TEXT, ## Debug action. Simply prints the text on the interactable data.
	
	# area related
	LOAD_AREA, ## Calls the area module to load a new area.
	
	# dialogue related
	READ_DIALOGUE, ## Calls the dialogue module to iterate through a dialogue tree.
}

@export var event_type:EventType ## Chooses which event to perform through the event module.
@export var event_data:Dictionary[String, Variant] ## Data to pass as arguments for the chosen esvent.
