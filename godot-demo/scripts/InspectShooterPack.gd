extends SceneTree


func _initialize() -> void:
	var files := [
		"Ch35_nonPBR.fbx",
		"rifle aiming idle.fbx",
		"rifle run.fbx",
		"walking.fbx",
		"walking backwards.fbx",
		"strafe.fbx",
		"strafe (2).fbx",
		"firing rifle.fbx"
	]
	for file_name in files:
		_inspect_asset("res://assets/models/shooter_pack/%s" % file_name, file_name)

	var zombie_files := [
		"Warzombie F Pedroso.fbx",
		"zombie idle.fbx",
		"zombie walk.fbx",
		"zombie run.fbx",
		"zombie attack.fbx",
		"zombie death.fbx",
		"zombie dying.fbx",
		"zombie crawl.fbx"
	]
	for file_name in zombie_files:
		_inspect_asset("res://assets/models/scary_zombie_pack/%s" % file_name, file_name)
	quit()


func _inspect_asset(path: String, label: String) -> void:
		var scene := load(path) as PackedScene
		print("\nASSET ", label, " scene=", scene != null)
		if not scene:
			return
		var root := scene.instantiate()
		var anim := _find_anim_player(root)
		var skel := _find_skeleton(root)
		if anim:
			print("  animations=", anim.get_animation_list())
			if label in ["rifle run.fbx", "walking.fbx", "walking backwards.fbx", "strafe.fbx", "strafe (2).fbx"]:
				_print_position_tracks(anim)
		else:
			print("  animations=<none>")
		if skel:
			var bones := []
			for i in range(mini(skel.get_bone_count(), 36)):
				bones.append(skel.get_bone_name(i))
			print("  skeleton=", skel.name, " bones=", skel.get_bone_count(), " sample=", bones)
		else:
			print("  skeleton=<none>")
		root.free()


func _print_position_tracks(anim_player: AnimationPlayer) -> void:
	var anim_name := "mixamo_com"
	if not anim_player.has_animation(anim_name):
		anim_name = "Take 001"
	if not anim_player.has_animation(anim_name):
		return
	var anim := anim_player.get_animation(anim_name)
	for i in range(anim.get_track_count()):
		if anim.track_get_type(i) != Animation.TYPE_POSITION_3D:
			continue
		var count := anim.track_get_key_count(i)
		if count <= 0:
			continue
		var first = anim.track_get_key_value(i, 0)
		var last = anim.track_get_key_value(i, count - 1)
		print("    pos track ", i, " path=", anim.track_get_path(i), " first=", first, " last=", last)


func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_anim_player(child)
		if found:
			return found
	return null


func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node
	for child in node.get_children():
		var found := _find_skeleton(child)
		if found:
			return found
	return null
