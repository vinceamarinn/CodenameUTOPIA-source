extends Resource
class_name Clue

@export_group("General")
@export var Name:String ## Name of the clue.
@export_multiline var Description:String ## Description of the clue. Length may vary.
@export_enum("a", "b", "c") var ClueType:String ## Type of the clue. Purely cosmetic and serves no gameplay purpose.
# icon
# location

func serialize() -> Dictionary: ## Converts the clue object into a dictionary so it can be saved into a proper array in a config file.
	return {
		"Name": Name,
		"Description" : Description,
		"ClueType": ClueType
	}

static func create_from_dict(data: Dictionary) -> Clue:
	var clue = Clue.new()
	clue.Name = data.get("Name", "")
	clue.Description = data.get("Description", "")
	clue.ClueType = data.get("ClueType", "a")
	return clue
