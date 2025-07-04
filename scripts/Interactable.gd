extends Area3D
class_name Interactable

var is_within_range:bool = false ## Determines whether or not the player is within an interactable's range, in case it matters for activation conditions.
var interactable_fired:bool = false ## Locks the code from running again if the interactable has already been ran.

@export var interactable_data:InteractableData ## Data resource for the interactable data. Read its documentation for what the values below do.
@onready var interactable_type = interactable_data.interactable_type
@onready var interact_action = interactable_data.interact_action
@onready var action_data = interactable_data.action_data
@onready var interaction_range = interactable_data.interaction_range

@onready var interaction_prompt:SpriteBase3D = $Prompt ## The prompt.

func show_prompt(on_off:bool) -> void: ## Handles popup animation.
	interaction_prompt.visible = on_off

func execute_action(): ## Executes the interaction action accordingly.
	if interactable_fired: return
	interactable_fired = true
	show_prompt(false)
	
	match interact_action:
		InteractableData.InteractAction.PRINT_TEXT:
			var print_text = action_data.get("print_text")
			print(print_text)
		InteractableData.InteractAction.LOAD_AREA:
			var area_name = action_data.get("load_area")
			var state_name = GeneralModule.get_chapter_state_name()
			var playable_char = DataStateModule.game_data.PlayerCharacter
			AreaModule.load_area(area_name, state_name, playable_char)
		InteractableData.InteractAction.PLAY_DIALOGUE:
			pass
		_:
			pass

func _input(event: InputEvent) -> void: # handle input for on_interact interactables
	if event.is_action_pressed("interact") and is_within_range == true:
		execute_action()

func _ready() -> void:
	if interaction_range > 0: # set the size of the interaction range if the value was modified
		self.get_node("CollisionShape3D").scale = Vector3(interaction_range, interaction_range, interaction_range)
	
	# set up the interactable!!!
	if interactable_type == InteractableData.InteractableType.ON_TOUCH: return # no need to do this if it's a non interact interactable
	var interactable_parent = self.get_parent() # get the interactable's parent
	
	# position it accordingly to the size of the parent object
	var visual_size:float # final size variable
	if interactable_parent is MeshInstance3D: # if it's a part of the map
		var bounding_box = interactable_parent.get_aabb()
		visual_size = bounding_box.size.y
	elif interactable_parent is Character or interactable_parent is PlayerOverworld: # if it's a character
		var sprite = interactable_parent.get_node("Sprite")
		var texture_size = sprite.get_sprite_frames().get_frame_texture(sprite.animation, sprite.frame).get_size().y
		visual_size = texture_size * sprite.pixel_size * sprite.scale.y
		
	interaction_prompt.position.y += visual_size/2 + 1 # set popup final position
	interaction_prompt.visible = false

func _on_body_entered(body: Node3D) -> void:
	if not body is PlayerOverworld: return # if the object is not the player character, dont run
	
	match interactable_type:
		InteractableData.InteractableType.ON_TOUCH: # if it triggers immediately upon entering range:
			execute_action()
		InteractableData.InteractableType.ON_INTERACT: # if it triggers after pressing the button while in range:
			if interactable_fired: return # don't run the logic if the action is already being performed
			is_within_range = true
			show_prompt(true)
		_:
			pass

func _on_body_exited(body: Node3D) -> void:
	if not body is PlayerOverworld: return # if the object is not the player character, dont run
	
	if interactable_type == InteractableData.InteractableType.ON_INTERACT: # this doesn't need to run if it's an on touch interaction
		is_within_range = false
		show_prompt(false)
