extends Node3D

const SPIN_UP_AUDIO := "res://assets/audio/minigun-spin-up.wav"
const SUSTAINED_AUDIO := "res://assets/audio/minigun-sustained-loop.wav"
const CASING_AUDIO := "res://assets/audio/minigun-casing-loop.wav"
const ZOMBIE_IMPACT_AUDIO := "res://assets/audio/zombie-impact-layer.wav"
const ZOMBIE_DEATH_AUDIO := "res://assets/audio/zombie-death.wav"
const MUSIC_AUDIO := "res://assets/audio/turbo-black.mp3"
const ZOMBIE_TEXTURE := "res://assets/sprites/zombie-billboard.png"
const OPERATOR_MODEL := "res://assets/models/shooter_pack/Ch35_nonPBR.fbx"
const SHOOTER_PACK_DIR := "res://assets/models/shooter_pack"
const ZOMBIE_PACK_DIR := "res://assets/models/scary_zombie_pack"
const ZOMBIE_MODEL := "res://assets/models/scary_zombie_pack/Warzombie F Pedroso.fbx"

const OPERATOR_TARGET_HEIGHT := 1.95
const OPERATOR_ROT_OFFSET := PI
const ZOMBIE_TARGET_HEIGHT := 1.85
const ZOMBIE_ROT_OFFSET := PI

const WEAPON_MODEL := "res://assets/models/rotarycannonfbx.glb"
const AK_MODEL := "res://assets/models/rainier_ak_-_3d.glb"
const KATANA_MODEL := "res://assets/models/katana.glb"
const WEAPON_TARGET_LENGTH := 2.55
const WEAPON_FOLLOW_OFFSET := Vector3(0.24, 1.38, -0.42)
const WEAPON_MODEL_OFFSET := Vector3(0.0, 0.0, 0.0)
const WEAPON_MODEL_ROTATION := Vector3(0.0, PI, 0.0)
const AK_TARGET_LENGTH := 1.38
const AK_MODEL_OFFSET := Vector3(0.0, -0.01, -0.48)
const AK_MODEL_ROTATION := Vector3(0.0, PI / 2.0, 0.0)
const KATANA_TARGET_LENGTH := 1.85
const KATANA_MODEL_OFFSET := Vector3(0.0, -0.04, -0.92)
const KATANA_MODEL_ROTATION := Vector3(0.0, PI / 2.0, 0.1)
const ATTACH_WEAPON_TO_HAND := true
const WEAPON_HAND_BONE_CANDIDATES := ["mixamorig:RightHand", "RightHand", "hand_r", "Hand.R", "CC_Base_R_Hand"]
const WEAPON_GRIP_OFFSET := Vector3(0.0, 0.0, -0.25)
const WEAPON_GRIP_ROTATION := Vector3(0, -PI / 2.0, -PI / 2.0)

const MAX_ZOMBIES := 120
const MAX_TRACERS := 110
const MAX_CASINGS := 240
const MAX_BLOOD_DECALS := 760
const MAX_FOOTPRINTS := 140
const MAX_GRENADES := 8
const MAX_FIRE_PATCHES := 28
const ZOMBIE_ATTACK_RANGE := 1.55
const ZOMBIE_ATTACK_RELEASE := 1.95
const MAX_BLOOD_DROPS := 360
const MAX_IMPACTS := 170
const ZOMBIE_SEPARATION_ITERATIONS := 2
const ZOMBIE_SEPARATION_PADDING := 0.08
const ARENA_HALF := 140.0
const MULTIKILL_WINDOW := 1.1
const GRENADE_COOLDOWN := 1.6
const GRENADE_FUSE := 1.6
const GRENADE_RADIUS := 8.5
const GRENADE_DAMAGE := 18.0
const FIRE_PATCH_DURATION := 7.0
const FIRE_PATCH_RADIUS := 3.4
const FIRE_PATCH_DPS := 5.8
const BURN_DURATION := 4.8
const BURN_TICK_RATE := 0.28
const BURN_TICK_DAMAGE := 0.68
const DEATH_FEAST_RADIUS := 6.2
const DEATH_FEAST_BLOOD_INTERVAL := 0.16
const BIG_ZOMBIE_WAVE_THRESHOLD := 3
const SHOTGUN_COOLDOWN := 0.62
const SHOTGUN_RANGE := 23.0
const SHOTGUN_CONE_DOT := 0.78
const SHOTGUN_DAMAGE := 7.5
const SHOTGUN_MAX_TARGETS := 10
const SHOTGUN_PELLETS := 16
const AK_RANGE := 62.0
const AK_DAMAGE := 2.75
const AK_FIRE_RATE := 10.5
const AK_MAX_TARGETS := 2
const KATANA_COOLDOWN := 0.54
const KATANA_RANGE := 3.45
const KATANA_CONE_DOT := 0.28
const KATANA_DAMAGE := 28.0
const MINIGUN_START_AMMO := 1200
const SHOTGUN_START_AMMO := 36
const AK_START_AMMO := 240
const LEADERBOARD_PATH := "user://leaderboard.json"
const UI_MINIGUN_ICON := "res://assets/ui/minigun-barrel-icon.png"
const UI_WEAPON_SHEET := "res://assets/ui/hud-concept-sheet.png"
const UI_EXTRACT_REGION := Rect2(1158.0, 52.0, 492.0, 224.0)
const UI_KILLS_REGION := Rect2(1290.0, 642.0, 346.0, 260.0)
const UI_LEADERBOARD_REGION := Rect2(1290.0, 642.0, 346.0, 260.0)
const UI_SHOTGUN_REGION := Rect2(368.0, 292.0, 302.0, 304.0)
const UI_AK_REGION := Rect2(678.0, 292.0, 302.0, 304.0)
const UI_KATANA_REGION := Rect2(990.0, 292.0, 302.0, 304.0)
const UI_HP_BAR_WIDTH := 248.0
const EXTRACTION_UNLOCK_WAVE := 5
const EXTRACTION_UNLOCK_KILLS := 250
const EXTRACTION_HOLD_TIME := 25.0
const EXTRACTION_RADIUS := 5.8
const EXTRACTION_SCORE_BONUS := 1000

var rng := RandomNumberGenerator.new()

var player: Node3D
var body: Node3D
var barrel_cluster: Node3D
var muzzle_light: OmniLight3D
var muzzle_flash: MeshInstance3D
var camera: Camera3D
var camera_distance := 17.0
var target_camera_distance := 17.0
var pointer_world := Vector3.ZERO
var velocity := Vector3.ZERO
var firing := false
var active_weapon := 1
var shotgun_cooldown_remaining := 0.0
var shotgun_flash_timer := 0.0
var spin := 0.0
var shot_accumulator := 0.0
var belt_travel := 0.0
var belt_segments: Array = []
var belt_curve: Curve3D
var step_time := 0.0

var elapsed := 0.0
var wave := 1
var kills := 0
var spawn_timer := 0.15
var burst_timer := 7.0

var zombies: Array = []
var tracers: Array = []
var casings: Array = []
var blood_decals: Array = []
var blood_drops: Array = []
var impacts: Array = []

var operator_anim: AnimationPlayer
var operator_skeleton: Skeleton3D
var operator_idle_clip: String = ""
var operator_walk_clip: String = ""
var operator_run_clip: String = ""
var operator_back_clip: String = ""
var operator_strafe_left_clip: String = ""
var operator_strafe_right_clip: String = ""
var operator_state: String = ""
var zombie_idle_clip := "zombie_idle"
var zombie_walk_clip := "zombie_walk"
var zombie_run_clip := "zombie_run"
var zombie_attack_clip := "zombie_attack"
var zombie_death_clip := "zombie_death"
var operator_leg_bones := {}
var weapon_anchor: Node3D
var weapon_root: Node3D
var imported_weapon_model: Node3D
var shotgun_model: Node3D
var ak_model: Node3D
var katana_model: Node3D
var ammo_pack: Node3D
var muzzle_marker: Marker3D
var casing_marker: Marker3D
var barrel_spin_axis := "z"
var green_light: OmniLight3D
var green_pulse: float = 0.0

var recoil_kick: float = 0.0
var shake_intensity: float = 0.0
var fov_pulse_amount: float = 0.0
var sustained_fire_time: float = 0.0
var hit_stop_until_msec: int = 0
const BASE_FOV := 48.0

var footprints: Array = []
var footprint_index: int = 0
var footprint_step_distance: float = 0.0
var last_footprint_pos: Vector3 = Vector3.ZERO
var blood_charge: float = 0.0
var grenades: Array = []
var fire_patches: Array = []
var grenade_cooldown_remaining: float = 0.0
var recent_kills: Array = []
var multikill_label: Label
var multikill_decay: float = 0.0
var kills_giant_label: Label
var kills_pulse: float = 0.0
var minigun_ammo := MINIGUN_START_AMMO
var shotgun_ammo := SHOTGUN_START_AMMO
var ak_ammo := AK_START_AMMO
var ak_shot_accumulator := 0.0
var ak_flash_timer := 0.0
var katana_cooldown_remaining := 0.0
var katana_swing_timer := 0.0

var player_health: float = 100.0
var player_max_health: float = 100.0
var player_damage_flash: float = 0.0
var player_dead: bool = false
var game_paused: bool = false
var death_camera_timer: float = 0.0
var death_camera_target: Node3D = null
var death_zoom_distance: float = 5.0
var death_blood_timer: float = 0.0
var death_overlay: ColorRect
var death_label: Label
var death_sublabel: Label
var health_bar_bg: ColorRect
var health_bar_fill: ColorRect
var health_bar_label: Label
var damage_vignette: ColorRect
var grenade_flash_nodes: Array = []
var weapon_mode_label: Label
var weapon_selector: HBoxContainer
var weapon_cards: Array = []
var kills_frame: TextureRect
var extraction_frame: TextureRect
var leaderboard_frame: TextureRect
var extraction_panel: PanelContainer
var leaderboard_panel: PanelContainer
var status_panel: PanelContainer
var pause_overlay: ColorRect
var pause_label: Label
var leaderboard_label: Label
var initials_label: Label
var leaderboard: Array = []
var entering_initials := false
var current_initials := ""
var score_submitted := false
var final_score_override := -1
var extraction_unlocked := false
var extraction_complete := false
var extraction_timer := 0.0
var extraction_position := Vector3.ZERO
var extraction_big_timer := 0.0
var extraction_marker: Node3D
var extraction_ring: MeshInstance3D
var extraction_core: MeshInstance3D
var extraction_light: OmniLight3D
var extraction_label: Label

var spin_up_player: AudioStreamPlayer
var sustained_player: AudioStreamPlayer
var casing_loop_player: AudioStreamPlayer
var music_player: AudioStreamPlayer
var impact_players: Array = []
var death_players: Array = []
var last_impact_sound_ms := 0

var kills_label: Label
var wave_label: Label
var zoom_label: Label
var spin_label: Label
var zombie_label: Label

var mat_armor: StandardMaterial3D
var mat_armor_edge: StandardMaterial3D
var mat_black: StandardMaterial3D
var mat_weapon: StandardMaterial3D
var mat_hot: StandardMaterial3D
var mat_brass: StandardMaterial3D
var mat_blood: StandardMaterial3D
var mat_blood_dark: StandardMaterial3D
var mat_zombie: StandardMaterial3D
var mat_zombie_flash: StandardMaterial3D
var mat_zombie_burning: StandardMaterial3D
var mat_fire: StandardMaterial3D
var mat_tracer: StandardMaterial3D
var mat_impact: StandardMaterial3D
var mat_dust: StandardMaterial3D


func _ready() -> void:
	DisplayServer.window_set_title("Minigunner Horde Demo - Clean Rig")
	rng.randomize()
	_build_materials()
	_build_world()
	_build_player()
	_build_pools()
	_build_audio()
	_load_leaderboard()
	_build_hud()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if extraction_complete:
			if entering_initials:
				_handle_initials_input(event)
				return
			if event.keycode == KEY_R:
				_restart_game()
				return
			return
		if player_dead:
			if entering_initials:
				_handle_initials_input(event)
				return
			if event.keycode == KEY_R:
				_restart_game()
				return
			return
		if event.keycode == KEY_SPACE:
			_toggle_pause()
			return
		if game_paused:
			return
		if event.keycode == KEY_1:
			_set_active_weapon(1)
			return
		if event.keycode == KEY_2:
			_set_active_weapon(2)
			return
		if event.keycode == KEY_3:
			_set_active_weapon(3)
			return
		if event.keycode == KEY_4:
			_set_active_weapon(4)
			return
	if player_dead or extraction_complete:
		return
	if game_paused:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and active_weapon == 1:
				_start_firing()
			elif event.pressed and active_weapon == 2:
				_fire_shotgun()
			elif event.pressed and active_weapon == 3:
				_start_ak_fire()
			elif event.pressed and active_weapon == 4:
				_swing_katana()
			elif active_weapon == 1 or active_weapon == 3:
				firing = false
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			_throw_grenade(_screen_to_ground(event.position))
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			target_camera_distance = clamp(target_camera_distance - 1.6, 11.0, 34.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			target_camera_distance = clamp(target_camera_distance + 1.6, 11.0, 34.0)


func _process(delta: float) -> void:
	delta = min(delta, 0.033)
	if game_paused:
		_update_hud()
		return
	if hit_stop_until_msec > 0 and Time.get_ticks_msec() >= hit_stop_until_msec:
		hit_stop_until_msec = 0
		Engine.time_scale = 1.0
	if player_dead:
		_update_player_death_pose(delta)
		_update_death_camera(delta)
		_update_zombies(delta)
		_update_fire_patches(delta)
		_update_blood(delta)
		_update_impacts(delta)
		_update_hud()
		return
	if extraction_complete:
		_update_extraction_complete(delta)
		_update_hud()
		return
	_update_pointer_world()
	_update_player(delta)
	_update_waves(delta)
	_update_extraction(delta)
	_update_zombies(delta)
	_update_weapon(delta)
	_update_tracers(delta)
	_update_casings(delta)
	_update_blood(delta)
	_update_impacts(delta)
	_update_camera(delta)
	_update_audio(delta)
	_update_neon(delta)
	_update_grenades(delta)
	_update_fire_patches(delta)
	_update_grenade_flashes(delta)
	_update_damage_vignette(delta)
	_update_hud()


func _update_neon(delta: float) -> void:
	if green_light == null:
		return
	green_pulse += delta * 1.4
	green_light.light_energy = 5.0 + sin(green_pulse) * 1.6
	green_light.position = player.global_position + Vector3(sin(green_pulse * 0.4) * 4.0, 5.5, cos(green_pulse * 0.4) * 4.0)


func _build_materials() -> void:
	mat_zombie_flash = StandardMaterial3D.new()
	mat_zombie_flash.albedo_color = Color(1.0, 0.96, 0.62)
	mat_zombie_flash.emission_enabled = true
	mat_zombie_flash.emission = Color(1.0, 0.72, 0.28)
	mat_zombie_flash.emission_energy_multiplier = 4.5
	mat_zombie_flash.roughness = 0.4
	mat_zombie_burning = StandardMaterial3D.new()
	mat_zombie_burning.albedo_color = Color(0.9, 0.26, 0.04)
	mat_zombie_burning.emission_enabled = true
	mat_zombie_burning.emission = Color(1.0, 0.3, 0.02)
	mat_zombie_burning.emission_energy_multiplier = 2.8
	mat_zombie_burning.roughness = 0.72

	mat_fire = StandardMaterial3D.new()
	mat_fire.albedo_color = Color(1.0, 0.38, 0.04, 0.72)
	mat_fire.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_fire.emission_enabled = true
	mat_fire.emission = Color(1.0, 0.32, 0.02)
	mat_fire.emission_energy_multiplier = 5.2
	mat_fire.cull_mode = BaseMaterial3D.CULL_DISABLED
	mat_fire.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS

	mat_armor = _mat(Color(0.045, 0.052, 0.055), 0.72, 0.58)
	mat_armor_edge = _mat(Color(0.25, 0.26, 0.25), 0.5, 0.75)
	mat_black = _mat(Color(0.015, 0.016, 0.018), 0.88, 0.2)
	mat_weapon = _mat(Color(0.09, 0.095, 0.1), 0.48, 0.86)
	mat_hot = _mat(Color(1.0, 0.34, 0.02), 0.28, 0.55)
	mat_hot.emission_enabled = true
	mat_hot.emission = Color(1.0, 0.25, 0.0)
	mat_hot.emission_energy_multiplier = 1.45
	mat_brass = _mat(Color(0.82, 0.57, 0.18), 0.32, 0.82)
	mat_brass.emission_enabled = true
	mat_brass.emission = Color(0.22, 0.12, 0.03)
	mat_brass.emission_energy_multiplier = 0.22
	mat_blood = _transparent_mat(Color(0.42, 0.0, 0.0, 0.86))
	mat_blood_dark = _transparent_mat(Color(0.11, 0.0, 0.0, 0.82))
	mat_tracer = _transparent_mat(Color(1.0, 0.53, 0.08, 0.82))
	mat_tracer.emission_enabled = true
	mat_tracer.emission = Color(1.0, 0.42, 0.05)
	mat_tracer.emission_energy_multiplier = 2.0
	mat_impact = _transparent_mat(Color(1.0, 0.66, 0.18, 0.96))
	mat_impact.emission_enabled = true
	mat_impact.emission = Color(1.0, 0.5, 0.08)
	mat_impact.emission_energy_multiplier = 2.4
	mat_dust = _transparent_mat(Color(0.46, 0.34, 0.25, 0.5))

	mat_zombie = StandardMaterial3D.new()
	var texture := load(ZOMBIE_TEXTURE) as Texture2D
	if texture:
		mat_zombie.albedo_texture = texture
	else:
		mat_zombie.albedo_color = Color(0.25, 0.55, 0.22)
	mat_zombie.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat_zombie.alpha_scissor_threshold = 0.18
	mat_zombie.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	mat_zombie.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat_zombie.no_depth_test = false
	mat_zombie.cull_mode = BaseMaterial3D.CULL_DISABLED


func _build_world() -> void:
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.01, 0.012, 0.014)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.18, 0.21, 0.24)
	env.ambient_light_energy = 0.55

	env.glow_enabled = true
	env.glow_intensity = 0.42
	env.glow_strength = 0.82
	env.glow_bloom = 0.08
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE
	env.glow_hdr_threshold = 0.7
	env.glow_hdr_scale = 2.2

	env.fog_enabled = true
	env.fog_density = 0.0006
	env.fog_aerial_perspective = 0.12

	env.adjustment_enabled = true
	env.adjustment_contrast = 1.08
	env.adjustment_saturation = 1.18

	environment.environment = env
	add_child(environment)

	var sun := DirectionalLight3D.new()
	sun.light_color = Color(1.0, 0.88, 0.72)
	sun.light_energy = 1.55
	sun.rotation_degrees = Vector3(-52, -38, 0)
	sun.shadow_enabled = true
	add_child(sun)

	var fill := DirectionalLight3D.new()
	fill.light_color = Color(0.3, 0.45, 0.6)
	fill.light_energy = 0.22
	fill.rotation_degrees = Vector3(-30, 145, 0)
	fill.shadow_enabled = false
	add_child(fill)

	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(ARENA_HALF * 2.0, ARENA_HALF * 2.0)
	var ground := MeshInstance3D.new()
	ground.mesh = ground_mesh
	ground.material_override = _build_ground_material()
	ground.position.y = -0.05
	add_child(ground)

	_build_stone_tile_floor()


