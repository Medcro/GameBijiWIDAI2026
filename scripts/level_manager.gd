extends Node

## buat minimap
#signal map_updated

signal level_changed(new_level: int)

# --- room files dictionary ---
const LEVEL_ROOM_SCENES = {
	1: {
		RoomData.Type.SPAWN: ["res://scenes/rooms/level1/spawn_var_1.tscn"],
		RoomData.Type.PLATFORM: ["res://scenes/rooms/level1/platform_var_1.tscn", "res://scenes/rooms/level1/platform_var_2.tscn"],
		RoomData.Type.MINION: ["res://scenes/rooms/level1/minion_var_1.tscn", "res://scenes/rooms/level1/minion_var_2.tscn", "res://scenes/rooms/level1/minion_var_3.tscn"],
		RoomData.Type.TREASURE: ["res://scenes/rooms/level1/treasure_var_1.tscn"],
		RoomData.Type.PASSIVE: ["res://scenes/rooms/level1/passive_var_1.tscn", "res://scenes/rooms/level1/passive_var_2.tscn"],
		RoomData.Type.BOSS: ["res://scenes/rooms/level1/boss_var_1.tscn"]
	},
	2: { #beda sendiri cok i guess bro
		RoomData.Type.SPAWN: ["res://scenes/rooms/level2/spawn_var_1.tscn", "res://scenes/rooms/level2/spawn_var_2.tscn"],
		RoomData.Type.PLATFORM: ["res://scenes/rooms/level2/platform_var_1.tscn", "res://scenes/rooms/level2/platform_var_2.tscn", "res://scenes/rooms/level2/platform_var_3.tscn", "res://scenes/rooms/level2/platform_var_4.tscn", "res://scenes/rooms/level2/platform_var_5.tscn"],
		RoomData.Type.MINION: ["res://scenes/rooms/level2/minion_var_1.tscn", "res://scenes/rooms/level2/minion_var_2.tscn", "res://scenes/rooms/level2/minion_var_3.tscn", "res://scenes/rooms/level2/minion_var_4.tscn", "res://scenes/rooms/level2/minion_var_5.tscn", "res://scenes/rooms/level2/minion_var_6.tscn", "res://scenes/rooms/level2/minion_var_7.tscn"],
		RoomData.Type.TREASURE: ["res://scenes/rooms/level2/treasure_var_1.tscn", "res://scenes/rooms/level2/treasure_var_2.tscn"],
		RoomData.Type.PASSIVE: ["res://scenes/rooms/level2/passive_var_1.tscn", "res://scenes/rooms/level2/passive_var_2.tscn"],
		RoomData.Type.BOSS: ["res://scenes/rooms/level2/boss_var_1.tscn", "res://scenes/rooms/level2/boss_var_2.tscn"]
	},
	3: {
		RoomData.Type.SPAWN: ["res://scenes/rooms/level3/spawn_var_1.tscn"],
		RoomData.Type.PLATFORM: ["res://scenes/rooms/level3/platform_var_1.tscn"],
		RoomData.Type.MINION: ["res://scenes/rooms/level3/minion_var_1.tscn"],
		RoomData.Type.TREASURE: ["res://scenes/rooms/level3/treasure_var_1.tscn"],
		RoomData.Type.PASSIVE: ["res://scenes/rooms/level3/passive_var_1.tscn"],
		RoomData.Type.BOSS: ["res://scenes/rooms/level3/boss_var_1.tscn"]
	},
	4: {
		RoomData.Type.SPAWN: ["res://scenes/rooms/level4/spawn_var_1.tscn"],
		RoomData.Type.PLATFORM: ["res://scenes/rooms/level4/platform_var_1.tscn"],
		RoomData.Type.MINION: ["res://scenes/rooms/level4/minion_var_1.tscn"],
		RoomData.Type.TREASURE: ["res://scenes/rooms/level4/treasure_var_1.tscn"],
		RoomData.Type.PASSIVE: ["res://scenes/rooms/level4/passive_var_1.tscn"],
		RoomData.Type.BOSS: ["res://scenes/rooms/level4/boss_var_1.tscn"]
	},
	5: {
		RoomData.Type.SPAWN: ["res://scenes/rooms/level5/spawn_var_1.tscn"],
		RoomData.Type.PLATFORM: ["res://scenes/rooms/level5/platform_var_1.tscn"],
		RoomData.Type.MINION: ["res://scenes/rooms/level5/minion_var_1.tscn"],
		RoomData.Type.TREASURE: ["res://scenes/rooms/level5/treasure_var_1.tscn"],
		RoomData.Type.PASSIVE: ["res://scenes/rooms/level5/passive_var_1.tscn"],
		RoomData.Type.BOSS: ["res://scenes/rooms/level5/boss_var_1.tscn"]
	}
}

