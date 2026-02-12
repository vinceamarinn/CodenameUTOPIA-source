extends Resource
class_name EventData

enum EventType {
	#region General category events
	GENERAL_PRINT_TEXT, ## Debug action. Simply prints the text on the interactable data.
	#endregion
	
	#region Area category events
	AREA_LOAD_AREA, ## Calls the area module to load a new area.
	#endregion
	
	#region Dialogue category events
	DIALOGUE_READ_DIALOGUE, ## Calls the dialogue module to iterate through a dialogue tree.
	#endregion
	
	#region Audio category events
	AUDIO_PLAY_MUSIC, ## Plays the provided music track.
	AUDIO_STOP_MUSIC, ## Stops the current music track.
	AUDIO_PLAY_SFX, ## Plays the provided sound effect.
	AUDIO_PLAY_VOICELINE, ## PLays the provided voiceline.
	#endregion
	
	#region Trial events
	TRIAL_START_TRIAL, ## Calls the Data/State module to begin a new trial.
	#endregion
}

@export var event_type:EventType = EventType.GENERAL_PRINT_TEXT ## Chooses which event to perform through the event module.
@export var event_data:Dictionary[String, Variant] ## Data to pass as arguments for the chosen event.

## Determines when the event will trigger automatically. Only used during dialogue lines.
##[br][br]
##[b]None:[/b] The event does not trigger automatically during the dialogue.
##[br][br][b]On Start:[/b] The event triggers immediately before the dialogue line is processed.
##[br][br][b]On End:[/b] The event triggers immediately after the dialogue is processed.
##[br][br][b]On Continue:[/b] The event triggers after the dialogue is processed, and after the player confirms to move to the next line. 
@export_enum("None", "On Start", "On End", "On Continue") var EventTriggerCondition = "None"
