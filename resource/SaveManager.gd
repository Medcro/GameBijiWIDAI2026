extends Node

const SAVE_FILE_PATH = "user://savegame.dat"

var game_data : Dictionary = {
	"player_position": Vector2(-141.0, 156.0),
	"player_health" : 5,
	"player_dream" : 0,
	"collected_essences": [],
	
	"equipped_slot1": null,
	"equipped_slot2": null,
	"equipped_slot3": null,
	
	"has_collected_first_essence": false,
	
	"current_scene_path": "",
	"current_level_num": 1,
	"current_room_coords": Vector2i.ZERO,
	"level_map_data": {},
	"discovered_rooms": []
}

func save_game():
	# Buka file dalam mode WRITE (Menulis/Menimpa)
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_var(game_data, true)
		print("Game berhasil di-save!")
	else:
		print("Gagal nge-save game!")

func load_game() -> bool:
	# Cek apakah file savenya ada
	if FileAccess.file_exists(SAVE_FILE_PATH):
		# Buka dalam mode READ (Membaca)
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			# Tarik datanya dan timpa keranjang game_data kita
			var loaded_data = file.get_var(true)
			
			# Validasi opsional: pastikan data yang di-load bukan null
			if loaded_data != null:
				game_data = loaded_data
				print("Game berhasil di-load!")
				return true
				
	print("Belum ada save data.")
	return false

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_FILE_PATH)

func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(SAVE_FILE_PATH)
		print("Save file berhasil dihapus!")
		
func reset_and_delete_save() -> void:
	# 1. Hapus file fisiknya dari harddisk/penyimpanan perangkat
	delete_save() 
	
	# 2. Kembalikan isi keranjang game_data di RAM ke status awal (kosong)
	game_data = {
		"player_position": Vector2(-141.0, 156.0), 
		"player_health" : 5, 
		"player_dream" : 0, 
		"collected_essences": [], 
		"equipped_slot1": null,
		"equipped_slot2": null,
		"equipped_slot3": null,
		"has_collected_first_essence": false,
		"current_scene_path": "", 
		"current_level_num": 1, 
		"current_room_coords": Vector2i.ZERO, 
		"level_map_data": {}, 
		"discovered_rooms": [] 
	}
	print("Save data dihapus dan memori game_data telah di-reset!")

func reset_level() -> void:
	reset_and_delete_save()
	LevelManager.current_level_num = 1
	LevelManager.generate_new_level()
