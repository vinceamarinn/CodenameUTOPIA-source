extends Node3D
var CurrScene:Node3D
var PlayerUI:CanvasLayer

func InitModule(Scene):
	CurrScene = Scene
	PlayerUI = Scene.get_node("UI")

func DialogueLine(LineInfo):
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
	
	# Set text color if needed
	if LineText.modulate != LineInfo.TextColor:
		LineText.modulate = LineInfo.TextColor
	
	# Call sprite to change (CHANGE LATER TO NOT RUN IF THE SPRITE TO CHANGE IS THE SAME AS THE CURRENT SPRITE)
	if LineInfo.Sprite != "":
		Speaker.ChangeSprite(LineInfo.Sprite)
	
	# CAMERA============================
	var ForwardFace = Speaker.transform * (Vector3.BACK * 6)
	print(ForwardFace)
	Camera.position = Vector3(ForwardFace.x, Speaker.position.y + 2, ForwardFace.z)
	Camera.look_at(Vector3(Speaker.position.x, Camera.position.y, Speaker.position.z))
	
	# PROCESS LINE============================
	var LineLength = LineText.text.length()
	var ScrollSpeed = .025 # time it takes for the digit to scroll
	
	if LineInfo.SkipScrolling  == false: # skip the scrolling if it's on
		var ScrollTween = create_tween()
		ScrollTween.tween_property(LineText, "visible_characters", LineLength, ScrollSpeed * LineLength).set_trans(Tween.TRANS_LINEAR)
		ScrollTween.play()
		await ScrollTween.finished
	
	ContArrow.visible = true
	LineText.visible_characters = -1
	await get_tree().create_timer(3).timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