func _build_stone_tile_floor() -> void:
	var tile_scene := load("res://assets/models/environment/stone_ground_01.glb") as PackedScene
	if tile_scene == null:
		return
	var tile_size_x := 14.0
	var tile_size_z := 25.0
	var tile_thickness := 0.612
	var tile_mesh_y_offset := 2.618
	var top_y := -0.04
	var tile_origin_offset := tile_thickness + tile_mesh_y_offset
	var cols: int = int(ceil(ARENA_HALF * 2.0 / tile_size_x)) + 1
	var rows: int = int(ceil(ARENA_HALF * 2.0 / tile_size_z)) + 1
	var start_x: float = -ARENA_HALF - tile_size_x * 0.5
	var start_z: float = -ARENA_HALF - tile_size_z * 0.5
	for r in range(rows):
		for c in range(cols):
			var tile := tile_scene.instantiate() as Node3D
			tile.position = Vector3(
				start_x + (float(c) + 0.5) * tile_size_x,
				top_y - tile_origin_offset,
				start_z + (float(r) + 0.5) * tile_size_z
			)
			tile.rotation.y = PI if ((r + c) % 2 == 0) else 0.0
			add_child(tile)

	for i in range(360):
		var shard := _box(Vector3(randf_range(0.25, 1.4), 0.025, randf_range(0.035, 0.13)), _mat(Color(randf_range(0.09, 0.16), randf_range(0.09, 0.12), randf_range(0.08, 0.09)), 0.9, 0.05))
		shard.position = Vector3(randf_range(-ARENA_HALF + 5, ARENA_HALF - 5), 0.025, randf_range(-ARENA_HALF + 5, ARENA_HALF - 5))
		shard.rotation.y = randf_range(0, TAU)
		add_child(shard)

	_build_perimeter_buildings()
	_build_neon_lights()
	_build_extraction_marker()


func _build_perimeter_buildings() -> void:
	var concrete := _mat(Color(0.085, 0.082, 0.078), 0.92, 0.05)
	var trim := _mat(Color(0.13, 0.12, 0.11), 0.7, 0.2)
	var window_mat := StandardMaterial3D.new()
	window_mat.albedo_color = Color(0.6, 0.42, 0.12)
	window_mat.emission_enabled = true
	window_mat.emission = Color(1.0, 0.55, 0.12)
	window_mat.emission_energy_multiplier = 1.6
	for side in 4:
		for i in range(7):
			var t: float = (float(i) + randf_range(-0.2, 0.2)) / 7.0
			var pos := _ring_position(side, t, ARENA_HALF * 0.86 + randf_range(-4.0, 4.0))
			var w: float = randf_range(7.0, 14.0)
			var d: float = randf_range(7.0, 13.0)
			var h: float = randf_range(7.0, 22.0)
			var building := _box(Vector3(w, h, d), concrete)
			building.position = pos + Vector3(0, h * 0.5, 0)
			building.rotation.y = randf_range(-0.18, 0.18)
			add_child(building)
			var roof := _box(Vector3(w * 1.05, 0.5, d * 1.05), trim)
			roof.position = Vector3(0, h * 0.5 + 0.25, 0)
			building.add_child(roof)
			var rows: int = int(maxf(2.0, h / 3.5))
			var cols: int = int(maxf(2.0, w / 2.5))
			for r in range(rows):
				for c in range(cols):
					if randf() > 0.55:
						continue
					var win := _box(Vector3(0.7, 1.1, 0.05), window_mat)
					var wx: float = lerpf(-w * 0.45, w * 0.45, float(c) / float(cols - 1)) if cols > 1 else 0.0
					var wy: float = lerpf(-h * 0.42, h * 0.42, float(r) / float(rows - 1)) if rows > 1 else 0.0
					win.position = Vector3(wx, wy, d * 0.5 + 0.05)
					building.add_child(win)


func _ring_position(side: int, t: float, distance: float) -> Vector3:
	var local: float = lerpf(-ARENA_HALF * 0.92, ARENA_HALF * 0.92, t)
	match side:
		0:
			return Vector3(local, 0, -distance)
		1:
			return Vector3(distance, 0, local)
		2:
			return Vector3(local, 0, distance)
		_:
			return Vector3(-distance, 0, local)


func _build_ground_material() -> StandardMaterial3D:
	var albedo := NoiseTexture2D.new()
	var noise := FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.06
	noise.fractal_octaves = 5
	albedo.noise = noise
	albedo.width = 1024
	albedo.height = 1024
	albedo.seamless = true
	albedo.color_ramp = _ground_color_ramp()

	var roughness_tex := NoiseTexture2D.new()
	var roughness_noise := FastNoiseLite.new()
	roughness_noise.noise_type = FastNoiseLite.TYPE_CELLULAR
	roughness_noise.frequency = 0.12
	roughness_tex.noise = roughness_noise
	roughness_tex.width = 512
	roughness_tex.height = 512
	roughness_tex.seamless = true

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.62, 0.62, 0.64)
	mat.albedo_texture = albedo
	mat.roughness = 1.0
	mat.metallic = 0.0
	mat.uv1_scale = Vector3(28, 28, 1)
	return mat


func _ground_color_ramp() -> Gradient:
	var g := Gradient.new()
	g.set_color(0, Color(0.06, 0.065, 0.072))
	g.set_color(1, Color(0.18, 0.18, 0.19))
	g.add_point(0.45, Color(0.11, 0.11, 0.12))
	g.add_point(0.78, Color(0.14, 0.13, 0.13))
	return g


func _build_neon_lights() -> void:
	green_light = OmniLight3D.new()
	green_light.light_color = Color(0.18, 1.0, 0.32)
	green_light.light_energy = 1.8
	green_light.omni_range = 12.0
	green_light.omni_attenuation = 1.4
	green_light.position = Vector3(0, 2.6, 0)
	add_child(green_light)

	var pillar_mat := StandardMaterial3D.new()
	pillar_mat.albedo_color = Color(0.05, 0.4, 0.12)
	pillar_mat.emission_enabled = true
	pillar_mat.emission = Color(0.2, 1.0, 0.35)
	pillar_mat.emission_energy_multiplier = 1.3
	pillar_mat.roughness = 0.35

	for i in range(6):
		var angle := float(i) / 6.0 * TAU
		var radius := 42.0
		var pillar := _cylinder(0.16, 1.6, pillar_mat)
		pillar.position = Vector3(cos(angle) * radius, 0.8, sin(angle) * radius)
		add_child(pillar)
		var pillar_light := OmniLight3D.new()
		pillar_light.light_color = Color(0.2, 1.0, 0.32)
		pillar_light.light_energy = 1.15
		pillar_light.omni_range = 7.0
		pillar_light.position = pillar.position + Vector3(0, 0.5, 0)
		add_child(pillar_light)


func _build_extraction_marker() -> void:
	extraction_marker = Node3D.new()
	extraction_marker.name = "ExtractionMarker"
	extraction_marker.visible = false
	add_child(extraction_marker)

	var ring_mat := _transparent_mat(Color(0.1, 1.0, 0.36, 0.26))
	ring_mat.emission_enabled = true
	ring_mat.emission = Color(0.08, 1.0, 0.28)
	ring_mat.emission_energy_multiplier = 1.8
	extraction_ring = _cylinder(EXTRACTION_RADIUS, 0.035, ring_mat)
	extraction_ring.position.y = 0.035
	extraction_marker.add_child(extraction_ring)

	var core_mat := _emissive_mat(Color(0.18, 1.0, 0.34), 5.0)
	extraction_core = _cylinder(0.26, 3.2, core_mat)
	extraction_core.position.y = 1.6
	extraction_marker.add_child(extraction_core)

	var cap := _sphere(Vector3(0.5, 0.5, 0.5), core_mat)
	cap.position.y = 3.32
	extraction_marker.add_child(cap)

	extraction_light = OmniLight3D.new()
	extraction_light.light_color = Color(0.16, 1.0, 0.34)
	extraction_light.light_energy = 5.0
	extraction_light.omni_range = 18.0
	extraction_light.omni_attenuation = 1.2
	extraction_light.position.y = 2.2
	extraction_marker.add_child(extraction_light)


func _build_player() -> void:
	player = Node3D.new()
	player.name = "Minigunner"
	add_child(player)

	body = Node3D.new()
	player.add_child(body)

	var operator_scene := load(OPERATOR_MODEL) as PackedScene
	if operator_scene:
		var operator := operator_scene.instantiate() as Node3D
		operator.rotation.y = OPERATOR_ROT_OFFSET
		body.add_child(operator)
		_normalize_height(operator, OPERATOR_TARGET_HEIGHT)
		operator_anim = _find_anim_player(operator)
		if operator_anim:
			operator_anim.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
			_import_shooter_animations()
		operator_skeleton = _find_skeleton(operator)
		_cache_operator_leg_bones()
		var hand_skel := _find_skeleton_with_bone(operator, WEAPON_HAND_BONE_CANDIDATES)
		if ATTACH_WEAPON_TO_HAND and hand_skel and operator_idle_clip != "":
			var weapon_bone := _find_bone_name(hand_skel, WEAPON_HAND_BONE_CANDIDATES)
			if weapon_bone != "":
				var attach := BoneAttachment3D.new()
				attach.bone_name = weapon_bone
				hand_skel.add_child(attach)
				weapon_anchor = attach
	else:
		_add_part(body, _box(Vector3(1.2, 0.55, 0.64), mat_armor), Vector3(0, 0.95, 0))
		_add_part(body, _box(Vector3(1.55, 1.35, 0.78), mat_armor), Vector3(0, 1.78, 0))
		_add_part(body, _sphere(Vector3(0.56, 0.43, 0.52), mat_armor), Vector3(0, 2.58, -0.04))

	var gun := Node3D.new()
	gun.name = "IndependentWeaponRig"
	add_child(gun)
	weapon_root = gun

	var imported_weapon_loaded := false
	if WEAPON_MODEL != "":
		imported_weapon_loaded = _build_imported_weapon(gun)

	_build_ammo_pack(body)
	if not imported_weapon_loaded:
		_build_minigun(gun)
	_build_shotgun_model(gun)
	ak_model = _build_weapon_asset(gun, AK_MODEL, AK_TARGET_LENGTH, AK_MODEL_OFFSET, AK_MODEL_ROTATION, "AKModel")
	katana_model = _build_weapon_asset(gun, KATANA_MODEL, KATANA_TARGET_LENGTH, KATANA_MODEL_OFFSET, KATANA_MODEL_ROTATION, "KatanaModel")
	_build_belt(body)

	muzzle_flash = _sphere(Vector3(0.42, 0.42, 0.42), _transparent_mat(Color(1.0, 0.45, 0.05, 0.0)))
	muzzle_flash.position = Vector3(0, 0, -1.58)
	muzzle_flash.visible = false
	gun.add_child(muzzle_flash)

	muzzle_marker = Marker3D.new()
	muzzle_marker.name = "MuzzleMarker"
	muzzle_marker.position = Vector3(0, 0, -1.58)
	gun.add_child(muzzle_marker)

	casing_marker = Marker3D.new()
	casing_marker.name = "CasingEjectMarker"
	casing_marker.position = Vector3(0.28, -0.08, -0.55)
	gun.add_child(casing_marker)

	muzzle_light = OmniLight3D.new()
	muzzle_light.light_color = Color(1.0, 0.42, 0.08)
	muzzle_light.light_energy = 0
	muzzle_light.omni_range = 11
	gun.add_child(muzzle_light)
	muzzle_light.position = Vector3(0, 0, -1.58)
	_refresh_weapon_visuals()

	camera = Camera3D.new()
	camera.name = "Camera"
	camera.fov = 48
	add_child(camera)


func _build_imported_weapon(parent: Node3D) -> bool:
	var weapon_scene := load(WEAPON_MODEL) as PackedScene
	if not weapon_scene:
		return false
	var weapon := weapon_scene.instantiate() as Node3D
	parent.add_child(weapon)
	imported_weapon_model = weapon
	_normalize_max_dimension(weapon, WEAPON_TARGET_LENGTH)
	weapon.position = WEAPON_MODEL_OFFSET
	weapon.rotation = WEAPON_MODEL_ROTATION
	_hide_imported_helper_nodes(weapon)

	var imported_barrels := weapon.find_child("Barrels", true, false) as Node3D
	if imported_barrels:
		barrel_cluster = imported_barrels
		barrel_spin_axis = "y"

	return true


func _build_weapon_asset(parent: Node3D, path: String, target_length: float, offset: Vector3, rotation: Vector3, model_name: String) -> Node3D:
	if path == "":
		return null
	var scene := load(path) as PackedScene
	if not scene:
		return null
	var model := scene.instantiate() as Node3D
	model.name = model_name
	model.visible = false
	parent.add_child(model)
	_normalize_max_dimension(model, target_length)
	model.position = offset
	model.rotation = rotation
	_hide_imported_helper_nodes(model)
	return model


func _build_shotgun_model(parent: Node3D) -> void:
	shotgun_model = Node3D.new()
	shotgun_model.name = "Shotgun"
	shotgun_model.visible = false
	parent.add_child(shotgun_model)

	var scene := load("res://assets/models/weapons/shotgun.glb") as PackedScene
	if scene:
		var visual := scene.instantiate() as Node3D
		shotgun_model.add_child(visual)
		_normalize_max_dimension(visual, 1.4)
		visual.rotation = WEAPON_MODEL_ROTATION
		visual.position = WEAPON_MODEL_OFFSET
	else:
		var stock_mat := _mat(Color(0.11, 0.075, 0.045), 0.72, 0.12)
		var dark_metal := _mat(Color(0.025, 0.027, 0.03), 0.36, 0.9)
		_add_part(shotgun_model, _box(Vector3(0.3, 0.22, 0.42), stock_mat), Vector3(0, -0.02, 0.42))
		_add_part(shotgun_model, _box(Vector3(0.22, 0.18, 0.48), stock_mat), Vector3(0, -0.02, 0.1))
		_add_part(shotgun_model, _box(Vector3(0.34, 0.2, 0.32), dark_metal), Vector3(0, 0.02, -0.18))


func _build_ammo_pack(parent: Node3D) -> void:
	var pack := Node3D.new()
	pack.name = "AmmoBackpack"
	pack.position = Vector3(0.0, 1.42, 0.38)
	parent.add_child(pack)
	ammo_pack = pack

	_add_part(pack, _box(Vector3(0.42, 0.66, 0.2), mat_weapon), Vector3(0, 0, 0))
	_add_part(pack, _box(Vector3(0.38, 0.08, 0.24), mat_armor_edge), Vector3(0, 0.36, 0))
	_add_part(pack, _box(Vector3(0.38, 0.08, 0.24), mat_armor_edge), Vector3(0, -0.36, 0))
	_add_part(pack, _box(Vector3(0.07, 0.72, 0.25), mat_armor_edge), Vector3(-0.26, 0, 0))
	_add_part(pack, _box(Vector3(0.07, 0.72, 0.25), mat_armor_edge), Vector3(0.26, 0, 0))
	_add_part(pack, _box(Vector3(0.18, 0.12, 0.1), mat_brass), Vector3(0.27, 0.2, -0.15))
	_add_part(pack, _box(Vector3(0.055, 0.64, 0.045), mat_black), Vector3(-0.15, 0.0, -0.15))
	_add_part(pack, _box(Vector3(0.055, 0.64, 0.045), mat_black), Vector3(0.15, 0.0, -0.15))


func _build_minigun(parent: Node3D) -> void:
	barrel_spin_axis = "z"
	_add_part(parent, _box(Vector3(0.44, 0.3, 0.42), mat_weapon), Vector3(0, 0, -0.16))
	_add_part(parent, _box(Vector3(0.34, 0.2, 0.24), mat_black), Vector3(0, -0.17, -0.02))
	_add_part(parent, _box(Vector3(0.64, 0.07, 0.09), mat_black), Vector3(0, -0.02, -0.01))
	_add_part(parent, _box(Vector3(0.18, 0.18, 0.12), mat_armor_edge), Vector3(0, 0, 0.18))
	_add_part(parent, _box(Vector3(0.12, 0.42, 0.1), mat_black), Vector3(-0.26, -0.08, -0.04), Vector3(0.0, 0.0, 0.28))
	_add_part(parent, _box(Vector3(0.12, 0.42, 0.1), mat_black), Vector3(0.26, -0.08, -0.04), Vector3(0.0, 0.0, -0.28))

	barrel_cluster = Node3D.new()
	barrel_cluster.name = "RotatingBarrelCluster"
	barrel_cluster.position = Vector3(0, 0, -0.52)
	parent.add_child(barrel_cluster)

	var rear_ring := _torus(0.18, 0.025, mat_hot)
	rear_ring.position = Vector3(0, 0, 0.05)
	barrel_cluster.add_child(rear_ring)

	var front_ring := _torus(0.18, 0.025, mat_hot)
	front_ring.position = Vector3(0, 0, -0.92)
	barrel_cluster.add_child(front_ring)

	var core := _cylinder(0.052, 1.08, mat_weapon)
	core.rotation.x = PI / 2.0
	core.position = Vector3(0, 0, -0.43)
	barrel_cluster.add_child(core)

	for i in range(6):
		var angle := float(i) / 6.0 * TAU
		var barrel := _cylinder(0.03, 1.2, mat_black)
		barrel.rotation.x = PI / 2.0
		barrel.position = Vector3(cos(angle) * 0.16, sin(angle) * 0.16, -0.5)
		barrel_cluster.add_child(barrel)

	var muzzle_collar := _torus(0.2, 0.035, mat_hot)
	muzzle_collar.position = Vector3(0, 0, -1.28)
	parent.add_child(muzzle_collar)


func _build_belt(parent: Node3D) -> void:
	belt_curve = Curve3D.new()
	for point in [
		Vector3(0.24, 1.64, 0.28),
		Vector3(0.58, 1.82, 0.08),
		Vector3(0.64, 1.72, -0.28),
		Vector3(0.44, 1.54, -0.56),
		Vector3(0.18, 1.42, -0.7)
	]:
		belt_curve.add_point(point)

	for i in range(28):
		var round := _cylinder(0.036, 0.13, mat_brass)
		var link := _box(Vector3(0.095, 0.06, 0.026), mat_weapon)
		parent.add_child(round)
		parent.add_child(link)
		var seg := {"round": round, "link": link, "t": float(i) / 28.0}
		belt_segments.append(seg)
		_place_belt_segment(seg, seg.t)


