extends Sprite2D

var MoveFactor = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	while true:
		await get_tree().create_timer(.5).timeout
		self.position.y -= MoveFactor
		
		await get_tree().create_timer(.5).timeout
		self.position.y += MoveFactor
