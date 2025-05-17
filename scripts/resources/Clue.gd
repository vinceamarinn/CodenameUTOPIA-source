extends Resource
class_name Clue

enum ClueTypes {
	A,
	B,
	C,
}

@export_group("General")
@export var Name:String ## Name of the clue.
@export_multiline var Description:String ## Description of the clue. Length may vary.
@export var ClueType:ClueTypes = ClueTypes.A ## Type of the clue. Purely cosmetic and serves no gameplay purpose.
# icon
# location

func serialize() -> Dictionary: ## Converts the clue object into a dictionary so it can be saved into a proper array in a config file.
	var clue_dict = {}
	var clue_properties = GeneralModule.get_resource_properties(self)
	
	for property in clue_properties:
		clue_dict[property["name"]] = self.get(property["name"])
	
	return clue_dict

static func create_from_dict(data: Dictionary) -> Clue:
	var new_clue = Clue.new()
	for key in data:
		if not key in new_clue: continue
		new_clue.set(key, data[key])
	
	return new_clue
