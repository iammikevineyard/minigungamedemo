extends SceneTree


func _initialize() -> void:
	var path := "res://assets/models/rotarycannonfbx.glb"
	var scene := load(path) as PackedScene
	print("ASSET ", path, " scene=", scene != null)
	if not scene:
		quit()
		return
	var root := scene.instantiate() as Node3D
	get_root().add_child(root)
	var aabb := _aggregate_aabb(root)
	print("root=", root.name, " aabb_pos=", aabb.position, " aabb_size=", aabb.size, " center=", aabb.get_center())
	print_tree(root, 0, 80, Transform3D.IDENTITY)
	root.free()
	quit()


func print_tree(node: Node, depth: int, limit: int, xform: Transform3D) -> void:
	if limit <= 0:
		return
	var indent := ""
	for i in range(depth):
		indent += "  "
	var current_xform := xform
	if node is Node3D:
		current_xform = xform * (node as Node3D).transform
	if node is MeshInstance3D:
		var mi := node as MeshInstance3D
		var box := current_xform * mi.get_aabb()
		print(indent, node.name, " [Mesh] world_pos=", current_xform.origin, " local_pos=", mi.position, " aabb=", box)
	elif node is Node3D:
		var n3 := node as Node3D
		print(indent, node.name, " [Node3D] world_pos=", current_xform.origin, " local_pos=", n3.position, " rot=", n3.rotation, " scale=", n3.scale)
	else:
		print(indent, node.name, " [", node.get_class(), "]")
	var next_limit := limit - 1
	for child in node.get_children():
		if next_limit <= 0:
			return
		print_tree(child, depth + 1, next_limit, current_xform)
		next_limit -= 1


func _aggregate_aabb(root: Node3D) -> AABB:
	var result := AABB()
	var first := true
	var stack: Array = [{"node": root, "xform": Transform3D.IDENTITY}]
	while stack.size() > 0:
		var entry: Dictionary = stack.pop_back()
		var current: Node = entry["node"]
		var xform: Transform3D = entry["xform"]
		if current is VisualInstance3D:
			var box: AABB = xform * (current as VisualInstance3D).get_aabb()
			if first:
				result = box
				first = false
			else:
				result = result.merge(box)
		for child in current.get_children():
			var child_xform: Transform3D = xform
			if child is Node3D:
				child_xform = xform * (child as Node3D).transform
			stack.push_back({"node": child, "xform": child_xform})
	return result