func _build_pools() -> void:
	var zombie_scene := load(ZOMBIE_MODEL) as PackedScene
	for i in range(MAX_ZOMBIES):
		var root := Node3D.new()
		root.visible = false
		var instance: Node3D = null
		var anim_player: AnimationPlayer = null
		if zombie_scene:
			instance = zombie_scene.instantiate() as Node3D
			instance.rotation.y = ZOMBIE_ROT_OFFSET
			root.add_child(instance)
			_normalize_height(instance, ZOMBIE_TARGET_HEIGHT)
			_hide_imported_helper_nodes(instance)
			if ZOMBIE_MODEL.ends_with("ual_character.glb"):
				_apply_zombie_tint(instance, i)
			anim_player = _find_anim_player(instance)
			if anim_player and ZOMBIE_MODEL.begins_with(ZOMBIE_PACK_DIR):
				_import_zombie_animations(anim_player)
			if anim_player and i == 0:
				print("[zombie anims] ", anim_player.get_animation_list())
		else:
			var quad := QuadMesh.new()
			quad.size = Vector2(2.4, 3.8)
			var sprite := MeshInstance3D.new()
			sprite.mesh = quad
			sprite.material_override = mat_zombie
			sprite.position.y = 1.9
			root.add_child(sprite)
			instance = sprite
		var shadow := _sphere(Vector3(0.85, 0.03, 0.52), _transparent_mat(Color(0, 0, 0, 0.45)))
		shadow.position.y = 0.03
		root.add_child(shadow)
		add_child(root)
		var mesh_list: Array = []
		var original_overrides: Array = []
		for mi in instance.find_children("*", "MeshInstance3D", true, false):
			mesh_list.append(mi)
			original_overrides.append(mi.material_override)
		zombies.append({
			"root": root,
			"instance": instance,
			"anim": anim_player,
			"mesh_instances": mesh_list,
			"original_overrides": original_overrides,
			"hit_flash_timer": 0.0,
			"flashing": false,
			"burning": false,
			"burn_timer": 0.0,
			"burn_tick": 0.0,
			"health": 3.0,
			"speed": 1.8,
			"radius": 0.55,
			"base_y": instance.position.y,
			"phase": randf_range(0, TAU),
			"stagger": Vector3.ZERO,
			"age": 0.0,
			"dying": false,
			"death_timer": 0.0,
			"death_animating": false,
			"animated_zombie": ZOMBIE_MODEL.begins_with(ZOMBIE_PACK_DIR)
		})

	for i in range(MAX_TRACERS):
		var tracer := _box(Vector3(0.045, 0.045, 10.5), mat_tracer.duplicate())
		tracer.visible = false
		add_child(tracer)
		tracers.append({"node": tracer, "life": 0.0, "dir": Vector3.FORWARD})

	for i in range(MAX_CASINGS):
		var casing := _cylinder(0.045, 0.22, mat_brass)
		casing.visible = false
		add_child(casing)
		casings.append({"node": casing, "life": 0.0, "vel": Vector3.ZERO, "ang": Vector3.ZERO, "settled": false})

	for i in range(MAX_BLOOD_DECALS):
		var plane := MeshInstance3D.new()
		var mesh := PlaneMesh.new()
		mesh.size = Vector2(1, 1)
		plane.mesh = mesh
		plane.material_override = mat_blood.duplicate()
		plane.visible = false
		plane.position.y = 0.025 + i * 0.00003
		add_child(plane)
		blood_decals.append({"node": plane, "life": 0.0})

	for i in range(MAX_BLOOD_DROPS):
		var drop := _sphere(Vector3(0.08, 0.08, 0.08), mat_blood_dark.duplicate())
		drop.visible = false
		add_child(drop)
		blood_drops.append({"node": drop, "life": 0.0, "vel": Vector3.ZERO})

	for i in range(MAX_IMPACTS):
		var impact := _sphere(Vector3(0.22, 0.22, 0.22), mat_impact.duplicate())
		impact.visible = false
		add_child(impact)
		impacts.append({"node": impact, "life": 0.0, "max_life": 0.1, "vel": Vector3.ZERO})

	for i in range(MAX_FOOTPRINTS):
		var fp := MeshInstance3D.new()
		var fp_mesh := PlaneMesh.new()
		fp_mesh.size = Vector2(0.32, 0.55)
		fp.mesh = fp_mesh
		var fp_mat := StandardMaterial3D.new()
		fp_mat.albedo_color = Color(0.45, 0.02, 0.02, 0.0)
		fp_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		fp_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
		fp_mat.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
		fp.material_override = fp_mat
		fp.visible = false
		fp.position.y = 0.022 + i * 0.0001
		add_child(fp)
		footprints.append({"node": fp, "life": 0.0})

	for i in range(MAX_GRENADES):
		var gren := _sphere(Vector3(0.18, 0.18, 0.18), _mat(Color(0.07, 0.08, 0.06), 0.5, 0.7))
		gren.visible = false
		add_child(gren)
		grenades.append({"node": gren, "vel": Vector3.ZERO, "life": 0.0, "target": Vector3.ZERO, "active": false})

	for i in range(MAX_FIRE_PATCHES):
		var fire_root := Node3D.new()
		fire_root.visible = false
		add_child(fire_root)
		var fire_plane := MeshInstance3D.new()
		var fire_mesh := PlaneMesh.new()
		fire_mesh.size = Vector2(1.0, 1.0)
		fire_plane.mesh = fire_mesh
		fire_plane.material_override = mat_fire.duplicate()
		fire_plane.position.y = 0.055 + i * 0.00012
		fire_root.add_child(fire_plane)
		var fire_light := OmniLight3D.new()
		fire_light.light_color = Color(1.0, 0.38, 0.05)
		fire_light.light_energy = 0.0
		fire_light.omni_range = 8.0
		fire_light.omni_attenuation = 1.8
		fire_light.position.y = 0.7
		fire_root.add_child(fire_light)
		fire_patches.append({
			"root": fire_root,
			"plane": fire_plane,
			"light": fire_light,
			"life": 0.0,
			"max_life": 0.0,
			"radius": 0.0,
			"phase": randf_range(0.0, TAU)
		})

	# Grenade explosion flash spheres
	var flash_mat := StandardMaterial3D.new()
	flash_mat.albedo_color = Color(1.0, 0.62, 0.12, 0.92)
	flash_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	flash_mat.emission_enabled = true
	flash_mat.emission = Color(1.0, 0.45, 0.08)
	flash_mat.emission_energy_multiplier = 6.0
	flash_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	flash_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	for i in range(6):
		var flash_sphere := _sphere(Vector3.ONE, flash_mat.duplicate())
		flash_sphere.visible = false
		add_child(flash_sphere)
		var flash_light := OmniLight3D.new()
		flash_light.light_color = Color(1.0, 0.5, 0.08)
		flash_light.light_energy = 0.0
		flash_light.omni_range = 18.0
		flash_light.omni_attenuation = 1.5
		flash_sphere.add_child(flash_light)
		grenade_flash_nodes.append({"node": flash_sphere, "light": flash_light, "life": 0.0, "max_life": 0.35})


func _build_audio() -> void:
	spin_up_player = _audio_player(SPIN_UP_AUDIO, 0.0, false)
	sustained_player = _audio_player(SUSTAINED_AUDIO, -80.0, true)
	casing_loop_player = _audio_player(CASING_AUDIO, -80.0, true)
	music_player = _audio_player(MUSIC_AUDIO, -13.5, true)
	if music_player.stream:
		music_player.play()
	for i in range(6):
		impact_players.append(_audio_player(ZOMBIE_IMPACT_AUDIO, -9.0, false))
	for i in range(5):
		death_players.append(_audio_player(ZOMBIE_DEATH_AUDIO, -5.0, false))


func _build_hud() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)

	kills_frame = _add_hud_image(layer, Vector2(20, 68), Vector2(348, 224), UI_KILLS_REGION, Color(1.0, 0.86, 0.58, 0.86))
	_add_hud_scrim(layer, Vector2(34, 88), Vector2(318, 182), Color(0.0, 0.0, 0.0, 0.72))

	var box := HBoxContainer.new()
	box.position = Vector2(24, 832)
	box.add_theme_constant_override("separation", 10)
	layer.add_child(box)

	_add_hud_label(box, "WASD\nMove")
	_add_hud_label(box, "Mouse\nAim")
	_add_hud_label(box, "Hold\nFire")
	_add_hud_label(box, "RClick\nGrenade")
	_add_hud_label(box, "Wheel\nZoom")

	var stats_box := HBoxContainer.new()
	stats_box.position = Vector2(40, 300)
	stats_box.add_theme_constant_override("separation", 6)
	layer.add_child(stats_box)
	wave_label = _add_hud_label(stats_box, "Wave\n1")
	kills_label = _add_hud_label(stats_box, "Kills\n0")
	zoom_label = _add_hud_label(stats_box, "Camera\n17m")
	spin_label = _add_hud_label(stats_box, "Spin\n0%")
	zombie_label = _add_hud_label(stats_box, "Zombies\n0")

	_build_weapon_selector(layer)

	extraction_frame = _add_hud_image(layer, Vector2(560, 58), Vector2(520, 138), UI_EXTRACT_REGION, Color(0.72, 1.0, 0.46, 0.88))
	_add_hud_scrim(layer, Vector2(606, 90), Vector2(428, 72), Color(0.0, 0.04, 0.0, 0.68))

	extraction_label = Label.new()
	extraction_label.text = ""
	extraction_label.add_theme_color_override("font_color", Color(0.67, 1.0, 0.52))
	extraction_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	extraction_label.add_theme_constant_override("outline_size", 7)
	extraction_label.add_theme_font_size_override("font_size", 25)
	extraction_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	extraction_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	extraction_label.position = Vector2(592, 84)
	extraction_label.size = Vector2(456, 86)
	layer.add_child(extraction_label)

	kills_giant_label = Label.new()
	kills_giant_label.text = "0"
	kills_giant_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55))
	kills_giant_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	kills_giant_label.add_theme_constant_override("outline_size", 12)
	kills_giant_label.add_theme_font_size_override("font_size", 112)
	kills_giant_label.position = Vector2(44, 88)
	kills_giant_label.size = Vector2(280, 116)
	layer.add_child(kills_giant_label)

	var kills_caption := Label.new()
	kills_caption.text = "KILLS"
	kills_caption.add_theme_color_override("font_color", Color(0.85, 0.85, 0.85))
	kills_caption.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	kills_caption.add_theme_constant_override("outline_size", 6)
	kills_caption.add_theme_font_size_override("font_size", 28)
	kills_caption.position = Vector2(48, 202)
	layer.add_child(kills_caption)

	multikill_label = Label.new()
	multikill_label.text = ""
	multikill_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.1))
	multikill_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	multikill_label.add_theme_constant_override("outline_size", 12)
	multikill_label.add_theme_font_size_override("font_size", 76)
	multikill_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	multikill_label.position = Vector2(440, 200)
	multikill_label.size = Vector2(720, 120)
	multikill_label.modulate.a = 0.0
	layer.add_child(multikill_label)

	leaderboard_frame = _add_hud_image(layer, Vector2(1294, 72), Vector2(286, 224), UI_LEADERBOARD_REGION, Color(1.0, 0.82, 0.42, 0.88))
	_add_hud_scrim(layer, Vector2(1308, 84), Vector2(258, 198), Color(0.0, 0.0, 0.0, 0.72))

	leaderboard_label = Label.new()
	leaderboard_label.text = ""
	leaderboard_label.add_theme_color_override("font_color", Color(0.95, 0.88, 0.62))
	leaderboard_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	leaderboard_label.add_theme_constant_override("outline_size", 5)
	leaderboard_label.add_theme_font_size_override("font_size", 18)
	leaderboard_label.position = Vector2(1322, 92)
	leaderboard_label.size = Vector2(234, 178)
	layer.add_child(leaderboard_label)

	# Health bar
	health_bar_bg = ColorRect.new()
	health_bar_bg.color = Color(0.12, 0.05, 0.05, 0.82)
	health_bar_bg.position = Vector2(44, 244)
	health_bar_bg.size = Vector2(UI_HP_BAR_WIDTH + 4.0, 22)
	layer.add_child(health_bar_bg)

	health_bar_fill = ColorRect.new()
	health_bar_fill.color = Color(0.85, 0.12, 0.08)
	health_bar_fill.position = Vector2(46, 246)
	health_bar_fill.size = Vector2(UI_HP_BAR_WIDTH, 18)
	layer.add_child(health_bar_fill)

	health_bar_label = Label.new()
	health_bar_label.text = "HP"
	health_bar_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.85))
	health_bar_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	health_bar_label.add_theme_constant_override("outline_size", 4)
	health_bar_label.add_theme_font_size_override("font_size", 16)
	health_bar_label.position = Vector2(48, 242)
	layer.add_child(health_bar_label)

	# Damage vignette (full-screen red flash when taking damage)
	damage_vignette = ColorRect.new()
	damage_vignette.color = Color(0.65, 0.02, 0.0, 0.0)
	damage_vignette.position = Vector2.ZERO
	damage_vignette.size = Vector2(1920, 1080)
	damage_vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(damage_vignette)

	# Death overlay
	death_overlay = ColorRect.new()
	death_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	death_overlay.position = Vector2.ZERO
	death_overlay.size = Vector2(1920, 1080)
	death_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	death_overlay.visible = false
	layer.add_child(death_overlay)

	death_label = Label.new()
	death_label.text = "YOU DIED"
	death_label.add_theme_color_override("font_color", Color(0.72, 0.08, 0.04))
	death_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	death_label.add_theme_constant_override("outline_size", 8)
	death_label.add_theme_font_size_override("font_size", 140)
	death_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_label.position = Vector2(0, 300)
	death_label.size = Vector2(1920, 200)
	death_label.modulate.a = 0.0
	death_label.visible = false
	layer.add_child(death_label)

	death_sublabel = Label.new()
	death_sublabel.text = "Press R to Rise Again"
	death_sublabel.add_theme_color_override("font_color", Color(0.65, 0.55, 0.45))
	death_sublabel.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	death_sublabel.add_theme_constant_override("outline_size", 5)
	death_sublabel.add_theme_font_size_override("font_size", 32)
	death_sublabel.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	death_sublabel.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	death_sublabel.position = Vector2(0, 520)
	death_sublabel.size = Vector2(1920, 60)
	death_sublabel.modulate.a = 0.0
	death_sublabel.visible = false
	layer.add_child(death_sublabel)

	initials_label = Label.new()
	initials_label.text = ""
	initials_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.58))
	initials_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	initials_label.add_theme_constant_override("outline_size", 6)
	initials_label.add_theme_font_size_override("font_size", 34)
	initials_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	initials_label.position = Vector2(0, 590)
	initials_label.size = Vector2(1920, 90)
	initials_label.modulate.a = 0.0
	initials_label.visible = false
	layer.add_child(initials_label)

	pause_overlay = ColorRect.new()
	pause_overlay.color = Color(0.0, 0.0, 0.0, 0.52)
	pause_overlay.position = Vector2.ZERO
	pause_overlay.size = Vector2(1920, 1080)
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pause_overlay.visible = false
	layer.add_child(pause_overlay)

	pause_label = Label.new()
	pause_label.text = "PAUSED\nSPACE TO RESUME"
	pause_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.62))
	pause_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	pause_label.add_theme_constant_override("outline_size", 8)
	pause_label.add_theme_font_size_override("font_size", 64)
	pause_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	pause_label.position = Vector2(0, 360)
	pause_label.size = Vector2(1920, 220)
	pause_label.visible = false
	layer.add_child(pause_label)

	_refresh_leaderboard_label()


func _add_hud_image(layer: CanvasLayer, pos: Vector2, image_size: Vector2, region: Rect2, tint: Color = Color.WHITE) -> TextureRect:
	var rect := TextureRect.new()
	rect.position = pos
	rect.size = image_size
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_SCALE
	rect.texture = _atlas_texture(region)
	rect.modulate = tint
	layer.add_child(rect)
	return rect


func _add_hud_scrim(layer: CanvasLayer, pos: Vector2, scrim_size: Vector2, color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.position = pos
	rect.size = scrim_size
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(rect)
	return rect


func _add_hud_panel(layer: CanvasLayer, pos: Vector2, panel_size: Vector2, bg: Color, border: Color) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.position = pos
	panel.size = panel_size
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _hud_panel_style(bg, border, 2, 6))
	layer.add_child(panel)
	return panel


func _hud_panel_style(bg: Color, border: Color, border_width: int = 2, radius: int = 6) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.42)
	style.shadow_size = 8
	return style


func _build_weapon_selector(layer: CanvasLayer) -> void:
	weapon_cards.clear()
	weapon_selector = HBoxContainer.new()
	weapon_selector.position = Vector2(440, 748)
	weapon_selector.add_theme_constant_override("separation", 8)
	weapon_selector.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(weapon_selector)

	weapon_cards.append(_make_weapon_card(weapon_selector, 1, "MINIGUN", MINIGUN_START_AMMO, UI_MINIGUN_ICON, Rect2()))
	weapon_cards.append(_make_weapon_card(weapon_selector, 2, "SHOTGUN", SHOTGUN_START_AMMO, "", UI_SHOTGUN_REGION))
	weapon_cards.append(_make_weapon_card(weapon_selector, 3, "AK", AK_START_AMMO, "", UI_AK_REGION))
	weapon_cards.append(_make_weapon_card(weapon_selector, 4, "KATANA", 0, "", UI_KATANA_REGION))


