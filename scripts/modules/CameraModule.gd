extends Node

#game tree goodies we need
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")
@onready var worldview = get_node("/root/GameMain/Worldview")
@onready var char_group = get_node("/root/GameMain/3DScenes/Characters")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")

@onready var camera = worldview.get_node("Camera")

# tween holder
var curr_cam_tween:Tween = null

# important stuff
enum CameraModes { ## lists the different modes for the camera.
	NONE, ## The camera is static and does nothing. Allows for custom behavior to be executed without interruption.
	FOLLOW_PLAYER, ## The camera follows the player around smoothly.
	TRIAL, ## The camera is set to tween smoothly to focus on which character is talking to accentuate the Courtroom Trials.
	DIALOGUE ## The camera is set to tween smoothly to focus on which character is talking during Overworld dialogue sections.
}

# define initial positions for each different Trial camera option
var position_table = {
	"Pan" = {
		"Left" = [Vector3(3, 0, 0), Vector3(-.25, 0, 0)],
		"Right" = [Vector3(-3, 0, 0), Vector3(.25, 0, 0)],
		"Up" = [Vector3(0, -3, 0), Vector3(0, .25, 0)],
		"Down" = [Vector3(0, 3, 0), Vector3(0, -.25, 0)],
	},
	
	"Zoom" = {
		"In" = [Vector3(0, 0, 2), Vector3(0, 0, -2)],
		"Out" = [Vector3(0, 0, -2), Vector3(0, 0, 2)],
	},
}

var camera_mode:CameraModes = CameraModes.NONE ## Tracks the currently selected camera mode.
var player:PlayerOverworld = null ## Tracks the player character so it can be followed around during Follow Player mode.

# values
const FOLLOW_SPEED:float = 5.0 ## Speed at which the camera follows the player in Follow Player mode.
const FOLLOW_OFFSET:Vector3 = Vector3(0, 2, 8.5) ## Offset with which the camera tracks the player from in Follow Player mode.

const DIALOGUE_OFFSET:Vector3 = Vector3(0, 0, 6) ## Offset from the camera subject where the camera rests after its Dialogue tween.
const DIALOGUE_TIME:float = 0.75 ## Default time the Dialogue tween takes.

const TRIAL_OFFSET:Vector3 = Vector3(0, 2, 6) ## Offset with which the camera builds the Trial camera movement out of, using the other initial values.

# signals
signal transition_finished ## Signals when a camera initial transition finishes.

func kill_current_tween() -> void: ## Kills any current ongoing tween.
	if curr_cam_tween != null:
		curr_cam_tween.kill()

func reset_camera() -> void: ## Sets the camera mode to None and resets references to the target player and the current tween, while killing the latter if it exists.
	# reset camera mode
	camera_mode = CameraModes.NONE
	
	# kill and reset tween reference
	kill_current_tween()
	curr_cam_tween = null
	
	# reset player reference
	player = null

func set_mode(chosen_mode:CameraModes) -> void: ## Switches the camera mode to one of the chosen modes.
	# clear references, kill tweens, and reset camera mode
	reset_camera()
	
	# if we wanna follow the player, get the player character if it exists - otherwise abort the function and essentially only reset the camera
	if chosen_mode == CameraModes.FOLLOW_PLAYER:
		player = char_group.get_node_or_null("Player")
		
		if player == null:
			return
	
	# switch to player follow mode
	camera_mode = chosen_mode

func _physics_process(delta:float) -> void: ## Fires every frame with the physics engine.
	# abort if we don't wanna follow the player around at all
	if camera_mode != CameraModes.FOLLOW_PLAYER: return
	
	# if the player reference is invalid, stop the player follow mode
	if not is_instance_valid(player) or player == null: 
		reset_camera()
		return
	
	# smoothly follow player with lerping
	var target_pos = player.position + FOLLOW_OFFSET
	camera.position = camera.position.lerp(target_pos, FOLLOW_SPEED * delta)

func initial_transition(cam_info:CameraMovementData) -> void: ## Handles creating the initial transition from the current camera location to the initial position of the tween. Used for the Trial camera mode.
	return

func dialogue_tween(cam_subject:Node3D) -> void: ## Handles tweening for regular overworld dialogue for focusing on the different speakers. Main function of the Dialogue mode.
	if camera_mode != CameraModes.DIALOGUE:
		GeneralModule.debug_message("CameraModule - dialogue_tween()", "Warning", "Attempted to start a Dialogue tween.", "However, the correct Dialogue camera mode wasn't initialized!")
		return
	
	if not is_instance_valid(cam_subject) or cam_subject == null:
		GeneralModule.debug_message("CameraModule - dialogue_tween()", "Error", "Dialogue tween was cancelled.", "The camera subject was not found in the scene!")
	
	# stop any ongoing tweens
	kill_current_tween()
	
	# create new tween
	var new_tween = create_tween()
	curr_cam_tween = new_tween
	
	# tween the position
	new_tween.tween_property(camera, "position", cam_subject.position + DIALOGUE_OFFSET, 0.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func trial_tween(cam_info:CameraMovementData, cam_subject:Node3D) -> void: ## Handles tweening for Courtroom Trial dialogue for focusing on the different speakers. Main function of the Trial mode.
	if camera_mode != CameraModes.TRIAL:
		GeneralModule.debug_message("CameraModule - trial_tween()", "Warning", "Attempted to start a Trial tween.", "However, the correct Trial camera mode wasn't initialized!")
		return
	
	if not is_instance_valid(cam_subject) or cam_subject == null:
		GeneralModule.debug_message("CameraModule - trial_tween()", "Error", "Trial tween was cancelled.", "The camera subject was not found in the scene!")
	
	# stop any ongoing tweens
	kill_current_tween()
	
	await initial_transition(cam_info)
	transition_finished.emit()
	
	pass

func _ready() -> void:
	ServiceLocator.register_service("CameraModule", self) # registers module in service locator automatically
