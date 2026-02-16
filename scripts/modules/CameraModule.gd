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
	NONE, ## The camera is static and does nothing.
	FOLLOW_PLAYER, ## The camera follows the player around smoothly.
	TRIAL, ## The camera is set to tween smoothly to focus on which character is talking to accentuate the Courtroom Trials.
	DIALOGUE ## The camera is set to tween smoothly to focus on which character is talking during Overworld dialogue sections.
}

var camera_mode:CameraModes = CameraModes.NONE ## Tracks the currently selected camera mode.
var player:PlayerOverworld = null ## Tracks the player character so it can be followed around during Follow Player mode.

# values
const FOLLOW_SPEED:float = 5.0 ## Speed at which the camera follows the player in Follow Player mode.
const FOLLOW_OFFSET:Vector3 = Vector3(0, 2, 8.5) ## Offset with which the camera tracks the player from in Follow Player mode.

func reset_camera() -> void: ## Sets the camera mode to None and resets references to the target player and the current tween, while killing the latter if it exists.
	# reset camera mode
	camera_mode = CameraModes.NONE
	
	# kill and reset tween reference
	if curr_cam_tween != null:
		curr_cam_tween.kill()
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


func _process(delta:float) -> void: ## Fires every frame.
	# abort if we don't wanna follow the player around at all
	if camera_mode != CameraModes.FOLLOW_PLAYER: return
	
	# if the player reference is invalid, stop the player follow mode
	if not is_instance_valid(player) or player == null: 
		reset_camera()
		return
	
	# smoothly follow player with lerping
	var target_pos = player.global_position + FOLLOW_OFFSET
	camera.global_position = camera.global_position.lerp(target_pos, FOLLOW_SPEED * delta)

func _ready() -> void:
	ServiceLocator.register_service("CameraModule", self) # registers module in service locator automatically
