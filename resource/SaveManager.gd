extends Node

const SAVE_FILE_PATH = "user:/savegame.dat"

var	 game_data : Dictionary ={
	"player_position": Vector2.ZERO,
	"collected_essences": [],
	"current_path": "res://scenes/main.tscn"
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