func _make_weapon_card(parent: Control, slot: int, title: String, max_ammo: int, texture_path: String, atlas_region: Rect2) -> Dictionary:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(176, 104)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", _hud_panel_style(Color(0.024, 0.024, 0.022, 0.76), Color(0.52, 0.48, 0.42, 0.58), 2, 5))
	parent.add_child(panel)

	var root := Control.new()
	root.custom_minimum_size = Vector2(176, 104)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(root)

	var key := Label.new()
	key.text = "%d" % slot
	key.position = Vector2(10, 5)
	key.size = Vector2(28, 28)
	key.add_theme_color_override("font_color", Color(1.0, 0.84, 0.48))
	key.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	key.add_theme_constant_override("outline_size", 4)
	key.add_theme_font_size_override("font_size", 24)
	root.add_child(key)

	var icon := TextureRect.new()
	icon.position = Vector2(12, 30)
	icon.size = Vector2(74, 54)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if texture_path != "":
		icon.texture = load(texture_path) as Texture2D
	else:
		icon.texture = _atlas_texture(atlas_region)
	root.add_child(icon)

	var name_label := Label.new()
	name_label.text = title
	name_label.position = Vector2(92, 10)
	name_label.size = Vector2(76, 24)
	name_label.add_theme_color_override("font_color", Color(0.94, 0.88, 0.72))
	name_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	name_label.add_theme_constant_override("outline_size", 3)
	name_label.add_theme_font_size_override("font_size", 14)
	root.add_child(name_label)

	var ammo_label := Label.new()
	ammo_label.text = ""
	ammo_label.position = Vector2(92, 34)
	ammo_label.size = Vector2(78, 22)
	ammo_label.add_theme_color_override("font_color", Color(1.0, 0.68, 0.12))
	ammo_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	ammo_label.add_theme_constant_override("outline_size", 3)
	ammo_label.add_theme_font_size_override("font_size", 18)
	root.add_child(ammo_label)

	var status_label := Label.new()
	status_label.text = ""
	status_label.position = Vector2(92, 58)
	status_label.size = Vector2(78, 18)
	status_label.add_theme_color_override("font_color", Color(0.72, 0.78, 0.78))
	status_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0))
	status_label.add_theme_constant_override("outline_size", 2)
	status_label.add_theme_font_size_override("font_size", 11)
	root.add_child(status_label)

	var bar_back := ColorRect.new()
	bar_back.position = Vector2(12, 88)
	bar_back.size = Vector2(152, 8)
	bar_back.color = Color(0.12, 0.11, 0.095, 0.92)
	root.add_child(bar_back)

	var bar_fill := ColorRect.new()
	bar_fill.position = Vector2(12, 88)
	bar_fill.size = Vector2(152, 8)
	bar_fill.color = Color(1.0, 0.62, 0.08, 0.95)
	root.add_child(bar_fill)

	return {
		"slot": slot,
		"max_ammo": max_ammo,
		"panel": panel,
		"icon": icon,
		"key": key,
		"name": name_label,
		"ammo": ammo_label,
		"status": status_label,
		"bar": bar_fill
	}


func _atlas_texture(region: Rect2) -> AtlasTexture:
	var tex := AtlasTexture.new()
	tex.atlas = load(UI_WEAPON_SHEET) as Texture2D
	tex.region = region
	return tex


func _update_weapon_cards() -> void:
	for card in weapon_cards:
		var slot := int(card["slot"])
		var ammo := 0
		var max_ammo := int(card["max_ammo"])
		var status := ""
		match slot:
			1:
				ammo = minigun_ammo
				status = "SPIN %d%%" % int(round(spin * 100))
			2:
				ammo = shotgun_ammo
				status = "READY" if shotgun_cooldown_remaining <= 0.0 else "%.1fs" % shotgun_cooldown_remaining
			3:
				ammo = ak_ammo
				status = "AUTO"
			4:
				ammo = 0
				status = "READY" if katana_cooldown_remaining <= 0.0 else "%.1fs" % katana_cooldown_remaining
		_update_weapon_card(card, slot == active_weapon, ammo, max_ammo, status)


func _update_weapon_card(card: Dictionary, active: bool, ammo: int, max_ammo: int, status: String) -> void:
	var panel := card["panel"] as PanelContainer
	var ammo_label := card["ammo"] as Label
	var status_label := card["status"] as Label
	var key_label := card["key"] as Label
	var name_label := card["name"] as Label
	var bar_fill := card["bar"] as ColorRect
	var icon := card["icon"] as TextureRect

	var empty := max_ammo > 0 and ammo <= 0
	var border := Color(1.0, 0.62, 0.08, 0.96) if active else Color(0.52, 0.48, 0.42, 0.58)
	var bg := Color(0.08, 0.062, 0.025, 0.88) if active else Color(0.024, 0.024, 0.022, 0.76)
	if empty:
		border = Color(0.86, 0.1, 0.06, 0.88)
	panel.add_theme_stylebox_override("panel", _hud_panel_style(bg, border, 3 if active else 2, 5))

	if max_ammo > 0:
		ammo_label.text = "%d/%d" % [ammo, max_ammo]
		var ratio: float = clampf(float(ammo) / float(max_ammo), 0.0, 1.0)
		bar_fill.size.x = 152.0 * ratio
		if empty:
			bar_fill.color = Color(0.82, 0.08, 0.04, 0.95)
		elif ratio < 0.25:
			bar_fill.color = Color(1.0, 0.24, 0.08, 0.95)
		else:
			bar_fill.color = Color(1.0, 0.62, 0.08, 0.95)
	else:
		ammo_label.text = "--"
		bar_fill.size.x = 152.0
		bar_fill.color = Color(0.95, 0.72, 0.18, 0.75)

	status_label.text = status
	status_label.add_theme_color_override("font_color", Color(1.0, 0.78, 0.24) if active else Color(0.72, 0.78, 0.78))
	key_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.52) if active else Color(0.8, 0.72, 0.55))
	name_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.72) if active else Color(0.82, 0.78, 0.68))
	icon.modulate = Color(1.18, 1.1, 0.92, 1.0) if active else Color(0.78, 0.78, 0.74, 0.9)


func _start_firing() -> void:
	if active_weapon != 1:
		return
	if minigun_ammo <= 0:
		return
	if not firing:
		spin_up_player.stop()
		spin_up_player.play()
	firing = true


func _start_ak_fire() -> void:
	if active_weapon != 3 or ak_ammo <= 0:
		return
	firing = true


func _set_active_weapon(index: int) -> void:
	active_weapon = clampi(index, 1, 4)
	firing = false
	_refresh_weapon_visuals()
	if sustained_player:
		sustained_player.stop()
	if casing_loop_player:
		casing_loop_player.stop()


func _refresh_weapon_visuals() -> void:
	var shotgun_active := active_weapon == 2
	var ak_active := active_weapon == 3
	var katana_active := active_weapon == 4
	var minigun_active := active_weapon == 1
	if imported_weapon_model:
		imported_weapon_model.visible = minigun_active
	if shotgun_model:
		shotgun_model.visible = shotgun_active
	if ak_model:
		ak_model.visible = ak_active
	if katana_model:
		katana_model.visible = katana_active
	if ammo_pack:
		ammo_pack.visible = minigun_active
	for seg in belt_segments:
		if seg.has("round"):
			(seg["round"] as Node3D).visible = minigun_active
		if seg.has("link"):
			(seg["link"] as Node3D).visible = minigun_active

	if muzzle_marker:
		if shotgun_active:
			muzzle_marker.position = Vector3(0.0, 0.08, -1.54)
		elif ak_active:
			muzzle_marker.position = Vector3(0.0, 0.04, -1.22)
		elif katana_active:
			muzzle_marker.position = Vector3(0.0, 0.0, -1.82)
		else:
			muzzle_marker.position = Vector3(0.0, 0.0, -1.58)
	if muzzle_flash:
		muzzle_flash.position = muzzle_marker.position if muzzle_marker else Vector3(0.0, 0.0, -1.58)
	if muzzle_light:
		muzzle_light.position = muzzle_marker.position if muzzle_marker else Vector3(0.0, 0.0, -1.58)
	if casing_marker:
		if shotgun_active:
			casing_marker.position = Vector3(0.22, -0.03, -0.14)
		elif ak_active:
			casing_marker.position = Vector3(0.17, 0.03, -0.34)
		else:
			casing_marker.position = Vector3(0.28, -0.08, -0.55)


func _toggle_pause() -> void:
	game_paused = not game_paused
	firing = false
	if pause_overlay:
		pause_overlay.visible = game_paused
	if pause_label:
		pause_label.visible = game_paused
	if sustained_player and game_paused:
		sustained_player.stop()
	if casing_loop_player and game_paused:
		casing_loop_player.stop()


func _update_pointer_world() -> void:
	pointer_world = _screen_to_ground(get_viewport().get_mouse_position())


func _screen_to_ground(screen_pos: Vector2) -> Vector3:
	var origin := camera.project_ray_origin(screen_pos)
	var normal := camera.project_ray_normal(screen_pos)
	if abs(normal.y) > 0.0001:
		var t := -origin.y / normal.y
		return origin + normal * t
	return pointer_world


func _update_player(delta: float) -> void:
	var input := Vector3.ZERO
	if Input.is_key_pressed(KEY_W):
		input.z -= 1
	if Input.is_key_pressed(KEY_S):
		input.z += 1
	if Input.is_key_pressed(KEY_A):
		input.x -= 1
	if Input.is_key_pressed(KEY_D):
		input.x += 1
	if input.length_squared() > 0:
		input = input.normalized()

	var speed := 7.2 * (0.72 if firing else 1.0)
	if active_weapon == 2:
		speed *= 0.92
	elif active_weapon == 3:
		speed *= 0.95
	elif active_weapon == 4:
		speed *= 1.08
	velocity = velocity.lerp(input * speed, 1.0 - pow(0.001, delta))
	player.position += velocity * delta
	player.position.x = clamp(player.position.x, -ARENA_HALF + 8.0, ARENA_HALF - 8.0)
	player.position.z = clamp(player.position.z, -ARENA_HALF + 8.0, ARENA_HALF - 8.0)

	var aim := pointer_world - player.position
	aim.y = 0
	if aim.length_squared() > 0.04:
		player.look_at(player.position + aim, Vector3.UP)

	var speed01: float = clampf(velocity.length() / 7.2, 0.0, 1.0)
	step_time += delta * speed01 * 9.0
	body.position.y = abs(sin(step_time)) * 0.055 * speed01
	body.rotation.z = sin(step_time * 0.5) * 0.035 * speed01
	recoil_kick = lerpf(recoil_kick, 0.0, 1.0 - pow(0.0006, delta))
	body.rotation.x = -recoil_kick * 0.55
	body.position.z = lerpf(body.position.z, recoil_kick * 0.18, 1.0 - pow(0.0008, delta))

	_update_footprints(delta)

	if operator_anim:
		var moving: bool = velocity.length() > 0.6
		var target_clip: String = _choose_operator_clip(input, moving)
		if target_clip != "" and operator_state != target_clip:
			var clip: Animation = operator_anim.get_animation(target_clip)
			if clip:
				clip.loop_mode = Animation.LOOP_LINEAR
			operator_anim.play(target_clip, 0.25)
			operator_state = target_clip
		operator_anim.speed_scale = clampf(velocity.length() / 5.5, 0.85, 1.35) if moving else 1.0
		operator_anim.advance(delta)


func _update_waves(delta: float) -> void:
	elapsed += delta
	wave = 1 + int(elapsed / 12.0)
	var extraction_pressure := extraction_unlocked and not extraction_complete
	var active := _active_zombie_count()
	if active >= MAX_ZOMBIES:
		return

	spawn_timer -= delta
	burst_timer -= delta
	if spawn_timer <= 0:
		var trickle := 1 + int(wave / 5)
		if extraction_pressure:
			trickle += 2 + int(wave / 4)
		trickle = mini(trickle, MAX_ZOMBIES - active)
		for i in range(trickle):
			_spawn_zombie(1.0 + wave * 0.24)
		var next_spawn: float = clampf(0.42 - wave * 0.032, 0.045, 0.42)
		if extraction_pressure:
			next_spawn = clampf(next_spawn * 0.55, 0.032, 0.26)
		spawn_timer = next_spawn
	if burst_timer <= 0:
		active = _active_zombie_count()
		var burst_size := 16 + wave * 5
		if extraction_pressure:
			burst_size = 24 + wave * 8
		var burst := mini(burst_size, MAX_ZOMBIES - active)
		for i in range(burst):
			_spawn_zombie(1.4 + wave * 0.26)
		if extraction_pressure:
			burst_timer = clamp(4.0 - wave * 0.18, 1.05, 4.0)
		else:
			burst_timer = clamp(6.2 - wave * 0.26, 1.7, 6.2)


func _spawn_zombie(difficulty: float, force_big: bool = false) -> Dictionary:
	for z in zombies:
		if not z.root.visible:
			var angle := randf_range(0, TAU)
			var distance := camera_distance + randf_range(12, 28)
			var big: bool = force_big or (wave >= BIG_ZOMBIE_WAVE_THRESHOLD and randf() < minf(0.018 + wave * 0.004, 0.08))
			var heavy: bool = not big and randf() < minf(0.1 + wave * 0.015, 0.3)
			var runner: bool = not big and not heavy and randf() < minf(0.12 + wave * 0.012, 0.28)
			var scale: float
			if big:
				scale = randf_range(2.4, 3.1)
			elif heavy:
				scale = randf_range(1.15, 1.35)
			elif runner:
				scale = randf_range(0.82, 0.94)
			else:
				scale = randf_range(0.9, 1.1)
			z.root.visible = true
			z.root.position = player.position + Vector3(sin(angle) * distance, 0, cos(angle) * distance)
			z.root.scale = Vector3.ONE * scale
			var instance: Node3D = z["instance"]
			if instance:
				instance.position.y = float(z["base_y"])
				instance.rotation.x = 0
				instance.rotation.z = 0
			if big:
				z.health = 135.0 + wave * 8.5
				z.speed = randf_range(0.9, 1.25) + difficulty * 0.04
			elif heavy:
				z.health = 13.0 + wave * 0.85
				z.speed = randf_range(1.0, 1.35) + difficulty * 0.06
			elif runner:
				z.health = 4.2 + wave * 0.12
				z.speed = randf_range(2.8, 3.35) + difficulty * 0.06
			else:
				z.health = 6.0 + wave * 0.35
				z.speed = randf_range(1.55, 2.05) + difficulty * 0.06
			z.radius = 0.58 * scale
			z.big = big
			z.stagger = Vector3.ZERO
			z.age = randf_range(0, TAU)
			z.dying = false
			z.death_timer = 0.0
			z.death_animating = false
			z.flashing = false
			z.hit_flash_timer = 0.0
			z.burning = false
			z.burn_timer = 0.0
			z.burn_tick = 0.0
			_restore_zombie_materials(z)
			z.attacking = false
			z.current_motion = ""
			_play_zombie_motion(z, runner, heavy)
			z.runner = runner
			z.heavy = heavy
			return z
	return {}


func _update_extraction(delta: float) -> void:
	if extraction_complete or player_dead:
		return
	if not extraction_unlocked:
		if wave >= EXTRACTION_UNLOCK_WAVE or kills >= EXTRACTION_UNLOCK_KILLS:
			_unlock_extraction()
		return

	var flat_player := Vector2(player.global_position.x, player.global_position.z)
	var flat_extract := Vector2(extraction_position.x, extraction_position.z)
	var dist := flat_player.distance_to(flat_extract)
	var in_zone := dist <= EXTRACTION_RADIUS
	if in_zone:
		extraction_timer = minf(extraction_timer + delta, EXTRACTION_HOLD_TIME)
	else:
		extraction_timer = maxf(extraction_timer - delta * 0.5, 0.0)

	_animate_extraction_marker(delta, in_zone)
	if extraction_timer >= EXTRACTION_HOLD_TIME:
		_trigger_extraction_success()
		return

	extraction_big_timer -= delta
	if extraction_big_timer <= 0.0 and _active_zombie_count() < MAX_ZOMBIES - 3:
		_spawn_zombie(2.8 + wave * 0.34, true)
		extraction_big_timer = randf_range(7.5, 10.5)


func _unlock_extraction() -> void:
	extraction_unlocked = true
	extraction_timer = 0.0
	extraction_big_timer = 1.4
	extraction_position = _pick_extraction_position()
	if extraction_marker:
		extraction_marker.global_position = extraction_position
		extraction_marker.visible = true
	for i in range(2):
		_spawn_zombie(3.0 + wave * 0.35, true)
	spawn_timer = minf(spawn_timer, 0.04)
	burst_timer = minf(burst_timer, 0.25)


func _pick_extraction_position() -> Vector3:
	var angle := randf_range(0.0, TAU)
	var player_flat := Vector2(player.global_position.x, player.global_position.z)
	if player_flat.length_squared() > 16.0:
		angle = atan2(player_flat.y, player_flat.x) + PI + randf_range(-0.55, 0.55)
	var distance := ARENA_HALF * randf_range(0.58, 0.72)
	return Vector3(
		clampf(cos(angle) * distance, -ARENA_HALF + 18.0, ARENA_HALF - 18.0),
		0.0,
		clampf(sin(angle) * distance, -ARENA_HALF + 18.0, ARENA_HALF - 18.0)
	)


func _animate_extraction_marker(delta: float, in_zone: bool) -> void:
	if extraction_marker == null or not extraction_marker.visible:
		return
	var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.006)
	if extraction_ring:
		var ring_scale := 1.0 + pulse * (0.06 if in_zone else 0.025)
		extraction_ring.scale = Vector3(ring_scale, 1.0, ring_scale)
		var mat := extraction_ring.material_override as StandardMaterial3D
		if mat:
			mat.albedo_color.a = 0.42 if in_zone else 0.24
			mat.emission_energy_multiplier = 3.4 if in_zone else 1.8
	if extraction_core:
		extraction_core.rotation.y += delta * (2.6 if in_zone else 1.2)
		extraction_core.scale.y = 1.0 + pulse * 0.06
	if extraction_light:
		extraction_light.light_energy = (9.0 if in_zone else 5.0) + pulse * 2.2


func _trigger_extraction_success() -> void:
	if extraction_complete:
		return
	extraction_complete = true
	firing = false
	game_paused = false
	death_camera_timer = 0.0
	entering_initials = true
	score_submitted = false
	current_initials = ""
	final_score_override = kills + EXTRACTION_SCORE_BONUS + wave * 50 + int(ceil(player_health)) * 5
	if sustained_player:
		sustained_player.stop()
	if casing_loop_player:
		casing_loop_player.stop()
	if death_overlay:
		death_overlay.visible = true
		death_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	if death_label:
		death_label.text = "EXTRACTED"
		death_label.add_theme_color_override("font_color", Color(0.24, 1.0, 0.34))
		death_label.modulate.a = 0.0
		death_label.visible = true
	if death_sublabel:
		death_sublabel.text = "Final score %d" % final_score_override
		death_sublabel.modulate.a = 0.0
		death_sublabel.visible = true
	if initials_label:
		initials_label.visible = true
		initials_label.modulate.a = 0.0
	if extraction_label:
		extraction_label.text = "EXTRACTED\nSCORE BONUS +%d" % EXTRACTION_SCORE_BONUS
	_trigger_hit_stop(450, 0.22)


func _update_extraction_complete(delta: float) -> void:
	death_camera_timer += delta
	var focus_pos := player.global_position.lerp(extraction_position, 0.42) + Vector3.UP * 1.0
	var orbit_angle := death_camera_timer * 0.22
	var cam_offset := Vector3(sin(orbit_angle) * 10.0, 7.0, cos(orbit_angle) * 10.0)
	if camera:
		camera.global_position = camera.global_position.lerp(focus_pos + cam_offset, 1.0 - pow(0.008, delta))
		camera.look_at(focus_pos, Vector3.UP)
		camera.fov = lerpf(camera.fov, 42.0, 1.0 - pow(0.01, delta))

	if death_overlay:
		death_overlay.color = Color(0.0, 0.0, 0.0, clampf((death_camera_timer - 0.45) / 2.0, 0.0, 0.56))
	if death_label:
		death_label.modulate.a = clampf((death_camera_timer - 0.55) / 0.9, 0.0, 1.0)
	if death_sublabel:
		death_sublabel.modulate.a = clampf((death_camera_timer - 1.0) / 0.8, 0.0, 1.0)
		death_sublabel.text = "Final score %d" % max(final_score_override, kills)
	if initials_label:
		initials_label.modulate.a = clampf((death_camera_timer - 1.25) / 0.8, 0.0, 1.0)
		var padded := (current_initials + "___").substr(0, 3)
		initials_label.text = "ENTER INITIALS  %s\nEXTRACT BONUS SAVED ON ENTER" % padded if entering_initials else "SCORE SAVED\nPRESS R TO RUN IT BACK"


