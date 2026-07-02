extends Node2D

class_name Collectibles

# Need to expprt all the essences
@export var collectible_essence : Array[EssenceData] =[]

@onready var current_essence = pick_random_essence()
@onready var sp_essence: Control = $"../Player/Camera2D/CanvasLayer/SPEssence"

func pick_random_essence():
	return collectible_essence[randi_range(0,collectible_essence.size()-1)]

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("entered: ", body.name)
	if body is Player:
		print("player entered")
		for check_essence in sp_essence.collected_essences:
			if check_essence == current_essence:
				queue_free()
				return
		
		sp_essence.collected_essences.append(current_essence)
		print("Player has collected " + current_essence.name)
		if not SaveManager.game_data.has("collected_essences"):
			SaveManager.game_data["collected_essences"] = []
		SaveManager.game_data["collected_essences"].append(current_essence)
		
		if SaveManager.game_data.has("has_collected_first_essence") and SaveManager.game_data["has_collected_first_essence"] == false:
			# Langsung ubah jadi true agar tutorial tidak muncul lagi di item berikutnya
			SaveManager.game_data["has_collected_first_essence"] = true
			
			# PANGGIL FUNGSI TUTORIALMU DI SINI
			print("TUTORIAL MUNCUL: Selamat! Kamu mendapatkan Essence pertama. Tekan R untuk membuka menu.")
			DialogueBox.tutorial3()
			# (Contoh jika kamu punya node TutorialManager: )
			# var tutorial = get_tree().get_first_node_in_group("TutorialManager")
			# if tutorial: tutorial.show_essence_tutorial()
		SaveManager.save_game()
		queue_free()
