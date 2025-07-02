extends Node3D
class_name Character

@export var knownName:String ## Name that shows up in the dialogue boxes.
@onready var frontSprite = $FrontSprite
@onready var backSprite = $BackSprite

func ChangeSprite(Sprite):
	print("my sprite is supposed to change here LOL")

func LeaveRoom():
	var FadeTimer:float = 1.25
	await get_tree().create_timer(.5).timeout
	
	for CurrSprite in self.get_children():
		if not CurrSprite.get_class() == "AnimatedSprite3D": continue
		
		var TranspTween = create_tween()
		TranspTween.tween_property(CurrSprite, "modulate:a", 0, FadeTimer).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		TranspTween.play()
	
	await get_tree().create_timer(FadeTimer + .5).timeout
	self.queue_free()