# map level yang sekarang dipakai
var current_map: Dictionary = {}
# sistemnya basically kayak matriks, di kolom x row y ada room apa ditentuin nnti sama func _get_leveln_layoutz
var current_room_coords: Vector2i = Vector2i.ZERO

var target_entrance_vector: Vector2i = Vector2i.ZERO # ngasih tau arah pintu

var current_level_num: int = 1
var max_levels: int = 5 # woah 5 level yh

var target_cutscene: String = ""

func generate_new_level() -> void:
	current_map.clear()
	target_entrance_vector = Vector2i.ZERO
	
	var layouts = []
	
	# inisialisasi layout level
	if current_level_num == 1:
		layouts = [
			_get_level1_layout_1(), _get_level1_layout_2(), _get_level1_layout_3()
			]
	#elif current_level_num == 2:
		#layouts = [_get_level2_layout_1(), _get_level2_layout_2(), _get_level2_layout_3()]
	#elif current_level_num == 3:
		#layouts = [_get_level3_layout_1(), _get_level3_layout_2(), _get_level3_layout_3()]
	#elif current_level_num == 4:
		#layouts = [_get_level4_layout_1(), _get_level4_layout_2(), _get_level4_layout_3()]
	#elif current_level_num == 5:
		#layouts = [_get_level5_layout_1()]
	
	# pilih layout
	var chosen_layout: Dictionary = layouts.pick_random()
	
	# fetch room pool based on level
	var level_pool = LEVEL_ROOM_SCENES.get(current_level_num, LEVEL_ROOM_SCENES[1])
	
	# build the level
	for coords in chosen_layout:
		var layout_data = chosen_layout[coords]
		
		var type = layout_data["type"]
		var room = RoomData.new(coords, type)
		
		var available_scenes = level_pool[type]
		var chosen_scene = ""
		
		if typeof(layout_data) == TYPE_DICTIONARY and layout_data.has("var"):
			var target_var = layout_data["var"]
			if target_var > 0 and target_var <= available_scenes.size():
				room.variation_id = target_var
				chosen_scene = available_scenes[target_var - 1]
			else:
				push_warning("Variation missing. Falling back to random.")
				chosen_scene = available_scenes.pick_random()
				room.variation_id = available_scenes.find(chosen_scene) + 1
		else:
			chosen_scene = available_scenes.pick_random()
			room.variation_id = available_scenes.find(chosen_scene) + 1 
			
		# check for allowed entrances
		if typeof(layout_data) == TYPE_DICTIONARY and layout_data.has("allowed_entrances"):
			room.allowed_entrances = layout_data["allowed_entrances"]
			
		room.scene_path = chosen_scene
		current_map[coords] = room

		
		if type == RoomData.Type.SPAWN:
			current_room_coords = coords

	# 3. Enter the spawn room
	enter_room(current_room_coords)

func move_to_room(direction: Vector2i) -> void:
	var target_coords = current_room_coords + direction
	
	if current_map.has(target_coords):
		enter_room(target_coords)
	else:
		push_warning("Attempted to move to a room that doesn't exist!")

func enter_room(coords: Vector2i) -> void:
	current_room_coords = coords
	var room: RoomData = current_map[coords]
	room.is_discovered = true
	await Transition.play_transition()
	#map_updated.emit()
	
	get_tree().call_deferred("change_scene_to_file", room.scene_path)
	print("Entered Room: ", RoomData.Type.keys()[room.type], " | Var: ", room.variation_id)
	await Transition.play_transition_backwards()

# --- UPGRADE 2: Progression & Transition Logic ---
func complete_level() -> void:
	print("Boss defeated! Level ", current_level_num, " complete.")
	
	if current_level_num < max_levels:
		target_cutscene = "level_" + str(current_level_num) + "_end"
		get_tree().call_deferred("change_scene_to_file", "res://scenes/cutscene.tscn")
	else:
		target_cutscene = "outro"
		get_tree().call_deferred("change_scene_to_file", "res://scenes/cutscene.tscn")

# The Cutscene scene will call this function when it finishes playing
func start_next_level() -> void:
	current_level_num += 1
	level_changed.emit(current_level_num)
	generate_new_level()

