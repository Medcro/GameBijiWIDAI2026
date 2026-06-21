#extends Node
#
### buat minimap
##signal map_updated
#
#signal level_changed(new_level: int)
#
## --- room files dictionary ---
#const LEVEL_ROOM_SCENES = {
	#1: {
		#RoomData.Type.SPAWN: ["res://scenes/rooms/level1/spawn_var_1.tscn"],
		#RoomData.Type.PLATFORM: ["res://scenes/rooms/level1/platform_var_1.tscn"],
		#RoomData.Type.MINION: ["res://scenes/rooms/level1/minion_var_1.tscn"],
		#RoomData.Type.TREASURE: ["res://scenes/rooms/level1/treasure_var_1.tscn"],
		#RoomData.Type.PASSIVE: ["res://scenes/rooms/level1/passive_var_1.tscn"],
		#RoomData.Type.BOSS: ["res://scenes/rooms/level1/boss_var_1.tscn"]
	#},
	#2: { #beda sendiri cok i guess bro
		#RoomData.Type.SPAWN: ["res://scenes/rooms/level2/spawn_var_1.tscn", "res://scenes/rooms/level2/spawn_var_2.tscn"],
		#RoomData.Type.PLATFORM: ["res://scenes/rooms/level2/platform_var_1.tscn", "res://scenes/rooms/level2/platform_var_2.tscn", "res://scenes/rooms/level2/platform_var_3.tscn", "res://scenes/rooms/level2/platform_var_4.tscn", "res://scenes/rooms/level2/platform_var_5.tscn"],
		#RoomData.Type.MINION: ["res://scenes/rooms/level2/minion_var_1.tscn", "res://scenes/rooms/level2/minion_var_2.tscn", "res://scenes/rooms/level2/minion_var_3.tscn", "res://scenes/rooms/level2/minion_var_4.tscn", "res://scenes/rooms/level2/minion_var_5.tscn", "res://scenes/rooms/level2/minion_var_6.tscn", "res://scenes/rooms/level2/minion_var_7.tscn"],
		#RoomData.Type.TREASURE: ["res://scenes/rooms/level2/treasure_var_1.tscn", "res://scenes/rooms/level2/treasure_var_2.tscn"],
		#RoomData.Type.PASSIVE: ["res://scenes/rooms/level2/passive_var_1.tscn", "res://scenes/rooms/level2/passive_var_2.tscn"],
		#RoomData.Type.BOSS: ["res://scenes/rooms/level2/boss_var_1.tscn", "res://scenes/rooms/level2/boss_var_2.tscn"]
	#},
	#3: {
		#RoomData.Type.SPAWN: ["res://scenes/rooms/level3/spawn_var_1.tscn"],
		#RoomData.Type.PLATFORM: ["res://scenes/rooms/level3/platform_var_1.tscn"],
		#RoomData.Type.MINION: ["res://scenes/rooms/level3/minion_var_1.tscn"],
		#RoomData.Type.TREASURE: ["res://scenes/rooms/level3/treasure_var_1.tscn"],
		#RoomData.Type.PASSIVE: ["res://scenes/rooms/level3/passive_var_1.tscn"],
		#RoomData.Type.BOSS: ["res://scenes/rooms/level3/boss_var_1.tscn"]
	#},
	#4: {
		#RoomData.Type.SPAWN: ["res://scenes/rooms/level4/spawn_var_1.tscn"],
		#RoomData.Type.PLATFORM: ["res://scenes/rooms/level4/platform_var_1.tscn"],
		#RoomData.Type.MINION: ["res://scenes/rooms/level4/minion_var_1.tscn"],
		#RoomData.Type.TREASURE: ["res://scenes/rooms/level4/treasure_var_1.tscn"],
		#RoomData.Type.PASSIVE: ["res://scenes/rooms/level4/passive_var_1.tscn"],
		#RoomData.Type.BOSS: ["res://scenes/rooms/level4/boss_var_1.tscn"]
	#},
	#5: {
		#RoomData.Type.SPAWN: ["res://scenes/rooms/level5/spawn_var_1.tscn"],
		#RoomData.Type.PLATFORM: ["res://scenes/rooms/level5/platform_var_1.tscn"],
		#RoomData.Type.MINION: ["res://scenes/rooms/level5/minion_var_1.tscn"],
		#RoomData.Type.TREASURE: ["res://scenes/rooms/level5/treasure_var_1.tscn"],
		#RoomData.Type.PASSIVE: ["res://scenes/rooms/level5/passive_var_1.tscn"],
		#RoomData.Type.BOSS: ["res://scenes/rooms/level5/boss_var_1.tscn"]
	#}
#}
#
## map level yang sekarang dipakai
#var current_map: Dictionary = {}
## sistemnya basically kayak matriks, di kolom x row y ada room apa ditentuin nnti sama func _get_leveln_layoutz
#var current_room_coords: Vector2i = Vector2i.ZERO
#
#var current_level_num: int = 1
#var max_levels: int = 5 # woah 5 level yh
#
#func _ready() -> void:
	#generate_new_level()
