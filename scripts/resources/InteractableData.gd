extends Resource
class_name InteractableData

enum InteractableTypes {
	ON_TOUCH, ## The interactable triggers its event once its range is entered.
	ON_INTERACT, ## The interactable triggers its event once its range is entered, and a prompt is triggered.
}

@export var InteractableType:InteractableTypes ## Type of interaction that triggers the interactable. being met.
@export var InteractionRange:float = 0 ## Range of the interactable's collision detector. If left at 0 or negative, will not apply.
@export var InteractableSFX:AudioStreamOggVorbis ## Sound effect that will play when the interactable is activated. If left blank, only the default sound will be played.
@export var InteractEvent:EventData ## Event executed upon meeting the interaction requirements.
