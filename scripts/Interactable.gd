extends Area3D
class_name Interactable

var is_within_range: bool = false # Track whether there's a player within interaction range
var player_within_range: PlayerOverworld = null  # Track the player currently in the area

@export var interactable_data: InteractableData ## The data for the interactable to use.
@onready var interactable_type = interactable_data.interactable_type
@onready var interaction_range = interactable_data.interaction_range
@onready var interaction_prompt: SpriteBase3D = $Prompt

@onready var interact_event = interactable_data.interact_event

# Static variables to track all interactables and closest one
static var all_interactables: Array[Interactable] = []
static var closest_interactable: Interactable = null

func _ready() -> void: ## Setup.
	# Register this interactable
	all_interactables.append(self)
	
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

func _exit_tree() -> void:
	# Unregister this interactable
	all_interactables.erase(self)
	if closest_interactable == self:
		closest_interactable = null
		_update_closest_interactable()

func show_prompt(on_off: bool) -> void: ## Handles the logic for showing the interaction prompt.
	interaction_prompt.visible = on_off

func execute_action(): ## Executes the interactable action once all requirements are met.
	if player_within_range == null or not player_within_range.can_interact:
		return
	
	# hide prompt
	show_prompt(false)
	
	# call event module to execute event
	EventModule.process_event(interact_event)
	
	"""
	match event_type:
		InteractableData.InteractAction.PRINT_TEXT:
			var print_text = action_data.get("print_text")
			print(print_text)
			# Repeatable action - unlock player after completion
			_unlock_player()
		InteractableData.InteractAction.LOAD_AREA:
			var area_name = action_data.get("load_area")
			var state_name = DataStateModule.get_chapter_state_name()
			var playable_char = DataStateModule.game_data.PlayerCharacter
			AreaModule.load_area(area_name, state_name, playable_char)
			# Non-repeatable action - area change will handle player state
		InteractableData.InteractAction.READ_DIALOGUE:
			var dialogue_data = action_data.get("read_dialogue")
			await DialogueModule.read_dialogue(dialogue_data)
			# Repeatable action - unlock player after completion
			_unlock_player()
		_:
			_unlock_player()
"""

func _input(event: InputEvent) -> void: ## Handles input confirmation for on_interact types.
	if event.is_action_pressed("interact") and is_within_range and self == closest_interactable:
		execute_action()

func _on_player_can_interact_changed(can_interact: bool) -> void: ## Fires when the player's ability to interact changes.
	# only respond if this player is in the area
	if player_within_range == null: return
	
	if can_interact:
		# player regained interaction rights while in range
		_handle_player_gained_interaction()
	else:
		# player lost interaction rights while in range
		_handle_player_lost_interaction()
	
	# Always update closest when player interaction state changes
	_update_closest_interactable()

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
			# immediately trigger the effect
			execute_action()
		InteractableData.InteractableType.ON_INTERACT:
			# set up for interaction - let _update_closest_interactable handle the prompt
			is_within_range = true

func _on_body_entered(body: Node3D) -> void:
	if not body is PlayerOverworld: return
	player_within_range = body as PlayerOverworld
	
	# connect to the player's interaction change signal
	if not player_within_range.can_interact_changed.is_connected(_on_player_can_interact_changed):
		player_within_range.can_interact_changed.connect(_on_player_can_interact_changed)
	
	# Connect to player's position changes for proximity updates
	if not player_within_range.tree_exiting.is_connected(_on_player_tree_exiting):
		player_within_range.tree_exiting.connect(_on_player_tree_exiting)
	_start_tracking_player_movement()
	
	# only proceed if player can interact
	if not player_within_range.can_interact: return
	
	match interactable_type:
		InteractableData.InteractableType.ON_TOUCH:
			execute_action()
		InteractableData.InteractableType.ON_INTERACT:
			is_within_range = true
			# Always update closest when entering any interactable
			_update_closest_interactable()
		_:
			pass

func _on_body_exited(body: Node3D) -> void:
	if not body is PlayerOverworld: return
	# disconnect from the player's signal
	if player_within_range != null and player_within_range.can_interact_changed.is_connected(_on_player_can_interact_changed):
		player_within_range.can_interact_changed.disconnect(_on_player_can_interact_changed)
	if player_within_range != null and player_within_range.tree_exiting.is_connected(_on_player_tree_exiting):
		player_within_range.tree_exiting.disconnect(_on_player_tree_exiting)
	
	_stop_tracking_player_movement()
	
	# clear the player reference
	player_within_range = null
	
	if interactable_type == InteractableData.InteractableType.ON_INTERACT:
		is_within_range = false
		show_prompt(false)
		# Always update closest when exiting any interactable
		_update_closest_interactable()

func _on_player_tree_exiting() -> void:
	_stop_tracking_player_movement()

# Static variables for tracking player movement
static var tracked_player: PlayerOverworld = null
static var player_last_position: Vector3
static var any_interactables_tracking: bool = false

func _start_tracking_player_movement() -> void:
	if interactable_type != InteractableData.InteractableType.ON_INTERACT:
		return
	
	if not any_interactables_tracking and player_within_range != null:
		tracked_player = player_within_range
		player_last_position = tracked_player.global_position
		any_interactables_tracking = true

func _stop_tracking_player_movement() -> void:
	if interactable_type != InteractableData.InteractableType.ON_INTERACT:
		return
	
	# Check if any other interactables are still tracking
	var still_tracking = false
	for interactable in all_interactables:
		if (interactable != self and 
			interactable.interactable_type == InteractableData.InteractableType.ON_INTERACT and 
			interactable.player_within_range != null):
			still_tracking = true
			break
	
	if not still_tracking:
		tracked_player = null
		any_interactables_tracking = false

func _process(delta: float) -> void:
	# Only track movement if we're supposed to and we have a player
	if any_interactables_tracking and tracked_player != null and tracked_player.is_inside_tree():
		var current_position = tracked_player.global_position
		if current_position.distance_to(player_last_position) > 0.1:  # Only update if moved significantly
			player_last_position = current_position
			_update_closest_interactable()

static func _update_closest_interactable() -> void:
	var previous_closest = closest_interactable
	closest_interactable = null
	var closest_distance = INF
	var current_player: PlayerOverworld = null
	
	# Find any player to calculate distances
	for interactable in all_interactables:
		if interactable.player_within_range != null:
			current_player = interactable.player_within_range
			break
	
	if current_player == null:
		# Hide previous closest if no player found
		if previous_closest != null:
			previous_closest.show_prompt(false)
		return
	
	# Find the closest ON_INTERACT interactable that has a player in range and can interact
	for interactable in all_interactables:
		if (interactable.interactable_type == InteractableData.InteractableType.ON_INTERACT and 
			interactable.is_within_range and 
			interactable.player_within_range != null and
			interactable.player_within_range.can_interact):
			var distance = current_player.global_position.distance_to(interactable.global_position)
			if distance < closest_distance:
				closest_distance = distance
				closest_interactable = interactable
	
	# Update prompts only if closest changed
	if previous_closest != closest_interactable:
		# Hide prompt from previous closest
		if previous_closest != null:
			previous_closest.show_prompt(false)
		
		# Show prompt for new closest
		if closest_interactable != null:
			closest_interactable.show_prompt(true)
