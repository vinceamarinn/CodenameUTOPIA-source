extends Minigame

@onready var UI = get_node("/root/GameMain/UI")

## MINIGAME DATA VALUES
# none, honestly LOL

## MINIGAME VARIABLES
var chosen_char:String

func setup() -> bool:
	# pick random main character (0 to 16 on the enum, from yuuto to madame) and get their name in lowercase
	chosen_char = GeneralModule.get_character_name(randi_range(0, 16))
	return true

func main() -> void:
	print(chosen_char)

func end() -> void:
	super.end()
