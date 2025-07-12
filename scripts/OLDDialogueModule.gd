extends Node
var CurrScene:Node3D = null
var PlayerUI:CanvasLayer = null

var Enabled:bool = false
var CurrScrollTween:Tween = null
var CurrCamTween:Tween = null

signal SpeakingChanged(value:int)
var Speaking:bool:
	set(NewValue):
		if Speaking == NewValue: return
		Speaking = NewValue
		SpeakingChanged.emit(NewValue)

func InitModule(Scene):
	Enabled = true
	CurrScene = Scene
	PlayerUI = Scene.get_node("UI")

func EndSession():
	Enabled = false
	CurrScene = null
	PlayerUI = null

func _input(event: InputEvent) -> void:
	if Enabled == false: return
	
	if event.is_action_pressed("SkipDialogue"):
		if Speaking == true:
			CurrScrollTween.emit_signal("finished")
			CurrScrollTween.kill()
			CurrScrollTween = null
		elif Speaking == false:
			Speaking = not Speaking

func DialogueLine(LineInfo):
	if Enabled == false: return
	Speaking = true
	
	# INIT============================
	# Load things in the scene
	var CharGroup = CurrScene.get_node("Characters") # get character group in scene
	var Speaker = CharGroup.get_node(LineInfo.Speaker) # identify speaker
	var Camera = CurrScene.get_node("Camera") # identify camera
	
	# Load UI active elements
	var ActiveElems = PlayerUI.get_node("Active")
	var SpeakingText = ActiveElems.get_node("SpeakingText") # get text displaying name
	var LineText = ActiveElems.get_node("LineText") # get text displaying dialogue line
	var ContArrow = ActiveElems.get_node("Arrow")
	
	# Set all sorts of texts & hide stuff
	if LineInfo.HideCharacterName == true: # change speaking text accordingly to the options
		SpeakingText.text = "???"
	else:
		SpeakingText.text = Speaker.knownName
	
	LineText.text = LineInfo.Line
	LineText.visible_characters = 0 # set text to display no characters at first
	ContArrow.visible = false # hide arrow at first
	Camera.fov = 75
	Camera.rotation.z = 0
	
	# Set text color if needed
	if LineText.modulate != LineInfo.TextColor:
		LineText.modulate = LineInfo.TextColor
	
	# Call sprite to change (CHANGE LATER TO NOT RUN IF THE SPRITE TO CHANGE IS THE SAME AS THE CURRENT SPRITE)
	if LineInfo.Sprite != "":
		Speaker.ChangeSprite(LineInfo.Sprite)
	
	# CAMERA============================
	if LineInfo.CameraType != "": # only run if there is a camera type specified
		# Cancel previous current camera tween
		if CurrCamTween != null:
			CurrCamTween.kill()
			CurrCamTween = null
		
		# Identify camera subject
		var CamSubject:Node3D
		if LineInfo.CameraSubject == "":
			CamSubject = Speaker
		else:
			CamSubject = CharGroup.get_node(LineInfo.CameraSubject)
		
		# Define base vector & positions for each different camera option
		var BaseVector = Vector3(0, 2, 6)
		var PosTable = {
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
		
		# Determine initial position (needed for transition tween)
		var InitPos:Vector3
		var InitRot:Vector3
		if LineInfo.CameraType == "Snap":
			InitPos = CamSubject.transform * BaseVector
		else:
			InitPos = CamSubject.transform * (BaseVector + PosTable[LineInfo.CameraType][LineInfo.CameraDirection][0])
		
		# Determine initial rotation (needed for transition tween)
		if LineInfo.TweenRotation == false or LineInfo.CameraType == "Snap":
			InitRot = CamSubject.rotation_degrees + Vector3(0, 0, LineInfo.CameraRotation)
		else:
			InitRot = CamSubject.rotation_degrees - Vector3(0, 0, LineInfo.CameraRotation)
		
		# Execute transition in if enabled
		if (LineInfo.OverrideTransition == true and CurrScene.name == "trial") or (LineInfo.OverrideTransition == false and CurrScene.name != "trial"):
			var TransTween = create_tween()
			TransTween.set_parallel(true)
			
			TransTween.tween_property(Camera, "position", InitPos, .35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
			TransTween.tween_property(Camera, "rotation_degrees", InitRot, .35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
			await TransTween.finished
		else: # If no transition, just set it to the initial from the get-go
			Camera.position = InitPos
			Camera.rotation_degrees = InitRot
		
		# Execute camera tween if not supposed to snap
		if LineInfo.CameraType != "Snap":
			var CamTween = create_tween()
			CurrCamTween = CamTween
			CamTween.set_parallel(true)
			
			# Position tween
			CamTween.tween_property(
				Camera,
				"position",
				CamSubject.transform * (BaseVector + PosTable[LineInfo.CameraType][LineInfo.CameraDirection][1]),
				LineInfo.CameraTime
			).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
			
			# Rotation tween
			if LineInfo.TweenRotation == true:
				CamTween.tween_property(
					Camera,
					"rotation_degrees:z",
					LineInfo.CameraRotation,
					LineInfo.CameraTime
				).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		
	
	# PROCESS LINE============================
	var LineLength = LineText.text.length()
	var ScrollSpeed = .025
	
	# Call character to leave the room if they're in the room
	if LineInfo.CharacterLeaves == true:
		Speaker.LeaveRoom()
	
	if LineInfo.SkipScrolling  == false: # skip the scrolling if it's on
		var ScrollTween = create_tween()
		ScrollTween.tween_property(LineText, "visible_characters", LineLength, ScrollSpeed * LineLength).set_trans(Tween.TRANS_LINEAR)
		CurrScrollTween = ScrollTween
		
		await ScrollTween.finished
	
	Speaking = false
	ContArrow.visible = true
	LineText.visible_characters = -1
	
	await SpeakingChanged

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
