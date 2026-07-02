extends Node2D

enum level {ONE, TWO}

# Change the enum based on the current level
@export var current_level : level

# Need to expprt all the essences
@export var essence_level_one : Array[EssenceData] =[]
@export var essence_level_two : Array[EssenceData] =[]

@onready var current_essence = pick_random_essence(current_level)
@onready var sp_essence: Control = $"../Player/Camera2D/CanvasLayer/SPEssence"
@onready var essence: Sprite2D = $Area2D/Essence

func _ready() -> void:
	essence.texture = current_essence.icon

func pick_random_essence(current_level : level):
	match current_level:
		level.ONE:
			return essence_level_one[randi_range(0,essence_level_one.size()-1)]
		level.TWO:
			return essence_level_two[randi_range(0,essence_level_two.size()-1)]

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
