static func get_characters_in_collection(input_string, index, collection):
	return __get_characters_in_collection(input_string, index, collection)
	
static func get_characters_not_in_collection(input_string, index, collection):
	return __get_characters_in_collection(input_string, index, collection, true)

static func __get_characters_in_collection(input_string, index, collection, invert = false):
	var result_collection = __join_collections(collection)
	
	var result_string = ''
	
	var current_character = input_string[index]
	if invert:
		while index < input_string.length() - 1 and not current_character in result_collection:
			result_string += current_character
			index += 1
			current_character = input_string[index]
	else:
		while index < input_string.length() - 1 and current_character in result_collection:
			result_string += current_character
			index += 1
			current_character = input_string[index]

	return result_string

static func __join_collections(collection):
	var result_collection = []

	for entry in collection:
		var type = typeof(entry)
		if type == TYPE_ARRAY:
			for character in entry:
				result_collection.push_back(character)
		elif type == TYPE_STRING:
			result_collection.push_back(entry)

	return result_collection