func _play_zombie_motion(z: Dictionary, runner: bool, heavy: bool) -> void:
	if not z.anim:
		return
	var anim_player: AnimationPlayer = z.anim
	var pool := [zombie_walk_clip, "Walk", "Walk_Formal", "Jog_Fwd"]
	if runner:
		pool = [zombie_run_clip, "Sprint", "Jog_Fwd", zombie_walk_clip, "Walk"]
	elif heavy:
		pool = [zombie_walk_clip, "Walk_Formal", "Walk", zombie_idle_clip]
	if ZOMBIE_MODEL.ends_with("cursed_undead_soldier_rig.glb"):
		pool = ["Slash"]
	var name := _first_existing_anim(anim_player, pool)
	if name == "" and ZOMBIE_MODEL.ends_with("ual_character.glb") and anim_player.get_animation_list().size() > 0:
		name = anim_player.get_animation_list()[0]
	if name == "":
		return
	var clip := anim_player.get_animation(name)
	if clip:
		clip.loop_mode = Animation.LOOP_LINEAR
	anim_player.play(name, 0.15)
	anim_player.speed_scale = clamp(float(z["speed"]) * (0.43 if runner else 0.52), 0.75, 1.55)
	z.current_motion = name


func _play_zombie_attack(z: Dictionary) -> void:
	if not z.anim:
		return
	var anim_player: AnimationPlayer = z.anim
	var name := _first_existing_anim(anim_player, [zombie_attack_clip, "zombie_biting", "Slash"])
	if name == "" or z.get("current_motion", "") == name:
		return
	var clip := anim_player.get_animation(name)
	if clip:
		clip.loop_mode = Animation.LOOP_LINEAR
	anim_player.play(name, 0.15)
	anim_player.speed_scale = 1.05
	z.current_motion = name


func _update_zombies(delta: float) -> void:
	for z in zombies:
		if not z.root.visible:
			continue
		if z.dying:
			z.death_timer -= delta
			var dying_instance: Node3D = z["instance"]
			if dying_instance and not bool(z.get("death_animating", false)):
				dying_instance.rotation.x = lerp_angle(dying_instance.rotation.x, -1.32, 1.0 - pow(0.003, delta))
				dying_instance.rotation.z = lerp_angle(dying_instance.rotation.z, sin(float(z["phase"])) * 0.55, 1.0 - pow(0.003, delta))
				dying_instance.position.y = lerpf(dying_instance.position.y, maxf(float(z["base_y"]) - 0.72, 0.05), 1.0 - pow(0.003, delta))
			if z.death_timer <= 0.0:
				z.root.visible = false
				z.dying = false
			continue
		var flash_t: float = float(z.get("hit_flash_timer", 0.0))
		if flash_t > 0.0:
			flash_t -= delta
			z.hit_flash_timer = flash_t
			if flash_t <= 0.0:
				_clear_zombie_flash(z)
		if bool(z.get("burning", false)):
			_update_zombie_burning(z, delta)
			if bool(z.get("dying", false)):
				continue
		z.age += delta
		var to_player: Vector3 = player.position - (z["root"] as Node3D).position
		to_player.y = 0
		var dist: float = maxf(to_player.length(), 0.001)
		var dir: Vector3 = to_player / dist
		var was_attacking: bool = bool(z.get("attacking", false))
		var should_attack: bool = was_attacking if (dist < ZOMBIE_ATTACK_RELEASE) else false
		if dist < ZOMBIE_ATTACK_RANGE:
			should_attack = true
		z.attacking = should_attack
		if should_attack:
			if not was_attacking:
				_play_zombie_attack(z)
			var dps: float = 28.0 if z.get("big", false) else (12.0 if z.get("heavy", false) else (7.0 if z.get("runner", false) else 5.5))
			_damage_player(dps * delta, z)
			z.root.position += z.stagger * delta
		else:
			if was_attacking:
				_play_zombie_motion(z, bool(z.get("runner", false)), bool(z.get("heavy", false)))
			z.root.position += dir * z.speed * delta
			z.root.position += z.stagger * delta
		z.stagger = z.stagger.lerp(Vector3.ZERO, 1.0 - pow(0.002, delta))
		if to_player.length_squared() > 0.0001:
			z.root.look_at(z.root.position + dir, Vector3.UP)
		var instance: Node3D = z["instance"]
		if instance and not bool(z.get("animated_zombie", false)):
			var stride: float = z.age * (4.2 + z.speed * 0.8) + float(z["phase"])
			instance.position.y = float(z["base_y"]) + abs(sin(stride)) * 0.045
			instance.rotation.x = sin(stride) * 0.08
			instance.rotation.z = sin(stride * 0.55) * 0.07
		if z.root.position.distance_squared_to(player.position) > 16000:
			z.root.visible = false
	_separate_zombies()


func _separate_zombies() -> void:
	for iteration in range(ZOMBIE_SEPARATION_ITERATIONS):
		for i in range(zombies.size()):
			var a: Dictionary = zombies[i]
			if not _is_live_zombie(a):
				continue
			var a_root: Node3D = a["root"]
			for j in range(i + 1, zombies.size()):
				var b: Dictionary = zombies[j]
				if not _is_live_zombie(b):
					continue
				var b_root: Node3D = b["root"]
				var delta_pos: Vector3 = a_root.position - b_root.position
				delta_pos.y = 0.0
				var desired: float = float(a["radius"]) + float(b["radius"]) + ZOMBIE_SEPARATION_PADDING
				var dist_sq := delta_pos.length_squared()
				if dist_sq >= desired * desired:
					continue

				var dir: Vector3 = delta_pos.normalized()
				var dist := sqrt(dist_sq)
				if dist < 0.001:
					var angle := float(i * 37 + j * 19 + iteration * 53)
					dir = Vector3(cos(angle), 0.0, sin(angle)).normalized()
					dist = 0.001

				var overlap := desired - dist
				if bool(a.get("big", false)) and not bool(b.get("big", false)):
					b_root.position -= dir * overlap
				elif bool(b.get("big", false)) and not bool(a.get("big", false)):
					a_root.position += dir * overlap
				else:
					var push := dir * (overlap * 0.5)
					a_root.position += push
					b_root.position -= push


func _is_live_zombie(z: Dictionary) -> bool:
	var root: Node3D = z["root"]
	return root.visible and not bool(z["dying"])


func _ignite_zombie(z: Dictionary, duration: float) -> void:
	if not _is_live_zombie(z):
		return
	z.burning = true
	z.burn_timer = maxf(float(z.get("burn_timer", 0.0)), duration * randf_range(0.85, 1.25))
	z.burn_tick = minf(float(z.get("burn_tick", BURN_TICK_RATE)), 0.04)
	if not bool(z.get("flashing", false)):
		_apply_zombie_burn_visual(z)


func _update_zombie_burning(z: Dictionary, delta: float) -> void:
	z.burn_timer = float(z.get("burn_timer", 0.0)) - delta
	z.burn_tick = float(z.get("burn_tick", 0.0)) - delta
	if float(z["burn_tick"]) <= 0.0:
		z.burn_tick = BURN_TICK_RATE
		var root: Node3D = z["root"]
		var away: Vector3 = root.global_position - player.global_position
		away.y = 0.0
		var dir: Vector3 = away.normalized() if away.length_squared() > 0.001 else Vector3.FORWARD
		z.health -= BURN_TICK_DAMAGE
		if not bool(z.get("big", false)):
			z.stagger += dir * 0.55
		if randf() < 0.45:
			_spawn_impact(root.global_position + Vector3(0, randf_range(0.75, 1.35), 0), Vector3.UP, false)
		if float(z["health"]) <= 0.0:
			_kill_zombie(z, dir)
			return
	if float(z["burn_timer"]) <= 0.0:
		z.burning = false
		if not bool(z.get("flashing", false)):
			_restore_zombie_materials(z)


func _update_weapon(delta: float) -> void:
	shotgun_cooldown_remaining = maxf(shotgun_cooldown_remaining - delta, 0.0)
	shotgun_flash_timer = maxf(shotgun_flash_timer - delta, 0.0)
	ak_flash_timer = maxf(ak_flash_timer - delta, 0.0)
	katana_cooldown_remaining = maxf(katana_cooldown_remaining - delta, 0.0)
	katana_swing_timer = maxf(katana_swing_timer - delta, 0.0)
	if weapon_root:
		weapon_root.global_position = player.global_transform * WEAPON_FOLLOW_OFFSET
	if weapon_root and pointer_world.distance_squared_to(weapon_root.global_position) > 0.1:
		var aim_target := pointer_world
		aim_target.y = weapon_root.global_position.y
		weapon_root.look_at(aim_target, Vector3.UP)

	if active_weapon == 1 and minigun_ammo <= 0:
		firing = false
	if active_weapon == 3 and ak_ammo <= 0:
		firing = false

	var target := 1.0 if firing and active_weapon == 1 and minigun_ammo > 0 else 0.0
	spin = _damp(spin, target, 3.6 if firing else 2.3, delta)
	if barrel_cluster:
		if barrel_spin_axis == "y":
			barrel_cluster.rotation.y += spin * 76.0 * delta
		elif barrel_spin_axis == "x":
			barrel_cluster.rotation.x += spin * 76.0 * delta
		else:
			barrel_cluster.rotation.z += spin * 76.0 * delta
	var ready := active_weapon == 1 and firing and spin > 0.68 and minigun_ammo > 0
	_update_belt(delta, ready)

	if katana_model:
		var slash_t := clampf(katana_swing_timer / 0.24, 0.0, 1.0)
		katana_model.rotation = KATANA_MODEL_ROTATION + Vector3(0.0, 0.0, sin(slash_t * PI) * -0.82)

	muzzle_flash.visible = ready or shotgun_flash_timer > 0.0 or ak_flash_timer > 0.0
	if ak_flash_timer > 0.0:
		muzzle_flash.scale = Vector3.ONE * randf_range(0.52, 0.9)
		(muzzle_flash.material_override as StandardMaterial3D).albedo_color.a = clampf(ak_flash_timer * 9.0, 0.0, 0.55)
		muzzle_light.light_energy = randf_range(7.0, 14.0) * clampf(ak_flash_timer * 10.0, 0.0, 1.0)
	elif shotgun_flash_timer > 0.0:
		muzzle_flash.scale = Vector3.ONE * randf_range(1.1, 1.65)
		(muzzle_flash.material_override as StandardMaterial3D).albedo_color.a = clampf(shotgun_flash_timer * 4.0, 0.0, 0.65)
		muzzle_light.light_energy = randf_range(13.0, 24.0) * clampf(shotgun_flash_timer * 5.0, 0.0, 1.0)
	elif ready:
		muzzle_flash.scale = Vector3.ONE * randf_range(0.72, 1.18)
		(muzzle_flash.material_override as StandardMaterial3D).albedo_color.a = randf_range(0.18, 0.38)
		muzzle_light.light_energy = randf_range(9.0, 18.0)
	else:
		muzzle_light.light_energy = 0

	if ready:
		shot_accumulator += delta * lerpf(14.0, 42.0, spin)
		var muzzle: Vector3 = muzzle_marker.global_position if muzzle_marker else (muzzle_flash.global_position if muzzle_flash else player.global_transform * Vector3(0, 1.55, -3.42))
		while shot_accumulator >= 1.0 and minigun_ammo > 0:
			_fire_shot(muzzle)
			_eject_casing()
			shot_accumulator -= 1.0
		if minigun_ammo <= 0:
			firing = false
	else:
		shot_accumulator = 0.0

	if active_weapon == 3 and firing and ak_ammo > 0:
		ak_shot_accumulator += delta * AK_FIRE_RATE
		var ak_muzzle: Vector3 = muzzle_marker.global_position if muzzle_marker else player.global_position + Vector3.UP * 1.3
		while ak_shot_accumulator >= 1.0 and ak_ammo > 0:
			_fire_ak_shot(ak_muzzle)
			ak_shot_accumulator -= 1.0
		if ak_ammo <= 0:
			firing = false
	else:
		ak_shot_accumulator = 0.0


func _update_belt(delta: float, feeding: bool) -> void:
	var rate := lerpf(0.82, 1.62, spin) if feeding else 0.0
	belt_travel = fmod(belt_travel + delta * rate, 1.0)
	for seg in belt_segments:
		_place_belt_segment(seg, fmod(seg.t + belt_travel, 1.0))


func _fire_shot(origin: Vector3) -> void:
	if minigun_ammo <= 0:
		return
	minigun_ammo -= 1
	var direction := _weapon_forward().rotated(Vector3.UP, randf_range(-0.045, 0.045))
	var hit := _apply_bullet_damage(origin, direction)
	_spawn_tracer(origin, direction)
	if not hit:
		_spawn_impact(origin + direction * randf_range(24, 46), direction, false)
	var spin_factor: float = clampf(spin, 0.0, 1.0)
	recoil_kick = minf(recoil_kick + 0.018 + spin_factor * 0.012, 0.22)
	shake_intensity = minf(shake_intensity + 0.015 + spin_factor * 0.018, 0.85)
	fov_pulse_amount = minf(fov_pulse_amount + 0.45, 3.5)


func _fire_ak_shot(origin: Vector3) -> void:
	if ak_ammo <= 0:
		return
	ak_ammo -= 1
	ak_flash_timer = 0.065
	var direction := _weapon_forward().rotated(Vector3.UP, randf_range(-0.035, 0.035))
	var hit := _apply_ak_damage(origin, direction)
	_spawn_tracer(origin, direction)
	if not hit:
		_spawn_impact(origin + direction * randf_range(24.0, AK_RANGE), direction, false)
	_eject_casing()
	recoil_kick = minf(recoil_kick + 0.035, 0.24)
	shake_intensity = minf(shake_intensity + 0.045, 0.9)
	fov_pulse_amount = minf(fov_pulse_amount + 0.35, 3.2)


func _fire_shotgun() -> void:
	if shotgun_cooldown_remaining > 0.0:
		return
	if shotgun_ammo <= 0:
		return
	shotgun_ammo -= 1
	shotgun_cooldown_remaining = SHOTGUN_COOLDOWN
	shotgun_flash_timer = 0.18
	var origin: Vector3 = muzzle_marker.global_position if muzzle_marker else player.global_position + Vector3.UP * 1.3
	var forward := _weapon_forward()
	var hit := _apply_shotgun_damage(origin, forward)
	for i in range(SHOTGUN_PELLETS):
		var spread := randf_range(-0.23, 0.23)
		var dir := forward.rotated(Vector3.UP, spread)
		_spawn_tracer(origin, dir)
		if not hit and i < 4:
			_spawn_impact(origin + dir * randf_range(10.0, SHOTGUN_RANGE), dir, false)
	for i in range(2):
		_eject_casing()
	recoil_kick = minf(recoil_kick + 0.18, 0.34)
	shake_intensity = minf(shake_intensity + 0.95, 1.45)
	fov_pulse_amount = minf(fov_pulse_amount + 2.1, 4.2)
	_trigger_hit_stop(55, 0.12)


func _swing_katana() -> void:
	if katana_cooldown_remaining > 0.0:
		return
	katana_cooldown_remaining = KATANA_COOLDOWN
	katana_swing_timer = 0.24
	var origin: Vector3 = player.global_position + Vector3.UP * 0.85
	var forward := _weapon_forward()
	var hit := _apply_katana_damage(origin, forward)
	recoil_kick = minf(recoil_kick + 0.08, 0.22)
	shake_intensity = minf(shake_intensity + (0.75 if hit else 0.22), 1.1)
	fov_pulse_amount = minf(fov_pulse_amount + (1.1 if hit else 0.45), 3.4)
	_trigger_hit_stop(45 if hit else 18, 0.13 if hit else 0.35)


func _apply_shotgun_damage(origin: Vector3, direction: Vector3) -> bool:
	var candidates := []
	var flat_origin := Vector3(origin.x, 0.0, origin.z)
	var flat_dir := Vector3(direction.x, 0.0, direction.z).normalized()
	for z in zombies:
		if not z.root.visible or z.dying:
			continue
		var to_z := Vector3(z.root.position.x - flat_origin.x, 0.0, z.root.position.z - flat_origin.z)
		var dist: float = to_z.length()
		if dist <= 0.001 or dist > SHOTGUN_RANGE:
			continue
		var z_dir := to_z / dist
		var dot: float = z_dir.dot(flat_dir)
		var radius_bonus: float = clampf(float(z["radius"]) * 0.08, 0.0, 0.12)
		if dot < SHOTGUN_CONE_DOT - radius_bonus:
			continue
		candidates.append({"z": z, "dist": dist, "dot": dot})
	candidates.sort_custom(func(a, b): return a.dist < b.dist)

	var hit := false
	for i in range(mini(candidates.size(), SHOTGUN_MAX_TARGETS)):
		var z: Dictionary = candidates[i]["z"]
		var dist: float = float(candidates[i]["dist"])
		var falloff: float = 1.0 - clampf(dist / SHOTGUN_RANGE, 0.0, 1.0) * 0.55
		var hit_point: Vector3 = z.root.position + Vector3(0, randf_range(0.75, 1.35), 0)
		_damage_zombie(z, SHOTGUN_DAMAGE * falloff, flat_dir, hit_point)
		if not bool(z.get("big", false)):
			z.stagger += flat_dir * (8.0 * falloff)
		_spawn_blood(hit_point, flat_dir, false)
		hit = true
	return hit


func _apply_katana_damage(origin: Vector3, direction: Vector3) -> bool:
	var flat_origin := Vector3(origin.x, 0.0, origin.z)
	var flat_dir := Vector3(direction.x, 0.0, direction.z).normalized()
	var hit := false
	for z in zombies:
		if not z.root.visible or z.dying:
			continue
		var to_z := Vector3(z.root.position.x - flat_origin.x, 0.0, z.root.position.z - flat_origin.z)
		var dist: float = to_z.length()
		if dist <= 0.001 or dist > KATANA_RANGE + float(z["radius"]):
			continue
		var z_dir := to_z / dist
		if z_dir.dot(flat_dir) < KATANA_CONE_DOT:
			continue
		var damage := KATANA_DAMAGE * (0.62 if bool(z.get("big", false)) else 1.0)
		var hit_point: Vector3 = z.root.position + Vector3(0, randf_range(0.65, 1.25), 0)
		_damage_zombie(z, damage, flat_dir, hit_point)
		if not bool(z.get("big", false)):
			z.stagger += flat_dir * 10.0
		_spawn_blood(hit_point, flat_dir, true)
		hit = true
	return hit


