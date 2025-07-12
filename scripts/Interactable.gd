extends Area3D
class_name Interactable

var is_within_range: bool = false # Track whether there's a player within interaction range
var player_within_range: PlayerOverworld = null  # Track the player currently in the area
var is_action_running: bool = false  # Track if an action is currently running

@export var interactable_data: InteractableData ## The data for the interactable to use.
@onready var interactable_type = interactable_data.interactable_type
@onready var interact_action = interactable_data.interact_action
@onready var action_data = interactable_data.action_data
@onready var interaction_range = interactable_data.interaction_range
@onready var interaction_prompt: SpriteBase3D = $Prompt

func show_prompt(on_off: bool) -> void: ## Handles the logic for showing the interaction prompt.
	interaction_prompt.visible = on_off

func execute_action(): ## Executes the interactable action once all requirements are met.
	if is_action_running: return
	is_action_running = true
	show_prompt(false)
	print("im doing an action!!!")
	
	match interact_action:
		InteractableData.InteractAction.PRINT_TEXT:
			var print_text = action_data.get("print_text")
			print(print_text)
			# Repeatable action - reset after completion
			is_action_running = false
			_handle_action_completed()
		InteractableData.InteractAction.LOAD_AREA:
			var area_name = action_data.get("load_area")
			var state_name = GeneralModule.get_chapter_state_name()
			var playable_char = DataStateModule.game_data.PlayerCharacter
			AreaModule.load_area(area_name, state_name, playable_char)
			# Non-repeatable action - stays locked
		InteractableData.InteractAction.READ_DIALOGUE:
			var dialogue_data = action_data.get("read_dialogue")
			await DialogueModule.read_dialogue(dialogue_data)
			# Repeatable action - reset after completion
			is_action_running = false
			_handle_action_completed()
		_:
			pass

func _handle_action_completed(): ## Called when a repeatable action completes and can be fired again.
	# Only re-enable if player is still in range and can interact
	if player_within_range != null and player_within_range.can_interact:
		match interactable_type:
			InteractableData.InteractableType.ON_TOUCH:
				# ON_TOUCH repeats immediately when action completes
				execute_action()
			InteractableData.InteractableType.ON_INTERACT:
				# ON_INTERACT shows prompt again
				is_within_range = true
				show_prompt(true)

func _input(event: InputEvent) -> void: ## Handles input confirmatiomn for on_interact types.
	if event.is_action_pressed("interact") and is_within_range == true:
		execute_action()

func _ready() -> void: ## Setup.
	if interaction_range > 0:
		self.get_node("CollisionShape3D").scale = Vector3(interaction_range, interaction_range, interaction_range)
	
	if interactable_type == InteractableData.InteractableType.ON_TOUCH: return
	
	var interactable_parent = self.get_parent()
	var visual_size: float
	
	if interactable_parent is MeshInstance3D:
		var bounding_box = interactable_parent.get_aabb()
		visual_size = bounding_box.size.y
	elif interactable_parent is Character or interactable_parent is PlayerOverworld:
		var sprite = interactable_parent.get_node("Sprite")
		var texture_size = sprite.get_sprite_frames().get_frame_texture(sprite.animation, sprite.frame).get_size().y
		visual_size = texture_size * sprite.pixel_size * sprite.scale.y
		
	interaction_prompt.position.y += visual_size/2 + 1
	interaction_prompt.visible = false

func _on_player_can_interact_changed(can_interact: bool) -> void: ## Fires when the player's ability to interact changes.
	# only respond if this player is in the area
	if player_within_range == null:
		return
	
	if can_interact:
		# player regained interaction rights while in range
		_handle_player_gained_interaction()
	else:
		# player lost interaction rights while in range
		_handle_player_lost_interaction()

func _handle_player_lost_interaction() -> void: ## Remove interaction stuff when the player loses interaction rights.
	match interactable_type:
		InteractableData.InteractableType.ON_INTERACT:
			# hide prompt and disable interaction
			is_within_range = false
			show_prompt(false)
		InteractableData.InteractableType.ON_TOUCH:
			pass

func _handle_player_gained_interaction() -> void: ## Add interaction stuff when the player gains interaction rights.
	match interactable_type:
		InteractableData.InteractableType.ON_TOUCH:
			# immediately trigger the effect (if not already running)
			if not is_action_running:
				execute_action()
		InteractableData.InteractableType.ON_INTERACT:
			# show prompt and set up for interaction (if not already running)
			if not is_action_running:
				is_within_range = true
				show_prompt(true)

func _on_body_entered(body: Node3D) -> void:
	if not body is PlayerOverworld: return
	
	player_within_range = body as PlayerOverworld
	
	# connect to the polayer's interaction change signal
	if not player_within_range.can_interact_changed.is_connected(_on_player_can_interact_changed):
		player_within_range.can_interact_changed.connect(_on_player_can_interact_changed)
	
	# only proceed if player can interact
	if not player_within_range.can_interact: return
	
	match interactable_type:
		InteractableData.InteractableType.ON_TOUCH:
			execute_action()
		InteractableData.InteractableType.ON_INTERACT:
			if is_action_running: return
			is_within_range = true
			show_prompt(true)
		_:
			pass

func _on_body_exited(body: Node3D) -> void:
	if not body is PlayerOverworld: return
	
	# disconnect from the player's signal
	if player_within_range != null and player_within_range.can_interact_changed.is_connected(_on_player_can_interact_changed):
		player_within_range.can_interact_changed.disconnect(_on_player_can_interact_changed)
	
	# clear the player reference
	player_within_range = null
	
	if interactable_type == InteractableData.InteractableType.ON_INTERACT:
		is_within_range = false
		show_prompt(false)