func get_map_save_data() -> Dictionary:
	var serialized_map = {}
	
	for coords in current_map:
		var room = current_map[coords]
		# Kita ubah koordinat Vector2i menjadi String "x,y" sebagai key karena
		# Dictionary yang di-save ke file kadang bermasalah jika key-nya berupa Vector.
		var coord_key = str(coords.x) + "," + str(coords.y)
		
		# Pecah properti RoomData menjadi tipe data primitif
		serialized_map[coord_key] = {
			"scene_path": room.scene_path,
			"type": room.type,
			"variation_id": room.variation_id,
			"is_discovered": room.is_discovered,
			"is_cleared": room.is_cleared,
			"allowed_entrances": room.allowed_entrances
		}
		
	return serialized_map

func load_map_from_save(saved_level_num: int, saved_room_coords: Vector2i, saved_map_data: Dictionary) -> void:
	# 1. Bersihkan peta lama dan setel variabel level saat ini
	current_map.clear()
	current_level_num = saved_level_num
	current_room_coords = saved_room_coords
	target_entrance_vector = Vector2i.ZERO
	# Ambil kelas RoomData secara dinamis (sesuai cara inner-class kamu)
	# Catatan: Jika RoomData adalah class_name tersendiri, kamu bisa langsung pakai RoomData
	# 2. Lakukan perulangan untuk membangun ulang objek RoomData
	for coord_string in saved_map_data:
		# Kembalikan string "x,y" menjadi Vector2i
		var parts = coord_string.split(",")
		var coords = Vector2i(int(parts[0]), int(parts[1]))
		
		var data = saved_map_data[coord_string]
		
		# Buat ulang objek RoomData baru
		var room = RoomData.new(coords, data["type"])
		room.scene_path = data["scene_path"]
		room.variation_id = data["variation_id"]
		room.is_discovered = data["is_discovered"]
		room.is_cleared = data["is_cleared"]
		
		# Kembalikan daftar arah pintu (karena Vector2i di-save otomatis oleh store_var)
		room.allowed_entrances = data["allowed_entrances"]
		
		# Masukkan kembali ke dalam memory map aktif
		current_map[coords] = room
		
	## 3. Beritahu UI/Minimap jika ada signal yang perlu di-update
	#level_changed.emit(current_level_num)
	# 4. Masuk ke room terakhir tempat player melakukan save
	enter_room(current_room_coords)
func proceed_from_cutscene() -> void:
	if target_cutscene == "outro":
		# Game is completely over, return to main menu or credits!
		get_tree().call_deferred("change_scene_to_file", "res://scenes/main_menu.tscn")
		return
		
	# If we just watched the intro, stay on level 1. Otherwise, move to the next level.
	if target_cutscene != "intro":
		current_level_num += 1
		level_changed.emit(current_level_num)
		
	generate_new_level()

# ==========================================
# --- LAYOUT LEVELS ---
# ==========================================

# --- LEVEL 1 ---
func _get_level1_layout_1() -> Dictionary:
	return {
		Vector2i(-3, 0): {"type": RoomData.Type.MINION, "var": 1, "allowed_entrances": [Vector2i.LEFT]}, Vector2i(-2, 0): {"type": RoomData.Type.PASSIVE, "var": 1, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT]}, Vector2i(-1, 0): {"type": RoomData.Type.MINION, "var": 2, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]}, Vector2i(0, 0): {"type": RoomData.Type.SPAWN, "var": 1, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT]}, Vector2i(1, 0): {"type": RoomData.Type.MINION, "var": 2, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]}, Vector2i(2, 0): {"type": RoomData.Type.TREASURE, "var": 1, "allowed_entrances": [Vector2i.LEFT]},
																   Vector2i(-2, 1): {"type": RoomData.Type.TREASURE, "var": 1, "allowed_entrances": [Vector2i.RIGHT, Vector2i.DOWN]}, Vector2i(-1, 1): {"type": RoomData.Type.PLATFORM, "var": 2, "allowed_entrances": [Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]},																																					  Vector2i(1, 1): {"type": RoomData.Type.PASSIVE, "var": 2, "allowed_entrances": [Vector2i.UP, Vector2i.DOWN]},
																   Vector2i(-2, 2): {"type": RoomData.Type.PLATFORM, "var": 2, "allowed_entrances": [Vector2i.RIGHT, Vector2i.UP]}, Vector2i(-1, 2): {"type": RoomData.Type.MINION, "var": 1, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]}, Vector2i(0, -2): {"type": RoomData.Type.MINION, "var": 1, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT]}, Vector2i(1, 2): {"type": RoomData.Type.MINION, "var": 3, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]},  Vector2i(2, 2): {"type": RoomData.Type.BOSS, "var": 1, "allowed_entrances": [Vector2i.LEFT]}
	}

