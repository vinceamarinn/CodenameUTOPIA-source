extends Resource
class_name EventData

enum EventTypes {
	#region General category events
	GENERAL_PRINT_MSG, ## Debug action. Simply prints the message through the General Module 
	#endregion
	
	#region Area category events
	AREA_LOAD_AREA, ## Calls the Area Module to load a new area.
	#endregion
	
	#region Dialogue category events
	DIALOGUE_READ_DIALOGUE, ## Calls the Dialogue Module to iterate through a dialogue tree.
	#endregion
	
	#region Audio category events
	AUDIO_PLAY_MUSIC, ## Calls the Audio Module to play the provided music track.
	AUDIO_STOP_MUSIC, ## Calls the Audio Module to stop the current music track.
	AUDIO_PLAY_SFX, ## Calls the Audio Module to play the provided sound effect.
	AUDIO_PLAY_VOICELINE, ## Calls the Audio Module to play the provided voiceline.
	#endregion
	
	#region Trial events
	TRIAL_START_TRIAL, ## Calls the Data/State Module to begin a new Courtroom Trial.
	#endregion
}

@export var EventType:EventTypes = EventTypes.GENERAL_PRINT_MSG ## Chooses which event to perform through the event module.
@export var EventDataList:Dictionary[String, Variant] ## Data to pass as arguments for the chosen event.

## Determines when the event will trigger automatically. Only used during dialogue lines.
##[br][br]
##[b]None:[/b] The event does not trigger automatically during the dialogue.
##[br][br][b]On Start:[/b] The event triggers immediately before the dialogue line is processed.
##[br][br][b]On End:[/b] The event triggers immediately after the dialogue is processed.
##[br][br][b]On Continue:[/b] The event triggers after the dialogue is processed, and after the player confirms to move to the next line. 
@export_enum("None", "On Start", "On End", "On Continue") var EventTriggerCondition = "None"
