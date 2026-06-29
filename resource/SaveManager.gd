extends Node

const SAVE_FILE_PATH = "user://savegame.dat"

var game_data : Dictionary = {
	"player_position": Vector2.ZERO,
	"player_health" : 5,
	"player_dream" : 0,
	"collected_essences": [],
	
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
		file.store_var(game_data)
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
			var loaded_data = file.get_var()
			
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
