extends Node

#game tree goodies we need
@onready var scenes_3D = get_node("/root/GameMain/3DScenes")
@onready var worldview = get_node("/root/GameMain/Worldview")
@onready var char_group = get_node("/root/GameMain/3DScenes/Characters")
@onready var scenes_2D = get_node("/root/GameMain/2DScenes")

@onready var camera = worldview.get_node("Camera")

# tween holders
var curr_cam_tween:Tween = null
var curr_cam_subject:Node3D = null

# camera mode stuff
enum CameraModes { ## lists the different modes for the camera.
	NONE, ## The camera is static and does nothing. Allows for custom behavior to be executed without interruption.
	FOLLOW_PLAYER, ## The camera follows the player around smoothly.
	TRIAL, ## The camera is set to tween smoothly to focus on which character is talking to accentuate the Courtroom Trials.
	DIALOGUE ## The camera is set to tween smoothly to focus on which character is talking during Overworld dialogue sections.
}

var camera_mode:CameraModes = CameraModes.NONE ## Tracks the currently selected camera mode.

# table storing the initial positions for each different Trial camera option
const POSITION_TABLE = {
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

# important values
const FOLLOW_SPEED:float = 5.0 ## Speed at which the camera follows the player in Follow Player mode.
const FOLLOW_OFFSET:Vector3 = Vector3(0, 2, 8.5) ## Offset with which the camera tracks the player from in Follow Player mode.

const DIALOGUE_OFFSET:Vector3 = Vector3(0, 0, 6) ## Offset from the camera subject where the camera rests after its Dialogue tween.
const DIALOGUE_TIME:float = 0.65 ## Default time the Dialogue tween takes.

const TRIAL_BASE_OFFSET:Vector3 = Vector3(0, 2, 6) ## Offset with which the camera builds the Trial camera movement out of, using the other initial values.

# signals
signal transition_finished ## Signals when a camera initial transition finishes.

func kill_current_tween() -> void: ## Kills any current ongoing tween.
	if curr_cam_tween != null:
		curr_cam_tween.kill()
		curr_cam_tween = null

func reset_camera() -> void: ## Sets the camera mode to None and resets references to the target player and the current tween, while killing the latter if it exists.
	# reset camera mode
	camera_mode = CameraModes.NONE
	
	# kill and reset tween reference
	kill_current_tween()
	
	# current camera subject references if they exist
	curr_cam_subject = null

func set_mode(chosen_mode:CameraModes) -> void: ## Switches the camera mode to one of the chosen modes.
	# clear references, kill tweens, and reset camera mode
	reset_camera()
	
	# if we wanna follow the player, get the player character if it exists - otherwise abort the function and essentially only reset the camera
	if chosen_mode == CameraModes.FOLLOW_PLAYER:
		curr_cam_subject = char_group.get_node_or_null("Player")
		
		if curr_cam_subject == null:
			return
	
	# switch to requested camera mode
	camera_mode = chosen_mode

func _physics_process(delta:float) -> void: ## Fires every frame with the physics engine.
	# abort if we don't wanna follow the player around at all
	if camera_mode != CameraModes.FOLLOW_PLAYER: return
	
	# if the player reference is invalid, stop the player follow mode
	if not is_instance_valid(curr_cam_subject) or curr_cam_subject == null: 
		reset_camera()
		return
	
	# smoothly follow player with lerping
	var target_pos = curr_cam_subject.position + FOLLOW_OFFSET
	camera.position = camera.position.lerp(target_pos, FOLLOW_SPEED * delta)

func get_initial_transform(movement_type:String, movement_direction:String, base_rotation:int) -> Array[Vector3]: ## Gets the initial position & rotation for Trial mode camera tweens.
	# define the movement offset by taking the base offset and matching it to the camera movement type:
	var movement_offset = TRIAL_BASE_OFFSET
	if movement_type != "Snap":
		# if it's not a Snap movement (there's actual tweening), the offset will be equal to the base offset + the movement appropriate offset, according to the chosen movement & direction
		# [0] signifies it's the initial position from the base
		movement_offset += POSITION_TABLE[movement_type][movement_direction][0]
	# if it's a Snap movement, then it's just the base offset vector, so no change is needed
	
	# init_pos is initiated as equal to the camera subject's transform multiplied by the movement's determined offset
	var init_pos:Vector3 = curr_cam_subject.transform * movement_offset
	
	# meanwhile, initial rotation is just the camera subject's rotation + the requested initial rotation
	var init_rot:Vector3 = curr_cam_subject.rotation_degrees + Vector3(0, 0, base_rotation)
	
	# return both values as the requested initial transform for the camera movement!
	return [init_pos, init_rot]

func get_final_transform(movement_type:String, movement_direction:String, final_rotation:int) -> Array[Vector3]: ## Gets the final position & rotation for Trial mode camera tweens.
	# define the movement offset by taking the base offset and matching it to the camera movement type:
	var movement_offset = TRIAL_BASE_OFFSET + POSITION_TABLE[movement_type][movement_direction][1]
	# the offset will be equal to the base offset + the movement appropriate offset, according to the chosen movement & direction
	# [1] signifies it's the final position from the base
	
	# final_pos is initiated as equal to the camera subject's transform multiplied by the movement's determined offset
	var final_pos:Vector3 = curr_cam_subject.transform * movement_offset
	
	# meanwhile, final_rot is just the camera subject's rotation + the requested final rotation
	var final_rot = curr_cam_subject.rotation_degrees + Vector3(0, 0, final_rotation)
	
	# return both values as the requested initial transform for the camera movement!
	return [final_pos, final_rot]

func dialogue_tween(cam_subject:Node3D) -> void: ## Handles tweening for regular overworld dialogue for focusing on the different speakers. Main function of the Dialogue mode.
	# abort immediately if we are not in Dialogue mode
	if camera_mode != CameraModes.DIALOGUE:
		GeneralModule.debug_message("CameraModule - dialogue_tween()", "Warning", "Attempted to start a Dialogue tween.", "However, the correct Dialogue camera mode wasn't initialized!")
		return
	
	# abort immediately if the camera subject is invalid
	if not is_instance_valid(cam_subject) or cam_subject == null:
		GeneralModule.debug_message("CameraModule - dialogue_tween()", "Error", "Dialogue tween was cancelled.", "The camera subject was not found in the scene!")
		return
	
	# abort if the camera subject is the same as the previous one (no need to run it)
	if curr_cam_subject == cam_subject:
		return
	
	# stop any ongoing tweens
	kill_current_tween()
	
	# create new tween
	var new_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	curr_cam_tween = new_tween
	curr_cam_subject = cam_subject
	
	# tween the position
	new_tween.tween_property(camera, "position", cam_subject.position + DIALOGUE_OFFSET, DIALOGUE_TIME)

func initial_transition(cam_info:CameraMovementData) -> void: ## Handles creating the initial transition from the current camera location to the initial position of the tween. Used for the Trial camera mode.
	# create tween
	var new_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_parallel(true)
	curr_cam_tween = new_tween
	
	# get initial coordinate frame (pos + rot) based on movement type and initial rotation 
	var init_cframe = get_initial_transform(cam_info.MovementType, cam_info.MovementDirection, cam_info.BaseRotation)
	var init_pos = init_cframe[0]
	var init_rot = init_cframe[1]
	
	# play the tween!
	new_tween.tween_property(camera, "position", init_pos, cam_info.TransitionTime)
	new_tween.tween_property(camera, "rotation_degrees", init_rot, cam_info.TransitionTime)
	await new_tween.finished
	
	# cleanup transition tween
	kill_current_tween()

func trial_tween(cam_info:CameraMovementData, cam_subject:Node3D) -> void: ## Handles tweening for Courtroom Trial dialogue for focusing on the different speakers. Main function of the Trial mode.
	# abort if not in Trial mode
	if camera_mode != CameraModes.TRIAL:
		GeneralModule.debug_message("CameraModule - trial_tween()", "Warning", "Attempted to start a Trial tween.", "However, the correct Trial camera mode wasn't initialized!")
		return
	
	# abort if the camera subject is invalid
	if not is_instance_valid(cam_subject) or cam_subject == null:
		GeneralModule.debug_message("CameraModule - trial_tween()", "Error", "Trial tween was cancelled.", "The camera subject was not found in the scene!")
		return
	
	# stop any ongoing tweens
	kill_current_tween()
	
	# set the camera subject (so other tweens don't have to do it themselves)
	curr_cam_subject = cam_subject
	
	# perform initial transition if it was asked of us
	if cam_info.InitialTransition:
		await initial_transition(cam_info)
	
	# signal that the transition is finished and the actual camera movement has begun
	transition_finished.emit()
	
	# reset camera back to initial position and rotation at the end of the transition, just to make sure everything's setup
	# alternatively, it puts the camera there in the first place if there was no transition
	var init_cframe = get_initial_transform(cam_info.MovementType, cam_info.MovementDirection, cam_info.BaseRotation)
	camera.position = init_cframe[0] # set initial position
	camera.rotation_degrees = init_cframe[1] # set initial rotation
	
	# perform the tween if the movement type is not equal to Snap1
	if cam_info.MovementType != "Snap":
		# create tween (easings are not set immediately, we'll set them separately per property for a cool effect!)
		var new_tween = create_tween().set_parallel(true)
		curr_cam_tween = new_tween
		
		# get final transform to calculate endpoints of the tween
		var final_transform = get_final_transform(cam_info.MovementType, cam_info.MovementDirection, cam_info.FinalRotation)
		
		# tween the position!
		var final_pos = final_transform[0]
		new_tween.tween_property(
			camera,
			"position",
			final_pos,
			cam_info.CameraTime
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		
		# tween the rotation if we want to!
		if cam_info.TweenRotation:
			var final_rot = final_transform[1]
			
			new_tween.tween_property(
			camera,
			"rotation_degrees",
			final_rot,
			cam_info.CameraTime
		).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func _ready() -> void:
	ServiceLocator.register_service("CameraModule", self) # registers module in service locator automatically
