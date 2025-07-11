@tool
class_name StringKeysOptions
extends Resource

@export var translation_file:= "res://localization/translations.csv"
@export var patterns_to_search: Array[String] = [
	"tr(\"STR_KEY\")",
	"Tr(\"STR_KEY\")",
	"text = \"STR_KEY\"",
	"title = \"STR_KEY\"",
	"hint_tooltip = \"STR_KEY\"",
	]
@export var file_types_to_search: Array[String] = [
	".gd",
	".cs",
	".vs",
	".tscn",
	".tres",
	".scn",
	".res",
	]: set = set_file_types_to_search
@export var directories_to_ignore: Array[String] = [
	"res://.git/",
	"res://.import/",
	"res://addons/",
	"res://localization/",
	]
@export var locales: Array[String] = ["en"]
@export var tag_seperator:= "$$"
@export var require_tag:= false
@export var remove_unused:= true: set = set_remove_unused
@export var modified_files_only:= false: set = set_modified_files_only
@export var print_debug_output:= false

var editor_inspector: EditorInspector # allows interactively correcting invalid options

func set_file_types_to_search(value: Array[String]):
	var file_types: Array[String] = []
	for ft in value:
		if ft.begins_with("."):
			file_types.append(ft)
		else:
			file_types.append("." + ft)
	file_types_to_search = file_types
	if editor_inspector:
		editor_inspector.refresh()


# remove_unused and modified_files_only are incompatible, so they need to turn off the other:
func set_remove_unused(value: bool):
	remove_unused = value
	if value:
		modified_files_only = false
		if editor_inspector:
			editor_inspector.refresh()


func set_modified_files_only(value: bool):
	modified_files_only = value
	if value:
		remove_unused = false
		if editor_inspector:
			editor_inspector.refresh()
