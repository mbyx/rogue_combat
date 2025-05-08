extends Resource
class_name Util


static func reverse_mapping(enum_: Dictionary) -> Dictionary:
	print(enum_)
	var keys: Array = enum_.keys()
	var values: Array = enum_.values()

	var mapping: Dictionary = {}
	for index in range(keys.size()):
		mapping[values[index]] = keys[index]
	
	return mapping