#
#func generate_new_level() -> void:
	#current_map.clear()
	#
	#var layouts = []
	#
	## inisialisasi layout level
	#if current_level_num == 1:
		#layouts = [_get_level1_layout_1(), _get_level1_layout_2(), _get_level1_layout_3()]
	##elif current_level_num == 2:
		##layouts = [_get_level2_layout_1(), _get_level2_layout_2(), _get_level2_layout_3()]
	##elif current_level_num == 3:
		##layouts = [_get_level3_layout_1(), _get_level3_layout_2(), _get_level3_layout_3()]
	##elif current_level_num == 4:
		##layouts = [_get_level4_layout_1(), _get_level4_layout_2(), _get_level4_layout_3()]
	##elif current_level_num == 5:
		##layouts = [_get_level5_layout_1()]
	#
	## pilih layout
	#var chosen_layout: Dictionary = layouts.pick_random()
	#
	## fetch room pool based on level
	#var level_pool = LEVEL_ROOM_SCENES.get(current_level_num, LEVEL_ROOM_SCENES[1])
	#
	## build the level
	#for coords in chosen_layout:
		#var layout_data = chosen_layout[coords]
		#
		#var type = layout_data["type"]
		#var room = RoomData.new(coords, type)
		#
		#var available_scenes = level_pool[type]
		#var chosen_scene = ""
		#
		## If the layout dictates a specific variation (e.g. Var 3 for a 3-way split), use it!
		#if typeof(layout_data) == TYPE_DICTIONARY and layout_data.has("var"):
			#var target_var = layout_data["var"]
			#
			## Safety check: Ensure we actually have that variation loaded in the array
			#if target_var > 0 and target_var <= available_scenes.size():
				#room.variation_id = target_var
				#chosen_scene = available_scenes[target_var - 1] # Array is 0-indexed, Variation is 1-indexed
			#else:
				#push_warning("Variation " + str(target_var) + " missing for " + str(RoomData.Type.keys()[type]) + ". Falling back to random.")
				#chosen_scene = available_scenes.pick_random()
				#room.variation_id = available_scenes.find(chosen_scene) + 1
		#else:
			## Fallback to random if no specific variation was requested
			#chosen_scene = available_scenes.pick_random()
			#room.variation_id = available_scenes.find(chosen_scene) + 1 
			#
		#room.scene_path = chosen_scene
		#current_map[coords] = room
		#
		#if type == RoomData.Type.SPAWN:
			#current_room_coords = coords
#
	## 3. Enter the spawn room
	#enter_room(current_room_coords)
#
	## 3. Enter the spawn room
	#enter_room(current_room_coords)
#
#func move_to_room(direction: Vector2i) -> void:
	#var target_coords = current_room_coords + direction
	#
	#if current_map.has(target_coords):
		#enter_room(target_coords)
	#else:
		#push_warning("Attempted to move to a room that doesn't exist!")
#
#func enter_room(coords: Vector2i) -> void:
	#current_room_coords = coords
	#var room: RoomData = current_map[coords]
	#room.is_discovered = true
	#
	##map_updated.emit()
	#
	## get_tree().change_scene_to_file(room.scene_path)
	#print("Entered Room: ", RoomData.Type.keys()[room.type], " | Var: ", room.variation_id)
#
## --- UPGRADE 2: Progression & Transition Logic ---
#func complete_level() -> void:
	#print("Boss defeated! Level ", current_level_num, " complete.")
	#
	#if current_level_num < max_levels:
		## 1. Change to the cutscene instead of generating the level instantly
		## Make sure you have a cutscene scene created!
		#print("Transitioning to cutscene...")
		## get_tree().change_scene_to_file("res://scenes/cutscene.tscn")
	#else:
		#print("Final Level Complete! You Win!")
		## get_tree().change_scene_to_file("res://scenes/credits.tscn")
#
## The Cutscene scene will call this function when it finishes playing
#func start_next_level() -> void:
	#current_level_num += 1
	#level_changed.emit(current_level_num)
	#generate_new_level()
#
## ==========================================
## --- LAYOUT LEVELS ---
## ==========================================
#
## --- LEVEL 1 ---
#func _get_level1_layout_1() -> Dictionary:
	#return{
	#}
#
#func _get_level1_layout_2() -> Dictionary:
	#return{
	#}
#
#func _get_level1_layout_3() -> Dictionary:
	#return{
	#}	
#
### --- LEVEL 2 ---
##func _get_level2_layout_1() -> Dictionary:
	##return {
	##}
##
### --- LEVEL 3 ---
##func _get_level3_layout_1() -> Dictionary:
	##return {
	##}
##
### --- LEVEL 4 ---
##func _get_level4_layout_1() -> Dictionary:
	##return {
	##}
##
### --- LEVEL 5 ---
##func _get_level5_layout_1() -> Dictionary:
	##return {
	##}
