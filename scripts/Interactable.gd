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

var is_within_range:bool = false ## Determines whether or not the player is within an interactable's range, in case it matters for activation conditions.
var interactable_fired:bool = false ## Locks the code from running again if the interactable has already been ran.

@export var interactable_type:InteractableType ## Type of interaction that triggers the interactable. being met.
@export var interact_action:InteractAction ## Action executed upon meeting the interaction requirements.
@export var action_data:Dictionary[String, Variant] ## Data to pass as arguments for the chosen action.

@onready var interaction_prompt:SpriteBase3D = $Prompt ## The prompt.

func execute_action():
	if interactable_fired: return
	interactable_fired = true
	
	match interact_action:
		InteractAction.PRINT_TEXT:
			var print_text = action_data.get("print_text")
			print(print_text)
		InteractAction.LOAD_AREA:
			var area_name = action_data.get("load_area")
			var state_name = GeneralModule.get_chapter_state_name()
			var playable_char = DataStateModule.game_data.PlayerCharacter
			AreaModule.load_area(area_name, state_name, playable_char)
		_:
			pass

func _input(event: InputEvent) -> void: # handle input for on_interact interactables
	if event.is_action_pressed("interact") and is_within_range == true:
		execute_action()

func _ready() -> void:
	# set up the interactable!!!
	if interactable_type == InteractableType.ON_TOUCH: return # no need to do this if it's a non interact interactable
	var interactable_parent = self.get_parent()
	interaction_prompt.position.y += interactable_parent.mesh.size.y/2 + 1 # position it accordingly to the size of the parent object
	interaction_prompt.visible = false

func _on_body_entered(body: Node3D) -> void:
	if not body is PlayerOverworld: return
	
	match interactable_type:
		InteractableType.ON_TOUCH:
			execute_action()
		InteractableType.ON_INTERACT:
			is_within_range = true
			interaction_prompt.visible = true
		_:
			pass

func _on_body_exited(body: Node3D) -> void:
	if not body is PlayerOverworld: return
	
	if interactable_type == InteractableType.ON_INTERACT:
		is_within_range = false
		interaction_prompt.visible = false