func _get_level1_layout_2() -> Dictionary:
	return {
		Vector2i(0, -1): {"type": RoomData.Type.TREASURE, "var": 1, "allowed_entrances": [Vector2i.RIGHT]}, Vector2i(1, -1): {"type": RoomData.Type.MINION, "var": 2, "allowed_entrances": [Vector2i.LEFT, Vector2i.DOWN]},																															   Vector2i(3, -1): {"type": RoomData.Type.MINION, "var": 2, "allowed_entrances": [Vector2i.DOWN, Vector2i.RIGHT]}, Vector2i(4, -1): {"type": RoomData.Type.PLATFORM, "var": 2, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]}, Vector2i(5, -1): {"type": RoomData.Type.TREASURE, "var": 1, "allowed_entrances": [Vector2i.LEFT]}, 
		Vector2i(0, 0): {"type": RoomData.Type.SPAWN, "var": 1, "allowed_entrances": [Vector2i.RIGHT]}, Vector2i(1, 0): {"type": RoomData.Type.MINION, "var": 1, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]}, Vector2i(2, 0): {"type": RoomData.Type.PLATFORM, "var": 1, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT]}, Vector2i(3, 0): {"type": RoomData.Type.MINION, "var": 1, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]}, Vector2i(4, 0): {"type": RoomData.Type.PASSIVE, "var": 2, "allowed_entrances": [Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]},
																																																																																																																					Vector2i(4, 1): {"type": RoomData.Type.MINION, "var": 1, "allowed_entrances": [Vector2i.UP, Vector2i.RIGHT]}, Vector2i(5, 1): {"type": RoomData.Type.MINION, "var": 3, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT]}, Vector2i(6, -1): {"type": RoomData.Type.BOSS, "var": 1, "allowed_entrances": [Vector2i.LEFT]}
	}

func _get_level1_layout_3() -> Dictionary:
	return {
																										   Vector2i(0, 0): {"type": RoomData.Type.SPAWN, "var": 1, "allowed_entrances": [Vector2i.RIGHT]},  Vector2i(1, 0): {"type": RoomData.Type.MINION, "var": 3, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT]}, Vector2i(2, 0): {"type": RoomData.Type.MINION, "var": 2, "allowed_entrances": [Vector2i.LEFT, Vector2i.DOWN]},
																										   Vector2i(0, 1): {"type": RoomData.Type.TREASURE, "var": 1, "allowed_entrances": [Vector2i.DOWN]},
		Vector2i(-1, 2): {"type": RoomData.Type.MINION, "var": 1, "allowed_entrances": [Vector2i.RIGHT]},  Vector2i(0, 2): {"type": RoomData.Type.MINION, "var": 3, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]}, Vector2i(1, 2): {"type": RoomData.Type.MINION, "var": 2, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]}, Vector2i(2, 2): {"type": RoomData.Type.PASSIVE, "var": 1, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]}, Vector2i(3, 2): {"type": RoomData.Type.MINION, "var": 3, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT]}, Vector2i(4, 2): {"type": RoomData.Type.TREASURE, "var": 1, "allowed_entrances": [Vector2i.LEFT]},
																										   Vector2i(0, 3): {"type": RoomData.Type.BOSS, "var": 1, "allowed_entrances": [Vector2i.RIGHT]}, Vector2i(1, 3): {"type": RoomData.Type.MINION, "var": 1, "allowed_entrances": [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP]}, Vector2i(2, 3): {"type": RoomData.Type.MINION, "var": 3, "allowed_entrances": [Vector2i.LEFT]}
	}

## --- LEVEL 2 ---
#func _get_level2_layout_1() -> Dictionary:
	#return {
	#}
#
## --- LEVEL 3 ---
#func _get_level3_layout_1() -> Dictionary:
	#return {
	#}
#
## --- LEVEL 4 ---
#func _get_level4_layout_1() -> Dictionary:
	#return {
	#}
#
## --- LEVEL 5 ---
#func _get_level5_layout_1() -> Dictionary:
	#return {
	#}