func _weapon_forward() -> Vector3:
	if weapon_root and muzzle_marker:
		var forward := muzzle_marker.global_position - weapon_root.global_position
		if forward.length_squared() > 0.0001:
			return forward.normalized()
	if weapon_root:
		return -weapon_root.global_transform.basis.z.normalized()
	return -player.global_transform.basis.z.normalized()


func _apply_ak_damage(origin: Vector3, direction: Vector3) -> bool:
	var candidates := []
	var flat_origin := Vector3(origin.x, 0, origin.z)
	var flat_dir := Vector3(direction.x, 0, direction.z).normalized()
	for z in zombies:
		if not z.root.visible or z.dying:
			continue
		var to_z := Vector3(z.root.position.x - flat_origin.x, 0, z.root.position.z - flat_origin.z)
		var projected := to_z.dot(flat_dir)
		if projected < 0 or projected > AK_RANGE:
			continue
		var lateral: float = maxf(0.0, to_z.length_squared() - projected * projected)
		var radius: float = float(z["radius"]) + 0.2
		if lateral <= radius * radius:
			candidates.append({"z": z, "p": projected})
	candidates.sort_custom(func(a, b): return a.p < b.p)

	var hit := false
	for i in range(mini(candidates.size(), AK_MAX_TARGETS)):
		var z: Dictionary = candidates[i]["z"]
		var hit_point: Vector3 = flat_origin + flat_dir * float(candidates[i]["p"])
		hit_point.y = randf_range(0.72, 1.42)
		_damage_zombie(z, AK_DAMAGE * (1.0 - i * 0.24), flat_dir, hit_point)
		if not bool(z.get("big", false)):
			z.stagger += flat_dir * 3.2
		hit = true
	return hit


func _apply_bullet_damage(origin: Vector3, direction: Vector3) -> bool:
	var candidates := []
	var flat_origin := Vector3(origin.x, 0, origin.z)
	var flat_dir := Vector3(direction.x, 0, direction.z).normalized()
	for z in zombies:
		if not z.root.visible or z.dying:
			continue
		var to_z := Vector3(z.root.position.x - flat_origin.x, 0, z.root.position.z - flat_origin.z)
		var projected := to_z.dot(flat_dir)
		if projected < 0 or projected > 58:
			continue
		var lateral: float = maxf(0.0, to_z.length_squared() - projected * projected)
		var radius: float = float(z["radius"]) + 0.28
		if lateral <= radius * radius:
			candidates.append({"z": z, "p": projected})
	candidates.sort_custom(func(a, b): return a.p < b.p)

	var hit := false
	for i in range(mini(candidates.size(), 4)):
		var z = candidates[i].z
		var hit_point: Vector3 = flat_origin + flat_dir * float(candidates[i]["p"])
		hit_point.y = randf_range(0.65, 1.45)
		_damage_zombie(z, 1.15 * (1.0 - i * 0.17), flat_dir, hit_point)
		hit = true
	return hit


func _damage_zombie(z: Dictionary, damage: float, direction: Vector3, hit_point: Vector3) -> void:
	z.health -= damage
	if not bool(z.get("big", false)):
		z.stagger += direction * 4.2
	_spawn_impact(hit_point, direction, true)
	_spawn_blood(hit_point, direction, false)
	_play_impact_sound()
	z.hit_flash_timer = 0.09
	_apply_zombie_flash(z, 1.0)
	if z.health <= 0:
		_trigger_hit_stop(70, 0.06)
		_kill_zombie(z, direction)
	else:
		_trigger_hit_stop(28, 0.18)


func _update_footprints(delta: float) -> void:
	blood_charge = maxf(blood_charge - delta * 0.5, 0.0)
	for d in blood_decals:
		if not d.node.visible:
			continue
		var dx: float = player.position.x - d.node.position.x
		var dz: float = player.position.z - d.node.position.z
		if dx * dx + dz * dz < 1.4:
			blood_charge = minf(blood_charge + 0.4, 6.0)
			break
	if blood_charge <= 0.0:
		footprint_step_distance = 0.0
		last_footprint_pos = player.position
		return
	footprint_step_distance += player.position.distance_to(last_footprint_pos)
	last_footprint_pos = player.position
	if footprint_step_distance >= 0.55:
		footprint_step_distance = 0.0
		_spawn_footprint(player.position, player.rotation.y)
		blood_charge = maxf(blood_charge - 0.18, 0.0)


func _spawn_footprint(pos: Vector3, yaw: float) -> void:
	if footprints.is_empty():
		return
	var fp: Dictionary = footprints[footprint_index]
	footprint_index = (footprint_index + 1) % footprints.size()
	var node: MeshInstance3D = fp.node
	var side: float = 0.18 if (footprint_index % 2 == 0) else -0.18
	var offset := Vector3(cos(yaw) * side, 0, -sin(yaw) * side)
	node.position = Vector3(pos.x + offset.x, node.position.y, pos.z + offset.z)
	node.rotation.y = yaw
	node.visible = true
	var mat := node.material_override as StandardMaterial3D
	mat.albedo_color = Color(0.42 + randf_range(-0.05, 0.05), 0.02, 0.02, 0.78)
	fp.life = randf_range(45.0, 70.0)


func _update_grenades(delta: float) -> void:
	if grenade_cooldown_remaining > 0.0:
		grenade_cooldown_remaining -= delta
	for g in grenades:
		if not g.active:
			continue
		g.life -= delta
		g.vel.y -= 14.0 * delta
		var node: MeshInstance3D = g.node
		node.global_position += g.vel * delta
		node.rotation += Vector3(g.vel.z, g.vel.x, g.vel.y) * delta * 1.5
		if node.global_position.y <= 0.18:
			node.global_position.y = 0.18
			g.vel.x *= 0.55
			g.vel.z *= 0.55
			if g.vel.y < 0:
				g.vel.y *= -0.35
			if abs(g.vel.y) < 0.4:
				g.vel.y = 0
		if g.life <= 0.0:
			var target: Vector3 = g.get("target", node.global_position)
			node.global_position = Vector3(target.x, 0.18, target.z)
			_explode_grenade(g)
	for fp in footprints:
		if not fp.node.visible:
			continue
		fp.life -= delta
		var fmat := fp.node.material_override as StandardMaterial3D
		if fp.life < 6.0:
			fmat.albedo_color.a = maxf(0.0, fp.life / 6.0) * 0.78
		if fp.life <= 0.0:
			fp.node.visible = false


func _throw_grenade(target_world: Vector3) -> void:
	if grenade_cooldown_remaining > 0.0:
		return
	for g in grenades:
		if g.active:
			continue
		grenade_cooldown_remaining = GRENADE_COOLDOWN
		g.active = true
		var origin: Vector3 = (muzzle_marker.global_position if muzzle_marker else weapon_root.global_position) if weapon_root else (player.global_position + Vector3.UP * 1.4)
		target_world.y = 0.18
		g.node.global_position = origin
		g.target = target_world
		var flat: Vector3 = target_world - origin
		flat.y = 0.0
		var distance: float = flat.length()
		var flight_time: float = clampf(distance / 16.0, 0.42, GRENADE_FUSE)
		g.life = flight_time
		var gravity: float = 14.0
		var horizontal_vel: Vector3 = flat / flight_time if distance > 0.1 else -player.global_transform.basis.z.normalized() * 4.0
		var vertical_vel: float = ((target_world.y - origin.y) + 0.5 * gravity * flight_time * flight_time) / flight_time
		g.vel = horizontal_vel + Vector3.UP * vertical_vel
		g.node.visible = true
		return


func _explode_grenade(g: Dictionary) -> void:
	g.active = false
	g.node.visible = false
	var pos: Vector3 = g.node.global_position
	shake_intensity = minf(shake_intensity + 1.4, 2.0)
	_trigger_hit_stop(110, 0.04)
	_spawn_grenade_flash(pos)
	_spawn_fire_cluster(pos)
	for i in range(28):
		var ang := randf_range(0, TAU)
		var radius := randf_range(0.8, GRENADE_RADIUS)
		var p := pos + Vector3(cos(ang) * radius, 0.05, sin(ang) * radius)
		_spawn_impact(p, Vector3(cos(ang), 0.4, sin(ang)).normalized(), false)
	_spawn_blood_decal(Vector3(pos.x, 0, pos.z), randf_range(2.4, 3.6), randf_range(160.0, 260.0))
	for z in zombies:
		if not z.root.visible or z.dying:
			continue
		var zombie_root: Node3D = z["root"]
		var dist: float = zombie_root.position.distance_to(Vector3(pos.x, zombie_root.position.y, pos.z))
		if dist <= GRENADE_RADIUS:
			var falloff: float = 1.0 - (dist / GRENADE_RADIUS)
			var dmg: float = GRENADE_DAMAGE * falloff
			var dir: Vector3 = (zombie_root.position - pos).normalized()
			if not bool(z.get("big", false)):
				z.stagger += dir * 7.0 * falloff
			_ignite_zombie(z, BURN_DURATION + falloff * 2.4)
			_damage_zombie(z, dmg, dir, zombie_root.position + Vector3(0, 1.0, 0))


func _spawn_fire_cluster(pos: Vector3) -> void:
	_spawn_fire_patch(pos, FIRE_PATCH_RADIUS * randf_range(1.0, 1.28), FIRE_PATCH_DURATION)
	for i in range(5):
		var ang := randf_range(0, TAU)
		var dist := randf_range(1.1, FIRE_PATCH_RADIUS * 1.6)
		var p := pos + Vector3(cos(ang) * dist, 0, sin(ang) * dist)
		_spawn_fire_patch(p, randf_range(1.5, FIRE_PATCH_RADIUS), randf_range(FIRE_PATCH_DURATION * 0.65, FIRE_PATCH_DURATION * 1.15))


func _spawn_fire_patch(pos: Vector3, radius: float, duration: float) -> void:
	for fp in fire_patches:
		if not fp.root.visible:
			fp.root.visible = true
			fp.root.global_position = Vector3(pos.x, 0.0, pos.z)
			fp.life = duration
			fp.max_life = duration
			fp.radius = radius
			fp.phase = randf_range(0.0, TAU)
			fp.plane.scale = Vector3.ONE * radius
			var mat := fp.plane.material_override as StandardMaterial3D
			mat.albedo_color = Color(1.0, randf_range(0.26, 0.48), 0.02, 0.82)
			fp.light.light_energy = 9.0
			return


func _update_fire_patches(delta: float) -> void:
	for fp in fire_patches:
		if not fp.root.visible:
			continue
		fp.life -= delta
		var alive: float = clampf(float(fp.life) / maxf(float(fp.max_life), 0.001), 0.0, 1.0)
		var pulse: float = 0.82 + sin(elapsed * 11.0 + float(fp.phase)) * 0.18
		var radius: float = float(fp.radius)
		fp.plane.scale = Vector3.ONE * radius * pulse
		var mat := fp.plane.material_override as StandardMaterial3D
		mat.albedo_color.a = minf(0.86, alive * 0.86)
		mat.emission_energy_multiplier = 3.0 + pulse * 3.2
		fp.light.light_energy = alive * randf_range(5.0, 11.0)

		for z in zombies:
			if not _is_live_zombie(z):
				continue
			var root: Node3D = z["root"]
			var dx: float = root.position.x - fp.root.position.x
			var dz: float = root.position.z - fp.root.position.z
			var dist_sq: float = dx * dx + dz * dz
			if dist_sq > radius * radius:
				continue
			var dist: float = sqrt(dist_sq)
			var heat: float = 1.0 - clampf(dist / radius, 0.0, 1.0) * 0.45
			_ignite_zombie(z, BURN_DURATION * heat)
			z.health -= FIRE_PATCH_DPS * heat * delta
			if float(z["health"]) <= 0.0:
				var dir: Vector3 = Vector3(dx, 0, dz).normalized() if dist > 0.01 else Vector3.FORWARD
				_kill_zombie(z, dir)
		if not player_dead:
			var pdx: float = player.position.x - fp.root.position.x
			var pdz: float = player.position.z - fp.root.position.z
			var player_dist_sq: float = pdx * pdx + pdz * pdz
			if player_dist_sq <= radius * radius:
				var player_dist: float = sqrt(player_dist_sq)
				var player_heat: float = 1.0 - clampf(player_dist / radius, 0.0, 1.0) * 0.35
				_damage_player(FIRE_PATCH_DPS * 0.78 * player_heat * delta, {})
		if fp.life <= 0.0:
			fp.root.visible = false
			fp.light.light_energy = 0.0


func _register_kill() -> void:
	var now: float = float(Time.get_ticks_msec()) / 1000.0
	recent_kills.append(now)
	recent_kills = recent_kills.filter(func(t): return now - float(t) <= MULTIKILL_WINDOW)
	var streak: int = recent_kills.size()
	if streak >= 2:
		_show_multikill(streak)


func _show_multikill(count: int) -> void:
	if multikill_label == null:
		return
	var msg: String
	var color: Color
	var font_size := 76
	if count >= 32:
		msg = "EXTINCTION EVENT"
		color = Color(1.0, 0.0, 0.0)
		font_size = 66
	elif count >= 26:
		msg = "THE GROUND NEEDS A MOP"
		color = Color(1.0, 0.08, 0.0)
		font_size = 58
	elif count >= 21:
		msg = "APOCALYPSE MULCHER"
		color = Color(1.0, 0.16, 0.02)
		font_size = 64
	elif count >= 17:
		msg = "UNREASONABLE FORCE"
		color = Color(1.0, 0.26, 0.03)
		font_size = 68
	elif count >= 14:
		msg = "INDUSTRIAL MEAT WEATHER"
		color = Color(1.0, 0.36, 0.04)
		font_size = 56
	elif count >= 11:
		msg = "HORDE DELETE BUTTON"
		color = Color(1.0, 0.48, 0.06)
		font_size = 66
	elif count >= 8:
		msg = "MONSTER KILL"
		color = Color(1.0, 0.1, 0.05)
	elif count >= 6:
		msg = "RAMPAGE"
		color = Color(1.0, 0.3, 0.05)
	elif count >= 5:
		msg = "ULTRA KILL"
		color = Color(1.0, 0.55, 0.1)
	elif count >= 4:
		msg = "MEGA KILL"
		color = Color(1.0, 0.8, 0.18)
	elif count >= 3:
		msg = "TRIPLE KILL"
		color = Color(0.95, 0.95, 0.4)
	else:
		msg = "DOUBLE KILL"
		color = Color(0.95, 1.0, 0.85)
	if count >= 11:
		msg = "%s\nx%d" % [msg, count]
	multikill_label.text = msg
	multikill_label.add_theme_color_override("font_color", color)
	multikill_label.add_theme_font_size_override("font_size", font_size)
	multikill_decay = 1.35


func _trigger_hit_stop(duration_ms: int, time_scale: float) -> void:
	var now := Time.get_ticks_msec()
	var until := now + duration_ms
	if until > hit_stop_until_msec:
		hit_stop_until_msec = until
		Engine.time_scale = time_scale


func _damage_player(amount: float, attacker: Dictionary) -> void:
	if player_dead or extraction_complete:
		return
	player_health -= amount
	player_damage_flash = minf(player_damage_flash + amount * 0.08, 0.65)
	shake_intensity = minf(shake_intensity + amount * 0.04, 0.6)
	if player_health <= 0.0:
		player_health = 0.0
		_trigger_death(attacker)


func _trigger_death(last_attacker: Dictionary) -> void:
	player_dead = true
	final_score_override = -1
	firing = false
	game_paused = false
	death_camera_timer = 0.0
	death_zoom_distance = 12.0
	death_blood_timer = 0.0
	entering_initials = true
	score_submitted = false
	current_initials = ""
	# Find the nearest live zombie to use as camera target
	var nearest_dist: float = 999.0
	var nearest_zombie: Node3D = null
	for z in zombies:
		if not z.root.visible or z.dying:
			continue
		var d: float = z.root.position.distance_to(player.position)
		if d < nearest_dist:
			nearest_dist = d
			nearest_zombie = z.root
	if nearest_zombie:
		death_camera_target = nearest_zombie
	else:
		death_camera_target = player
	# Show death UI
	death_overlay.visible = true
	death_label.text = "YOU DIED"
	death_label.add_theme_color_override("font_color", Color(0.72, 0.08, 0.04))
	death_label.visible = true
	death_sublabel.visible = true
	initials_label.visible = true
	initials_label.modulate.a = 0.0
	# Stop weapon sounds
	sustained_player.stop()
	casing_loop_player.stop()
	# Slow motion death effect
	_trigger_hit_stop(600, 0.12)


func _update_player_death_pose(delta: float) -> void:
	if body:
		body.position.y = lerpf(body.position.y, 0.28, 1.0 - pow(0.002, delta))
		body.position.z = lerpf(body.position.z, -0.12, 1.0 - pow(0.003, delta))
		body.rotation.x = lerp_angle(body.rotation.x, -0.58, 1.0 - pow(0.002, delta))
		body.rotation.z = lerp_angle(body.rotation.z, 0.34 + sin(death_camera_timer * 4.0) * 0.1, 1.0 - pow(0.01, delta))
	if weapon_root:
		var dropped_pos := player.global_position + Vector3(0.55, 0.22, -0.25)
		weapon_root.global_position = weapon_root.global_position.lerp(dropped_pos, 1.0 - pow(0.004, delta))
		weapon_root.rotation.x = lerp_angle(weapon_root.rotation.x, -0.72, 1.0 - pow(0.006, delta))
		weapon_root.rotation.z = lerp_angle(weapon_root.rotation.z, 0.58, 1.0 - pow(0.006, delta))

	death_blood_timer -= delta
	if death_blood_timer <= 0.0:
		death_blood_timer = DEATH_FEAST_BLOOD_INTERVAL
		var pos := player.global_position + Vector3(randf_range(-0.65, 0.65), 0.0, randf_range(-0.65, 0.65))
		_spawn_blood_decal(pos, randf_range(0.35, 0.95), randf_range(50.0, 120.0))
		if randf() < 0.45:
			_spawn_blood_drop(player.global_position + Vector3(0, randf_range(0.35, 1.1), 0), Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized(), true)

	for z in zombies:
		if not _is_live_zombie(z):
			continue
		var root: Node3D = z["root"]
		var to_player: Vector3 = player.global_position - root.global_position
		to_player.y = 0.0
		if to_player.length_squared() > DEATH_FEAST_RADIUS * DEATH_FEAST_RADIUS:
			continue
		if to_player.length_squared() > 0.001:
			root.look_at(root.global_position + to_player.normalized(), Vector3.UP)
		z.attacking = true
		_play_zombie_attack(z)


