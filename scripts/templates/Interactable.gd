extends Area3D
class_name Interactable

# important variables
var is_within_range: bool = false ## Tracks whether there's a player within interaction range.
var player_within_range: PlayerOverworld = null  ## Tracks the player currently in the area.

# interactable information
@export var interactable_data: InteractableData ## The data for the interactable to use.
@onready var interactable_type = interactable_data.InteractableType
@onready var interaction_range = interactable_data.InteractionRange
@onready var interaction_prompt: SpriteBase3D = $Prompt

@onready var interact_event = interactable_data.InteractEvent

func _ready() -> void: ## Setup.
	# if the range is not 0, set the range of the interaction area to the provided value
	if interaction_range > 0:
		self.get_node("CollisionShape3D").scale = Vector3(interaction_range, interaction_range, interaction_range)
	
	# no more setup needed if it's an on touch interactable!
	if interactable_type == InteractableData.InteractableTypes.ON_TOUCH: return
	
	# get the parent object
	var interactable_parent = self.get_parent()
	var visual_size: float
	
	# position the prompt texture and its visual size accordingly to the object it's a child of
	if interactable_parent is MeshInstance3D:
		var bounding_box = interactable_parent.get_aabb()
		visual_size = bounding_box.size.y
	elif interactable_parent is Character or interactable_parent is PlayerOverworld:
		var sprite = interactable_parent.get_node("Sprite")
		var texture_size = sprite.get_sprite_frames().get_frame_texture(sprite.animation, sprite.frame).get_size().y
		visual_size = texture_size * sprite.pixel_size * sprite.scale.y
	
	interaction_prompt.position.y += visual_size/2 + 1
	interaction_prompt.visible = false

func show_prompt(on_off: bool) -> void: ## Handles the logic for showing the interaction prompt.
	interaction_prompt.visible = on_off

func execute_action(): ## Executes the interactable action once all requirements are met.
	# failsafe just in case something happened
	if player_within_range == null or not player_within_range.can_interact:
		return
	
	# hide prompt while the event is being executed & lock interactions
	show_prompt(false)
	
	# call event module to execute event
	await EventModule.process_event(interact_event)

func _input(event: InputEvent) -> void: ## Handles input confirmation for on_interact types.
	if event.is_action_pressed("interact") and is_within_range and InteractableHandler.closest_interactable == self:
		execute_action()

func _on_body_entered(body: Node3D) -> void: ## Handles what to do when the player is within the interactable range.
	if not body is PlayerOverworld: return
	player_within_range = body as PlayerOverworld
	
	# only proceed if player can interact
	if not player_within_range.can_interact: return
	
	match interactable_type:
		InteractableData.InteractableTypes.ON_TOUCH:
			# touch types trigger immediately, no module involvement
			execute_action()
		InteractableData.InteractableTypes.ON_INTERACT:
			# notify the module to handle priority tracking
			is_within_range = true
			InteractableHandler.add_to_registry(self, player_within_range)
		_:
			pass

func _on_body_exited(body: Node3D) -> void: ## Handles logic for when the player leaves the interaction range.
	if not body is PlayerOverworld: return
	
	# clear the player reference
	player_within_range = null
	
	# lost interaction rights
	if interactable_type == InteractableData.InteractableTypes.ON_INTERACT:
		is_within_range = false
		show_prompt(false)
		
		# remove from module tracker
		InteractableHandler.remove_from_registry(self)
