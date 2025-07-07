extends Node

func parse_string_from_variables(string_to_parse : String, node_to_get_variables_from):
	print("parsing string")
	
	var dict = {}
	dict.clear()
	
	for i in node_to_get_variables_from.get_property_list():
		dict[i.name] = node_to_get_variables_from.get(i.name)
	
	var txt = string_to_parse.format(dict)
	return txt


func variable_in_range(variable,min_value,max_value):
	if (variable >= min_value && variable < max_value): return true
	else: return false


func find_closest_node_to_point(array:Array[Node], point, group = ""):
	## Returns the closest node to "point" in "array".
	## Can be used in 2D and 3D.
	var closest_node = null
	var closest_node_distance = 0.0
	for i in array:
		if group == "" or i.is_in_group(group):
			var current_node_distance = point.distance_to(i.global_position)
			if closest_node == null or current_node_distance < closest_node_distance:
				closest_node = i
				closest_node_distance = current_node_distance
	return closest_node


func get_all_children(node,type=null) -> Array:
	## Gets all children, grandchildren, great-grandchildren etc of "node".
	## "type" can optionally be used to only return nodes belonging to a specific class.
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			if type == null or is_instance_of(N,type): nodes.append(N)
			nodes.append_array(get_all_children(N,type))
		else:
			if type == null or is_instance_of(N,type): nodes.append(N)
	print(nodes)
	return nodes


func get_files(path,extension = "tscn"):
	## Returns a dictionary of filenames at "path", which all lead to their respective filepaths.
	## "extension" can be used to filter a specific file type.
	var files = {}
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
			else:
				if file_name.get_extension() == extension:
					var full_path = path.path_join(file_name)
					files[file_name] = full_path
					print("Added file " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return files


func get_sine(siner : float, amplitude := 1.0, frequency := 1.0):
	var sine = sin(siner * frequency) * amplitude
	return sine
