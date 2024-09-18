class_name Resolution extends RefCounted

var width: int
var height: int
var aspect_ratio: String


func _init(p_width: int, p_height: int, p_aspect_ratio: String) -> void:
	width = p_width
	height = p_height
	aspect_ratio = p_aspect_ratio


func _to_string() -> String:
	return get_as_string()


func get_as_string() -> String:
	return "%d x %d (%s)" % [width, height, aspect_ratio]


static func resolution_array_to_string_array(
	resolutions: Array[Resolution],
) -> Array[String]:

	var result: Array[String] = []
	for resolution in resolutions:
		result.append(resolution.get_as_string())

	return result


static func resolution_to_settings_string(resolution: Resolution) -> String:
	var result: String = "%dx%d" % [resolution.width, resolution.height]

	return result


static func search_array_with_vector2i(
	search_vector: Vector2i,
	resolutions: Array[Resolution],
) -> int:
	var search_index: int = -1
	for resolution in resolutions:
		if (
			resolution.width == search_vector.x
			and resolution.height == search_vector.y
		):
			search_index = resolutions.find(resolution)

	return search_index


static func settings_string_to_resolution(settings_string: String) -> Resolution:
	var split_array: PackedStringArray = settings_string.split("x")
	var resolution_options: Array[Resolution] = Settings.get_resolution_options()
	var found_resolution: Resolution
	for resolution in resolution_options:
		if (
			int(split_array[0]) ==  resolution.width
			and int(split_array[1]) == resolution.height
		):
			found_resolution = resolution

	return found_resolution
