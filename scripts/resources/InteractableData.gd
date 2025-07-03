extends Resource
class_name InteractableData

enum InteractableType { ## List of possible interaction types.
	ON_INTERACT, ## Triggers a pop-up when in range. The interaction is triggered if the player presses the interact key while the popup is visible.
	ON_TOUCH, ## The interaction is triggered immediately upon entering the range of the interactable.
}

enum InteractAction {
	PRINT_TEXT, ## Debug action. Simply prints the text on the interactable data.
	LOAD_AREA, ## Calls the area module to load a new area.
}

@export var interactable_type:InteractableType ## Type of interaction that triggers the interactable. being met.
@export var interact_action:InteractAction ## Action executed upon meeting the interaction requirements.
@export var action_data:Dictionary[String, Variant] ## Data to pass as arguments for the chosen action.
@export var interaction_range:float = 0 ## Range of the interactable's collision detector. If left at 0 or negative, will not apply.
