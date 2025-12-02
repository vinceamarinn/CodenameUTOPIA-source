extends Resource
class_name InteractableData

enum InteractableType {
	ON_TOUCH, ## The interactable triggers its event once its range is entered.
	ON_INTERACT, ## The interactable triggers its event once its range is entered, and a prompt is triggered.
}

@export var interactable_type:InteractableType ## Type of interaction that triggers the interactable. being met.
@export var interaction_range:float = 0 ## Range of the interactable's collision detector. If left at 0 or negative, will not apply.
@export var interactable_sfx:AudioStreamOggVorbis ## Sound effect that will play when the interactable is activated. If left blank, only the default sound will be played.
@export var interact_event:EventData ## Event executed upon meeting the interaction requirements.