func _update_death_camera(delta: float) -> void:
	death_camera_timer += delta
	# Phase 1 (0-2s): Zoom camera dramatically towards player/zombies
	# Phase 2 (2-4s): Slow orbit around the carnage
	# Phase 3 (4+): Fade to black with YOU DIED text
	var focus_pos: Vector3 = player.global_position
	if death_camera_target and is_instance_valid(death_camera_target):
		focus_pos = focus_pos.lerp(death_camera_target.global_position, clampf(death_camera_timer * 0.4, 0.0, 0.55))

	if death_camera_timer < 2.5:
		# Zoom in dramatically
		death_zoom_distance = lerpf(death_zoom_distance, 3.8, 1.0 - pow(0.004, delta))
		var orbit_angle: float = death_camera_timer * 0.3
		var cam_offset := Vector3(sin(orbit_angle) * death_zoom_distance, death_zoom_distance * 0.55, cos(orbit_angle) * death_zoom_distance)
		camera.global_position = camera.global_position.lerp(focus_pos + cam_offset, 1.0 - pow(0.002, delta))
		camera.look_at(focus_pos + Vector3.UP * 0.8, Vector3.UP)
		camera.fov = lerpf(camera.fov, 38.0, 1.0 - pow(0.01, delta))
	elif death_camera_timer < 5.0:
		# Slow orbit
		var orbit_angle: float = death_camera_timer * 0.25
		var cam_offset := Vector3(sin(orbit_angle) * death_zoom_distance, death_zoom_distance * 0.48, cos(orbit_angle) * death_zoom_distance)
		camera.global_position = camera.global_position.lerp(focus_pos + cam_offset, 1.0 - pow(0.01, delta))
		camera.look_at(focus_pos + Vector3.UP * 0.7, Vector3.UP)

	# Fade in dark overlay
	var overlay_alpha: float = clampf((death_camera_timer - 1.0) / 2.5, 0.0, 0.72)
	death_overlay.color = Color(0.0, 0.0, 0.0, overlay_alpha)

	# Fade in YOU DIED text (starts at t=1.5s)
	var text_alpha: float = clampf((death_camera_timer - 1.5) / 1.2, 0.0, 1.0)
	death_label.modulate.a = text_alpha

	# Fade in restart prompt (starts at t=3.5s)
	var sub_alpha: float = clampf((death_camera_timer - 3.5) / 1.0, 0.0, 1.0)
	# Pulse the sublabel opacity
	sub_alpha *= 0.7 + 0.3 * abs(sin(death_camera_timer * 2.0))
	death_sublabel.modulate.a = sub_alpha
	if initials_label:
		initials_label.modulate.a = clampf((death_camera_timer - 2.1) / 0.9, 0.0, 1.0)
		var padded := (current_initials + "___").substr(0, 3)
		initials_label.text = "ENTER INITIALS  %s\nA-Z TYPE  BACKSPACE  ENTER" % padded if entering_initials else "SCORE SAVED\nPRESS R TO RISE AGAIN"
	if death_sublabel:
		death_sublabel.text = "Submit initials to save score" if entering_initials else "Press R to Rise Again"


func _restart_game() -> void:
	player_dead = false
	game_paused = false
	entering_initials = false
	score_submitted = false
	current_initials = ""
	final_score_override = -1
	extraction_unlocked = false
	extraction_complete = false
	extraction_timer = 0.0
	extraction_big_timer = 0.0
	extraction_position = Vector3.ZERO
	player_health = player_max_health
	player_damage_flash = 0.0
	death_camera_timer = 0.0
	death_camera_target = null
	death_blood_timer = 0.0
	kills = 0
	wave = 1
	elapsed = 0.0
	spawn_timer = 0.15
	burst_timer = 7.0
	firing = false
	active_weapon = 1
	shotgun_cooldown_remaining = 0.0
	shotgun_flash_timer = 0.0
	minigun_ammo = MINIGUN_START_AMMO
	shotgun_ammo = SHOTGUN_START_AMMO
	ak_ammo = AK_START_AMMO
	ak_shot_accumulator = 0.0
	ak_flash_timer = 0.0
	katana_cooldown_remaining = 0.0
	katana_swing_timer = 0.0
	spin = 0.0
	shot_accumulator = 0.0
	recent_kills.clear()
	multikill_decay = 0.0
	kills_pulse = 0.0
	grenade_cooldown_remaining = 0.0
	shake_intensity = 0.0
	fov_pulse_amount = 0.0
	sustained_fire_time = 0.0
	blood_charge = 0.0
	recoil_kick = 0.0
	velocity = Vector3.ZERO

	# Reset player position
	player.position = Vector3.ZERO
	if body:
		body.position = Vector3.ZERO
		body.rotation = Vector3.ZERO
	if weapon_root:
		weapon_root.rotation = Vector3.ZERO

	# Hide death UI
	death_overlay.visible = false
	death_label.text = "YOU DIED"
	death_label.add_theme_color_override("font_color", Color(0.72, 0.08, 0.04))
	death_label.visible = false
	death_sublabel.visible = false
	if initials_label:
		initials_label.visible = false
		initials_label.modulate.a = 0.0
	if pause_overlay:
		pause_overlay.visible = false
	if pause_label:
		pause_label.visible = false
	death_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	death_label.modulate.a = 0.0
	death_sublabel.modulate.a = 0.0
	if damage_vignette:
		damage_vignette.color.a = 0.0
	if extraction_marker:
		extraction_marker.visible = false
	if extraction_label:
		extraction_label.text = ""

	# Hide all zombies
	for z in zombies:
		z.root.visible = false
		z.dying = false
		z.attacking = false
		z.burning = false
		z.burn_timer = 0.0
		z.burn_tick = 0.0
		z.flashing = false
		_restore_zombie_materials(z)

	# Hide all effects
	for t in tracers:
		t.node.visible = false
	for c in casings:
		c.node.visible = false
	for d in blood_decals:
		d.node.visible = false
	for b in blood_drops:
		b.node.visible = false
	for i in impacts:
		i.node.visible = false
	for fp in footprints:
		fp.node.visible = false
	for g in grenades:
		g.active = false
		g.node.visible = false
	for gf in grenade_flash_nodes:
		gf.node.visible = false
	for fp in fire_patches:
		fp.root.visible = false
		fp.life = 0.0
		if fp.get("light", null):
			fp.light.light_energy = 0.0

	# Reset camera
	camera_distance = 17.0
	target_camera_distance = 17.0
	camera.fov = BASE_FOV

	# Reset engine time
	hit_stop_until_msec = 0
	Engine.time_scale = 1.0


func _spawn_grenade_flash(pos: Vector3) -> void:
	for gf in grenade_flash_nodes:
		if not gf.node.visible:
			gf.node.visible = true
			gf.node.global_position = pos + Vector3(0, 0.5, 0)
			gf.node.scale = Vector3.ONE * 0.5
			gf.life = 0.35
			gf.max_life = 0.35
			# Point light
			if gf.get("light", null):
				gf.light.light_energy = 28.0
			return


func _update_grenade_flashes(delta: float) -> void:
	for gf in grenade_flash_nodes:
		if not gf.node.visible:
			continue
		gf.life -= delta
		var t: float = 1.0 - clampf(gf.life / gf.max_life, 0.0, 1.0)
		# Expand rapidly then fade
		gf.node.scale = Vector3.ONE * (0.5 + t * 8.0)
		var alpha: float = clampf(1.0 - t * 2.5, 0.0, 0.92)
		var mat := gf.node.material_override as StandardMaterial3D
		mat.albedo_color.a = alpha
		if gf.get("light", null):
			gf.light.light_energy = 28.0 * (1.0 - t)
		if gf.life <= 0.0:
			gf.node.visible = false
			if gf.get("light", null):
				gf.light.light_energy = 0.0


func _update_damage_vignette(delta: float) -> void:
	if damage_vignette == null:
		return
	player_damage_flash = maxf(player_damage_flash - delta * 1.4, 0.0)
	damage_vignette.color = Color(0.65, 0.02, 0.0, player_damage_flash)


func _apply_zombie_flash(z: Dictionary, _strength: float) -> void:
	if z.get("flashing", false):
		return
	z.flashing = true
	var meshes: Array = z.get("mesh_instances", [])
	for mi in meshes:
		(mi as MeshInstance3D).material_override = mat_zombie_flash


func _apply_zombie_burn_visual(z: Dictionary) -> void:
	var meshes: Array = z.get("mesh_instances", [])
	for mi in meshes:
		(mi as MeshInstance3D).material_override = mat_zombie_burning


func _clear_zombie_flash(z: Dictionary) -> void:
	if not z.get("flashing", false):
		return
	z.flashing = false
	if bool(z.get("burning", false)):
		_apply_zombie_burn_visual(z)
		return
	_restore_zombie_materials(z)


func _restore_zombie_materials(z: Dictionary) -> void:
	var meshes: Array = z.get("mesh_instances", [])
	var originals: Array = z.get("original_overrides", [])
	for i in range(meshes.size()):
		var mi: MeshInstance3D = meshes[i]
		mi.material_override = originals[i] if i < originals.size() else null


func _kill_zombie(z: Dictionary, direction: Vector3) -> void:
	var pos: Vector3 = (z["root"] as Node3D).position
	z.dying = true
	z.death_timer = 1.7
	z.death_animating = false
	if z.anim:
		var anim_player: AnimationPlayer = z.anim
		var name := _first_existing_anim(anim_player, [zombie_death_clip, "zombie_dying", "Death01", "Death", "Die", "Hit_Chest"])
		if name != "":
			var clip := anim_player.get_animation(name)
			if clip:
				clip.loop_mode = Animation.LOOP_NONE
				z.death_timer = clip.length + 1.2
			anim_player.speed_scale = 1.0
			anim_player.play(name)
			z.death_animating = bool(z.get("animated_zombie", false))
		else:
			anim_player.speed_scale = 0.0
	kills += 1
	kills_pulse = 1.0
	shake_intensity = minf(shake_intensity + (0.95 if z.get("big", false) else 0.55), 1.4)
	_register_kill()
	var size_mult := 1.8 if z.get("big", false) else 1.0
	_spawn_blood_pool(pos, randf_range(2.0, 3.6) * size_mult)
	_spawn_blood_decal(pos, randf_range(1.8, 3.0) * size_mult, randf_range(220.0, 360.0))
	_spawn_blood_decal(pos, randf_range(1.2, 2.2) * size_mult, randf_range(220.0, 360.0))
	for i in range(12):
		_spawn_blood_decal(pos + Vector3(randf_range(-1.1, 1.1), 0, randf_range(-1.1, 1.1)), randf_range(0.55, 1.35) * size_mult, randf_range(120.0, 240.0))
	for i in range(10):
		_spawn_blood_decal(pos + Vector3(randf_range(-2.0, 2.0), 0, randf_range(-2.0, 2.0)), randf_range(0.24, 0.7) * size_mult, randf_range(90.0, 180.0))
	for i in range(30):
		_spawn_blood_drop(pos + Vector3(0, randf_range(0.4, 1.6), 0), direction, true)
	_play_one_shot(death_players, randf_range(-6.0, -3.5), 0.0)


func _spawn_tracer(origin: Vector3, direction: Vector3) -> void:
	for t in tracers:
		if not t.node.visible:
			t.node.visible = true
			t.node.global_position = origin + direction * randf_range(5, 9)
			t.node.look_at(t.node.global_position + direction, Vector3.UP)
			t.node.scale.z = randf_range(0.9, 1.25)
			t.life = randf_range(0.085, 0.14)
			t.dir = direction
			return


func _spawn_impact(position: Vector3, direction: Vector3, flesh: bool) -> void:
	for impact in impacts:
		if not impact.node.visible:
			impact.node.visible = true
			impact.node.global_position = position
			impact.node.scale = Vector3.ONE * (randf_range(0.8, 1.35) if flesh else randf_range(0.45, 0.8))
			impact.life = 0.16 if flesh else 0.12
			impact.max_life = impact.life
			impact.vel = direction * (0.6 if flesh else -0.2) + Vector3.UP * (1.0 if flesh else 0.25)
			return


func _eject_casing() -> void:
	for c in casings:
		if not c.node.visible:
			var right := weapon_root.global_transform.basis.x.normalized() if weapon_root else player.global_transform.basis.x.normalized()
			var forward := _weapon_forward()
			c.node.visible = true
			if casing_marker:
				c.node.global_position = casing_marker.global_position
			elif weapon_root:
				c.node.global_position = weapon_root.global_position + right * 0.18
			else:
				c.node.global_position = player.global_transform * Vector3(0.42, 1.42, -1.14)
			c.node.rotation = Vector3(randf(), randf(), randf()) * TAU
			c.life = randf_range(3.8, 5.3)
			c.settled = false
			c.vel = right * randf_range(2.4, 4.5) + forward * randf_range(-0.7, 0.3) + Vector3.UP * randf_range(2.1, 3.7)
			c.ang = Vector3(randf_range(-18, 18), randf_range(-24, 24), randf_range(-18, 18))
			return


func _spawn_blood(position: Vector3, direction: Vector3, lethal: bool) -> void:
	_spawn_blood_decal(Vector3(position.x, 0, position.z), randf_range(0.32, 0.8), randf_range(24, 60))
	for i in range(16 if lethal else 6):
		_spawn_blood_drop(position + Vector3(0, randf_range(0.25, 0.7), 0), direction, lethal)


func _spawn_blood_pool(position: Vector3, size: float) -> void:
	for i in range(5):
		_spawn_blood_decal(
			position + Vector3(randf_range(-0.65, 0.65), 0, randf_range(-0.65, 0.65)),
			size * randf_range(0.48, 1.18),
			randf_range(240.0, 420.0)
		)


func _spawn_blood_decal(position: Vector3, size: float, life: float) -> void:
	for d in blood_decals:
		if not d.node.visible:
			d.node.visible = true
			d.node.position = Vector3(position.x + randf_range(-0.18, 0.18), 0.03, position.z + randf_range(-0.18, 0.18))
			d.node.rotation.y = randf_range(0, TAU)
			d.node.scale = Vector3(size * randf_range(0.85, 2.05), 1, size * randf_range(0.52, 1.36))
			var mat := d.node.material_override as StandardMaterial3D
			var darkness := clampf(size / 3.2, 0.0, 1.0)
			mat.albedo_color = Color(lerpf(0.5, 0.16, darkness), 0.0, 0.0, randf_range(0.58, 0.92))
			d.life = life
			return


func _spawn_blood_drop(position: Vector3, direction: Vector3, lethal: bool) -> void:
	for b in blood_drops:
		if not b.node.visible:
			var side := Vector3(-direction.z, 0, direction.x)
			b.node.visible = true
			b.node.global_position = position
			b.node.scale = Vector3.ONE * (randf_range(1.0, 1.8) if lethal else randf_range(0.65, 1.15))
			b.life = randf_range(0.38, 0.75) if lethal else randf_range(0.22, 0.5)
			b.vel = direction * (randf_range(2.1, 4.5) if lethal else randf_range(1.0, 2.5)) + side * randf_range(-1.8, 1.8) + Vector3.UP * (randf_range(1.5, 3.4) if lethal else randf_range(0.8, 2.0))
			return


func _update_tracers(delta: float) -> void:
	for t in tracers:
		if not t.node.visible:
			continue
		t.life -= delta
		t.node.global_position += t.dir * 78.0 * delta
		var mat := t.node.material_override as StandardMaterial3D
		mat.albedo_color.a = clamp(t.life * 8.5, 0.0, 0.9)
		if t.life <= 0:
			t.node.visible = false


func _update_casings(delta: float) -> void:
	for c in casings:
		if not c.node.visible:
			continue
		c.life -= delta
		if not c.settled:
			c.vel.y -= 12.5 * delta
			c.node.global_position += c.vel * delta
			c.node.rotation += c.ang * delta
			if c.node.global_position.y <= 0.08:
				c.node.global_position.y = 0.08
				if abs(c.vel.y) > 0.9:
					c.vel.y *= -0.22
					c.vel.x *= 0.68
					c.vel.z *= 0.68
					c.ang *= 0.55
				else:
					c.vel = Vector3.ZERO
					c.ang = Vector3.ZERO
					c.settled = true
		if c.life <= 0:
			c.node.visible = false


func _update_blood(delta: float) -> void:
	for b in blood_drops:
		if not b.node.visible:
			continue
		b.life -= delta
		b.vel.y -= 10.0 * delta
		b.node.global_position += b.vel * delta
		if b.node.global_position.y <= 0.05:
			_spawn_blood_decal(b.node.global_position, randf_range(0.1, 0.28) * b.node.scale.x, randf_range(24, 70))
			b.node.visible = false
		elif b.life <= 0:
			b.node.visible = false
	for d in blood_decals:
		if not d.node.visible:
			continue
		d.life -= delta
		if d.life < 4:
			(d.node.material_override as StandardMaterial3D).albedo_color.a = max(0.0, d.life / 4.0) * 0.58
		if d.life <= 0:
			d.node.visible = false


func _update_impacts(delta: float) -> void:
	for impact in impacts:
		if not impact.node.visible:
			continue
		impact.life -= delta
		impact.node.global_position += impact.vel * delta
		impact.node.scale *= 1.0 + delta * 3.0
		(impact.node.material_override as StandardMaterial3D).albedo_color.a = clamp(impact.life / impact.max_life, 0.0, 1.0)
		if impact.life <= 0:
			impact.node.visible = false


func _update_camera(delta: float) -> void:
	camera_distance = _damp(camera_distance, target_camera_distance, 6.5, delta)
	camera.global_position = camera.global_position.lerp(player.global_position + Vector3(0, camera_distance * 0.72, camera_distance), 1.0 - pow(0.0007, delta))
	camera.look_at(player.global_position + Vector3.UP * 1.2, Vector3.UP)

	if firing and spin > 0.6:
		sustained_fire_time = minf(sustained_fire_time + delta, 1.0)
	else:
		sustained_fire_time = lerpf(sustained_fire_time, 0.0, 1.0 - pow(0.02, delta))

	shake_intensity = lerpf(shake_intensity, 0.0, 1.0 - pow(0.00012, delta))
	fov_pulse_amount = lerpf(fov_pulse_amount, 0.0, 1.0 - pow(0.0006, delta))

	var jitter := Vector3(
		randf_range(-1.0, 1.0) * shake_intensity * 0.18,
		randf_range(-1.0, 1.0) * shake_intensity * 0.18,
		randf_range(-1.0, 1.0) * shake_intensity * 0.10
	)
	camera.global_position += jitter
	camera.fov = BASE_FOV + sustained_fire_time * 2.4 + fov_pulse_amount


func _update_audio(delta: float) -> void:
	var ready := active_weapon == 1 and firing and spin > 0.68 and minigun_ammo > 0
	if ready:
		if not sustained_player.playing:
			sustained_player.play()
		if not casing_loop_player.playing:
			casing_loop_player.play()
	var target_sustained := -3.0 if ready else -80.0
	var target_casing := -8.0 if ready else -80.0
	sustained_player.volume_db = _damp(sustained_player.volume_db, target_sustained, 9.0, delta)
	casing_loop_player.volume_db = _damp(casing_loop_player.volume_db, target_casing, 9.0, delta)
	if not ready and sustained_player.volume_db < -55:
		sustained_player.stop()
	if not ready and casing_loop_player.volume_db < -55:
		casing_loop_player.stop()


