extends Sprite2D

const MOVE_FACTOR = 10 ## How many pixels the arrow moves up and down.

func _ready() -> void:
	while true:
		await get_tree().create_timer(.5).timeout
		self.position.y -= MOVE_FACTOR
		
		await get_tree().create_timer(.5).timeout
		self.position.y += MOVE_FACTOR
