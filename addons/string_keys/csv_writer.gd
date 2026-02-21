class_name SkCsvWriter
extends RefCounted
var path: String
var tag_seperator: String
var csv_delimiter: String
var removed_keys:= []
var write_successful:= false
var old_locales: Array
var old_keys:= []
var _locales: Array # authoritative locale list, set at write time

func _init(file_path: String, key_tag_seperator: String, delimiter: String = ";"):
	path = file_path
	tag_seperator = key_tag_seperator
	csv_delimiter = delimiter

func read_old_csv_file():
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file == null:
			print("Error: Could not open file for reading: ", path)
			return
		
		file.set_big_endian(false)
		
		old_locales = Array(file.get_csv_line(csv_delimiter))
		old_locales.remove_at(0)
		while not file.eof_reached():
			var line = file.get_csv_line(csv_delimiter)
			# Skip blank rows and category comment rows
			if line.size() > 0 and line[0] != "" and not line[0].begins_with("#"):
				old_keys.append(Array(line))
		file.close()

func write_keys_to_csv_file(keys_by_file: Dictionary, locales: Array, remove_unused: bool):
	if are_locales_invalid(old_locales, locales):
		print("Error: StringKeys locales don't match .csv file, failed")
		write_successful = false
		return
	
	# Store as authoritative source for column counts — never depends on
	# old_locales being populated, which would silently break on a fresh CSV.
	_locales = locales
	
	make_sure_directory_exists()
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print("Error: Could not open file for writing: ", path)
		write_successful = false
		return
	
	var old_key_map: Dictionary = {}
	for row in old_keys:
		old_key_map[row[0]] = row
	
	var all_new_keys: Dictionary = {}
	for source_file in keys_by_file:
		for key in keys_by_file[source_file]:
			all_new_keys[key] = true
	
	file.store_csv_line(["key"] + locales, csv_delimiter)
	
	var sorted_files: Array = keys_by_file.keys()
	sorted_files.sort()
	
	var written_keys: Dictionary = {}
	var first_section := true
	
	for source_file in sorted_files:
		var file_keys: Array = keys_by_file[source_file]
		if file_keys.is_empty():
			continue
		
		var section_keys: Array = []
		for key in file_keys:
			if not written_keys.has(key):
				section_keys.append(key)
		
		if section_keys.is_empty():
			continue
		
		# Blank separator between sections as a proper CSV row so re-reads stay clean
		if not first_section:
			file.store_csv_line(make_filler_strings(0), csv_delimiter)
		first_section = false
		
		# Category comment header — Godot's CSV importer skips rows whose key starts with #
		file.store_csv_line(["# " + source_file] + make_filler_strings(1), csv_delimiter)
		
		for key in section_keys:
			written_keys[key] = true
			if old_key_map.has(key):
				var row: Array = old_key_map[key]
				file.store_csv_line(row + make_filler_strings(row.size()), csv_delimiter)
			else:
				file.store_csv_line([key] + make_filler_strings(1), csv_delimiter)
	
	var orphaned_keys: Array = []
	for key in old_key_map:
		if not all_new_keys.has(key):
			orphaned_keys.append(key)
	
	if orphaned_keys.size() > 0:
		orphaned_keys.sort()
		if remove_unused:
			for key in orphaned_keys:
				removed_keys.append(key)
		else:
			file.store_csv_line(make_filler_strings(0), csv_delimiter)
			file.store_csv_line(["# (no longer found in source)"] + make_filler_strings(1), csv_delimiter)
			for key in orphaned_keys:
				var row: Array = old_key_map[key]
				file.store_csv_line(row + make_filler_strings(row.size()), csv_delimiter)
	
	file.close()
	_ensure_utf8_encoding()
	
	print("StringKeys: Keys saved to .csv file with UTF-8 encoding")
	write_successful = true

func _ensure_utf8_encoding():
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	var content = file.get_as_text()
	file.close()
	if content.find("?") != -1:
		print("Warning: Encoding issues detected in CSV file. Consider manually saving as UTF-8.")
	_write_utf8_safe(content)

func _write_utf8_safe(content: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	file.store_buffer(content.to_utf8_buffer())
	file.close()

func are_locales_invalid(l1: Array, l2: Array) -> bool:
	for i in range(0, min(l1.size(), l2.size())):
		if l1[i] != l2[i]:
			return true
	return false

func make_sure_directory_exists():
	var dir_path = path.get_base_dir()
	if not DirAccess.dir_exists_absolute(dir_path):
		DirAccess.make_dir_recursive_absolute(dir_path)

func text_from_key(key: String) -> String:
	var tag_index:= key.find(tag_seperator)
	if tag_index == -1:
		return key
	else:
		return key.substr(tag_index + tag_seperator.length())

func make_filler_strings(filled: int) -> Array:
	var array = []
	for i in range(0, _locales.size() - filled + 1):
		array.append("")
	return array