func _update_hud() -> void:
	kills_label.text = "Kills\n%d" % kills
	wave_label.text = "Wave\n%d" % wave
	zoom_label.text = "Camera\n%dm" % int(round(target_camera_distance))
	spin_label.text = "Spin\n%d%%" % int(round(spin * 100))
	zombie_label.text = "Zombies\n%d" % _active_zombie_count()
	_update_weapon_cards()
	if kills_giant_label:
		kills_giant_label.text = "%d" % kills
		var pulse_scale: float = 1.0 + kills_pulse * 0.12
		kills_giant_label.scale = Vector2(pulse_scale, pulse_scale)
		kills_pulse = lerpf(kills_pulse, 0.0, 0.16)
	if multikill_label:
		multikill_label.modulate.a = clampf(multikill_decay, 0.0, 1.0)
		var mk_scale: float = 1.0 + clampf(multikill_decay - 0.5, 0.0, 0.5) * 0.6
		multikill_label.scale = Vector2(mk_scale, mk_scale)
		multikill_decay = maxf(multikill_decay - 0.012, 0.0)
	# Health bar
	if health_bar_fill:
		var hp_ratio: float = clampf(player_health / player_max_health, 0.0, 1.0)
		health_bar_fill.size.x = UI_HP_BAR_WIDTH * hp_ratio
		if hp_ratio > 0.6:
			health_bar_fill.color = Color(0.15, 0.75, 0.18)
		elif hp_ratio > 0.3:
			health_bar_fill.color = Color(0.92, 0.72, 0.12)
		else:
			var pulse: float = abs(sin(elapsed * 6.0))
			health_bar_fill.color = Color(0.85, 0.08 + pulse * 0.15, 0.05)
	if health_bar_label:
		health_bar_label.text = "HP %d/%d" % [int(ceil(player_health)), int(player_max_health)]
	if extraction_label:
		if extraction_complete:
			extraction_label.text = "EXTRACTED\nFINAL SCORE %d" % max(final_score_override, kills)
		elif extraction_unlocked:
			var dist := Vector2(player.global_position.x, player.global_position.z).distance_to(Vector2(extraction_position.x, extraction_position.z))
			var remaining := maxf(EXTRACTION_HOLD_TIME - extraction_timer, 0.0)
			if dist <= EXTRACTION_RADIUS:
				extraction_label.text = "EXTRACTING\n%.1fs HOLD THE LINE" % remaining
			else:
				extraction_label.text = "EXTRACT OPEN\n%.0fm TO BEACON" % dist
		else:
			var kills_left: int = maxi(0, EXTRACTION_UNLOCK_KILLS - kills)
			extraction_label.text = "EXTRACT LOCKED\nWAVE %d OR %d MORE KILLS" % [EXTRACTION_UNLOCK_WAVE, kills_left]


func _load_leaderboard() -> void:
	leaderboard.clear()
	if FileAccess.file_exists(LEADERBOARD_PATH):
		var file := FileAccess.open(LEADERBOARD_PATH, FileAccess.READ)
		if file:
			var parsed = JSON.parse_string(file.get_as_text())
			if typeof(parsed) == TYPE_ARRAY:
				for entry in parsed:
					if typeof(entry) == TYPE_DICTIONARY and entry.has("name") and entry.has("score"):
						leaderboard.append({
							"name": String(entry["name"]).substr(0, 3),
							"score": int(entry["score"]),
							"wave": int(entry.get("wave", 1))
						})
	if leaderboard.is_empty():
		leaderboard = [
			{"name": "AAA", "score": 1000, "wave": 12},
			{"name": "BOB", "score": 500, "wave": 8},
			{"name": "COD", "score": 250, "wave": 5}
		]
	_sort_leaderboard()


func _save_leaderboard() -> void:
	var file := FileAccess.open(LEADERBOARD_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(leaderboard))


func _sort_leaderboard() -> void:
	leaderboard.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	if leaderboard.size() > 8:
		leaderboard.resize(8)


func _refresh_leaderboard_label() -> void:
	if leaderboard_label == null:
		return
	_sort_leaderboard()
	var text := "LEADERBOARD\n"
	for i in range(mini(5, leaderboard.size())):
		var entry: Dictionary = leaderboard[i]
		text += "%d. %s  %04d  W%d\n" % [i + 1, String(entry["name"]).substr(0, 3), int(entry["score"]), int(entry.get("wave", 1))]
	leaderboard_label.text = text


func _handle_initials_input(event: InputEventKey) -> void:
	if score_submitted:
		return
	if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
		_submit_score()
		return
	if event.keycode == KEY_BACKSPACE:
		if current_initials.length() > 0:
			current_initials = current_initials.substr(0, current_initials.length() - 1)
		return
	if current_initials.length() >= 3:
		return
	var letter_index := int(event.keycode) - int(KEY_A)
	if letter_index >= 0 and letter_index < 26:
		current_initials += "ABCDEFGHIJKLMNOPQRSTUVWXYZ".substr(letter_index, 1)
		return
	var digit_index := int(event.keycode) - int(KEY_0)
	if digit_index >= 0 and digit_index <= 9:
		current_initials += "0123456789".substr(digit_index, 1)


func _submit_score() -> void:
	if score_submitted:
		return
	var name := (current_initials + "AAA").substr(0, 3)
	var final_score := final_score_override if final_score_override >= 0 else kills
	leaderboard.append({"name": name, "score": final_score, "wave": wave})
	_sort_leaderboard()
	_save_leaderboard()
	_refresh_leaderboard_label()
	entering_initials = false
	score_submitted = true


func _active_zombie_count() -> int:
	var count := 0
	for z in zombies:
		if z.root.visible and not z.dying:
			count += 1
	return count


func _import_shooter_animations() -> void:
	operator_idle_clip = _copy_animation_clip("rifle aiming idle.fbx", "rifle_aim_idle")
	operator_run_clip = _copy_animation_clip("rifle run.fbx", "rifle_run")
	operator_walk_clip = _copy_animation_clip("walking.fbx", "rifle_walk")
	operator_back_clip = _copy_animation_clip("walking backwards.fbx", "rifle_back")
	operator_strafe_left_clip = _copy_animation_clip("strafe (2).fbx", "rifle_strafe_left")
	operator_strafe_right_clip = _copy_animation_clip("strafe.fbx", "rifle_strafe_right")

	if operator_idle_clip == "":
		operator_idle_clip = _first_existing_anim(operator_anim, ["Take 001", "mixamo_com"])
	if operator_run_clip == "":
		operator_run_clip = operator_walk_clip
	if operator_walk_clip == "":
		operator_walk_clip = operator_run_clip
	print("[player anims] ", operator_anim.get_animation_list())


func _import_zombie_animations(anim_player: AnimationPlayer) -> void:
	_copy_animation_clip_to_player(anim_player, ZOMBIE_PACK_DIR, "zombie idle.fbx", zombie_idle_clip)
	_copy_animation_clip_to_player(anim_player, ZOMBIE_PACK_DIR, "zombie walk.fbx", zombie_walk_clip)
	_copy_animation_clip_to_player(anim_player, ZOMBIE_PACK_DIR, "zombie run.fbx", zombie_run_clip)
	_copy_animation_clip_to_player(anim_player, ZOMBIE_PACK_DIR, "zombie attack.fbx", zombie_attack_clip)
	var death_name := _copy_animation_clip_to_player(anim_player, ZOMBIE_PACK_DIR, "zombie death.fbx", zombie_death_clip)
	if death_name == "":
		_copy_animation_clip_to_player(anim_player, ZOMBIE_PACK_DIR, "zombie dying.fbx", "zombie_dying")


func _copy_animation_clip(file_name: String, clip_name: String) -> String:
	if not operator_anim:
		return ""
	return _copy_animation_clip_to_player(operator_anim, SHOOTER_PACK_DIR, file_name, clip_name, true)


func _copy_animation_clip_to_player(target_player: AnimationPlayer, base_dir: String, file_name: String, clip_name: String, strip_root_motion := true) -> String:
	if not target_player:
		return ""
	var scene := load("%s/%s" % [base_dir, file_name]) as PackedScene
	if not scene:
		return ""
	var root := scene.instantiate()
	var source_player := _find_anim_player(root)
	if not source_player:
		root.free()
		return ""
	var source_name := _first_existing_anim(source_player, ["mixamo_com", "Take 001"])
	if source_name == "" and source_player.get_animation_list().size() > 0:
		source_name = source_player.get_animation_list()[0]
	if source_name == "":
		root.free()
		return ""

	var animation := source_player.get_animation(source_name).duplicate(true) as Animation
	if strip_root_motion:
		_strip_horizontal_root_motion(animation)
	var library := target_player.get_animation_library("")
	if not library:
		library = AnimationLibrary.new()
		target_player.add_animation_library("", library)
	if library.has_animation(clip_name):
		library.remove_animation(clip_name)
	library.add_animation(clip_name, animation)
	root.free()
	return clip_name


func _strip_horizontal_root_motion(animation: Animation) -> void:
	for i in range(animation.get_track_count()):
		if animation.track_get_type(i) != Animation.TYPE_POSITION_3D:
			continue
		var path := String(animation.track_get_path(i)).to_lower()
		if not ("hips" in path or "root" in path or "armature" in path):
			continue
		var key_count := animation.track_get_key_count(i)
		if key_count <= 0:
			continue
		var anchor: Vector3 = animation.track_get_key_value(i, 0)
		for key in range(key_count):
			var value: Vector3 = animation.track_get_key_value(i, key)
			value.x = anchor.x
			value.z = anchor.z
			animation.track_set_key_value(i, key, value)


func _choose_operator_clip(input: Vector3, moving: bool) -> String:
	if not moving:
		return operator_idle_clip

	var local_input := player.global_transform.basis.inverse() * input
	if abs(local_input.x) > abs(local_input.z) * 1.25:
		if local_input.x < 0.0 and operator_strafe_left_clip != "":
			return operator_strafe_left_clip
		if local_input.x >= 0.0 and operator_strafe_right_clip != "":
			return operator_strafe_right_clip

	if local_input.z > 0.25 and operator_back_clip != "":
		return operator_back_clip
	if operator_run_clip != "":
		return operator_run_clip
	if operator_walk_clip != "":
		return operator_walk_clip
	return operator_idle_clip


func _cache_operator_leg_bones() -> void:
	operator_leg_bones.clear()
	if not operator_skeleton:
		return
	for bone_name in ["pelvis", "thigh_l", "calf_l", "foot_l", "thigh_r", "calf_r", "foot_r"]:
		var index := operator_skeleton.find_bone(bone_name)
		if index >= 0:
			operator_leg_bones[bone_name] = index


func _apply_procedural_aim_run(speed01: float) -> void:
	if not operator_skeleton or operator_leg_bones.is_empty():
		return

	var stride := step_time * 1.45
	var left := sin(stride)
	var right := sin(stride + PI)
	var weight := clampf(speed01, 0.0, 1.0)

	_add_global_pose_rotation("pelvis", Vector3(0, 0, 1), sin(stride) * 0.06, weight)
	_add_global_pose_rotation("thigh_l", Vector3(1, 0, 0), left * 0.82, weight)
	_add_global_pose_rotation("thigh_r", Vector3(1, 0, 0), right * 0.82, weight)
	_add_global_pose_rotation("calf_l", Vector3(1, 0, 0), maxf(0.0, -left) * 1.1, weight)
	_add_global_pose_rotation("calf_r", Vector3(1, 0, 0), maxf(0.0, -right) * 1.1, weight)
	_add_global_pose_rotation("foot_l", Vector3(1, 0, 0), -left * 0.34, weight)
	_add_global_pose_rotation("foot_r", Vector3(1, 0, 0), -right * 0.34, weight)
	operator_skeleton.force_update_all_bone_transforms()


func _add_global_pose_rotation(bone_name: String, axis: Vector3, radians: float, weight: float) -> void:
	if not operator_leg_bones.has(bone_name):
		return
	var index: int = operator_leg_bones[bone_name]
	var pose := operator_skeleton.get_bone_global_pose_no_override(index)
	pose.basis = pose.basis * Basis(Quaternion(axis.normalized(), radians * weight))
	operator_skeleton.set_bone_global_pose_override(index, pose, 1.0, true)


func _apply_zombie_tint(node: Node3D, seed: int) -> void:
	var hue_shift: float = float(seed % 5) * 0.05
	var rot_shift: float = float((seed * 7) % 11) * 0.02
	var zombie_color := Color(0.18 + rot_shift, 0.42 + hue_shift, 0.16 + rot_shift * 0.4)
	var zombie_mat := StandardMaterial3D.new()
	zombie_mat.albedo_color = zombie_color
	zombie_mat.roughness = 0.82
	zombie_mat.metallic = 0.0
	zombie_mat.emission_enabled = true
	zombie_mat.emission = Color(0.05, 0.18, 0.04)
	zombie_mat.emission_energy_multiplier = 0.35
	for child in node.find_children("*", "MeshInstance3D", true, false):
		var mi: MeshInstance3D = child
		mi.material_override = zombie_mat


func _hide_imported_helper_nodes(node: Node3D) -> void:
	for child in node.find_children("*", "Node3D", true, false):
		var child_3d: Node3D = child
		var lower := child_3d.name.to_lower()
		if lower.begins_with("text"):
			child_3d.visible = false


func _normalize_height(node: Node3D, target_height: float) -> void:
	var aabb := _aggregate_aabb(node)
	if aabb.size.y > 0.01:
		var s: float = target_height / aabb.size.y
		node.scale = Vector3.ONE * s
		var lowest: float = aabb.position.y * s
		node.position.y -= lowest


func _normalize_max_dimension(node: Node3D, target: float) -> void:
	var aabb := _aggregate_aabb(node)
	var max_dim: float = maxf(maxf(aabb.size.x, aabb.size.y), aabb.size.z)
	if max_dim > 0.001:
		node.scale = Vector3.ONE * (target / max_dim)


func _center_visual_origin(node: Node3D) -> void:
	var aabb := _aggregate_aabb(node)
	if aabb.size.length() > 0.001:
		node.position -= aabb.get_center() * node.scale.x


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


func _find_skeleton_with_bone(node: Node, candidates: Array) -> Skeleton3D:
	if node is Skeleton3D:
		if _find_bone_name(node, candidates) != "":
			return node
	for child in node.get_children():
		var found := _find_skeleton_with_bone(child, candidates)
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


func _find_bone_name(skel: Skeleton3D, candidates: Array) -> String:
	for desired in candidates:
		for i in range(skel.get_bone_count()):
			var bone_name := skel.get_bone_name(i)
			if bone_name == String(desired):
				return bone_name
	for i in range(skel.get_bone_count()):
		var lower := skel.get_bone_name(i).to_lower()
		if "hand" in lower and ("right" in lower or lower.ends_with("_r") or lower.ends_with(".r")):
			return skel.get_bone_name(i)
	return ""


func _list_bone_names(skel: Skeleton3D) -> Array:
	var names := []
	for i in range(skel.get_bone_count()):
		names.append(skel.get_bone_name(i))
	return names


func _find_anim_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var found := _find_anim_player(child)
		if found:
			return found
	return null


func _first_existing_anim(anim: AnimationPlayer, names: Array) -> String:
	var available := anim.get_animation_list()
	for desired in names:
		for clip_name in available:
			if String(clip_name) == String(desired):
				return clip_name
	return ""


func _pick_anim(anim: AnimationPlayer, keywords: Array) -> String:
	for clip_name in anim.get_animation_list():
		var lower := String(clip_name).to_lower()
		for kw in keywords:
			if String(kw) in lower:
				return clip_name
	return ""


func _pick_anim_excluding(anim: AnimationPlayer, exclude_keywords: Array) -> String:
	for clip_name in anim.get_animation_list():
		var lower := String(clip_name).to_lower()
		var blocked := false
		for kw in exclude_keywords:
			if String(kw) in lower:
				blocked = true
				break
		if not blocked:
			return clip_name
	return ""


func _place_belt_segment(seg: Dictionary, t: float) -> void:
	var length := belt_curve.get_baked_length()
	var pos := belt_curve.sample_baked(t * length)
	var pos2 := belt_curve.sample_baked(fmod(t + 0.01, 1.0) * length)
	var tangent := (pos2 - pos).normalized()
	seg.round.position = pos
	seg.round.look_at(pos + tangent, Vector3.UP)
	seg.round.rotation.x += deg_to_rad(90)
	seg.link.position = pos + Vector3(0, -0.1, 0)
	seg.link.look_at(pos + tangent, Vector3.UP)


func _play_impact_sound() -> void:
	var now := Time.get_ticks_msec()
	if now - last_impact_sound_ms < 85:
		return
	last_impact_sound_ms = now
	_play_one_shot(impact_players, randf_range(-14.0, -9.0), randf_range(0.0, 1.5))


func _play_one_shot(pool: Array, volume_db: float, offset: float) -> void:
	for player_node in pool:
		if not player_node.playing:
			player_node.volume_db = volume_db
			player_node.play(offset)
			return
	var p = pool[0]
	p.stop()
	p.volume_db = volume_db
	p.play(offset)


func _audio_player(path: String, volume_db: float, loop: bool) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	var stream = load(path)
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD if loop else AudioStreamWAV.LOOP_DISABLED
	if stream is AudioStreamMP3:
		stream.loop = loop
	p.stream = stream
	p.volume_db = volume_db
	add_child(p)
	return p


func _add_hud_label(parent: Control, text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.custom_minimum_size = Vector2(86, 46)
	label.add_theme_color_override("font_color", Color(0.96, 0.96, 0.94))
	label.add_theme_font_size_override("font_size", 14)
	parent.add_child(label)
	return label


func _add_part(parent: Node3D, node: MeshInstance3D, pos: Vector3, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
	node.position = pos
	node.rotation = rot
	parent.add_child(node)
	return node


func _box(size: Vector3, material: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material
	return node


func _sphere(scale: Vector3, material: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radial_segments = 18
	mesh.rings = 9
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.scale = scale
	node.material_override = material
	return node


func _cylinder(radius: float, height: float, material: Material) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 14
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material
	return node


func _torus(major_radius: float, minor_radius: float, material: Material) -> MeshInstance3D:
	var mesh := TorusMesh.new()
	mesh.inner_radius = major_radius - minor_radius
	mesh.outer_radius = major_radius + minor_radius
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = material
	return node


func _mat(color: Color, roughness: float, metalness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	material.metallic = metalness
	return material


func _emissive_mat(color: Color, energy: float) -> StandardMaterial3D:
	var material := _mat(color, 0.22, 0.1)
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


func _transparent_mat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	material.depth_draw_mode = BaseMaterial3D.DEPTH_DRAW_ALWAYS
	return material


func _damp(current: float, target: float, smoothing: float, delta: float) -> float:
	return lerpf(current, target, 1.0 - exp(-smoothing * delta))
