class_name SkCsvWriter
extends RefCounted
var path: String
var tag_seperator: String
var csv_delimiter: String
var removed_keys:= []
var write_successful:= false
var old_locales: Array
var old_keys:= []

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
		
		# Ensure we're reading as UTF-8
		file.set_big_endian(false)
		
		old_locales = Array(file.get_csv_line(csv_delimiter))  # Convert to Array
		old_locales.remove_at(0) # gets rid of the "key" in the first column
		while not file.eof_reached():
			var line = file.get_csv_line(csv_delimiter)
			if line.size() > 0:  # Skip empty lines
				old_keys.append(Array(line))  # Convert to Array
		file.close()

func write_keys_to_csv_file(keys: Array, locales: Array, remove_unused: bool):
	if are_locales_invalid(old_locales, locales):
		print("Error: StringKeys locales don't match .csv file, failed")
		write_successful = false
		return
	
	make_sure_directory_exists()
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		print("Error: Could not open file for writing: ", path)
		write_successful = false
		return
	
	# Force UTF-8 encoding by writing BOM (optional but can help with some editors)
	# Uncomment the next line if you want BOM for better editor compatibility
	# file.store_8(0xEF); file.store_8(0xBB); file.store_8(0xBF)
	
	file.store_csv_line(["key"] + locales, csv_delimiter) # First line with locales
	var old_index := 0
	var new_index := 0
	while old_index < old_keys.size() and new_index < keys.size(): # Both left, compare new and old and add in alphabetical order
		var comparision = old_keys[old_index][0].casecmp_to(keys[new_index])
		if comparision == -1: # add next old key
			if (not keys.has(old_keys[old_index][0])) and remove_unused:
				removed_keys.append(old_keys[old_index][0])
			else:
				file.store_csv_line(old_keys[old_index] + make_filler_strings(old_keys[old_index].size()), csv_delimiter)
			old_index += 1
		elif comparision == 1: # add next new key
			file.store_csv_line([keys[new_index], text_from_key(keys[new_index])] + make_filler_strings(2), csv_delimiter)
			new_index += 1
		elif comparision == 0: # keys are equal, skip new and use old to keep manual work
			file.store_csv_line(old_keys[old_index] + make_filler_strings(old_keys[old_index].size()), csv_delimiter)
			old_index += 1
			new_index += 1
		else:
			print("Error: StringKeys old key comparison failed")
	while old_index < old_keys.size(): # If only old keys left, add old
		if (not keys.has(old_keys[old_index][0])) and remove_unused:
			removed_keys.append(old_keys[old_index][0])
		else:
			file.store_csv_line(old_keys[old_index] + make_filler_strings(old_keys[old_index].size()), csv_delimiter)
		old_index += 1
	while new_index < keys.size(): # If only new keys left, add new
		file.store_csv_line([keys[new_index], text_from_key(keys[new_index])] + make_filler_strings(2), csv_delimiter)
		new_index += 1
	
	file.close()
	
	# Additional step: Verify and fix encoding if needed
	_ensure_utf8_encoding()
	
	print("StringKeys: Keys saved to .csv file with UTF-8 encoding")
	write_successful = true

# Helper function to ensure UTF-8 encoding
func _ensure_utf8_encoding():
	# Read the file back and check for encoding issues
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return
	
	var content = file.get_as_text()
	file.close()
	
	# Check if we have any replacement characters (indicates encoding issues)
	if content.find("�") != -1:
		print("Warning: Encoding issues detected in CSV file. Consider manually saving as UTF-8.")
	
	# Optionally, we could rewrite the file with explicit UTF-8 handling
	# This is a more robust approach for problematic characters
	_write_utf8_safe(content)

# Write content with explicit UTF-8 safety
func _write_utf8_safe(content: String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return
	
	# Convert string to UTF-8 bytes and write
	var utf8_bytes = content.to_utf8_buffer()
	file.store_buffer(utf8_bytes)
	file.close()

# locales are invalid if the new ones don't match the old (the new can have additional locales added though)
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

func make_filler_strings(filled: int) -> Array: # fills in empty slots, as godot doesn't use keys that don't have a translation in all locales
	var array = []
	for i in range(0, old_locales.size() - filled + 1):
		array.append("")
	return array
