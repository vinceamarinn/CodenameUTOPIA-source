extends Area3D
class_name Interactable

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

func execute_action():
	
	match interact_action:
		InteractAction.PRINT_TEXT:
			var print_text = action_data.get("print_text")
			print(print_text)
		InteractAction.LOAD_AREA:
			print("sigmund freud")
		_:
			pass

func _on_body_entered(body: Node3D) -> void:
	if not body is PlayerOverworld: return
	print(body.name, " entered interaction range")
	
	match interactable_type:
		InteractableType.ON_TOUCH:
			print("should trigger interaction event")
			execute_action()
		InteractableType.ON_INTERACT:
			print("should create popup to trigger event on interaction")
		_:
			pass

func _on_body_exited(body: Node3D) -> void:
	if not body is PlayerOverworld: return
	print(body.name, " left interaction range")
	
	if interactable_type == InteractableType.ON_INTERACT:
		print("should destroy popup")
