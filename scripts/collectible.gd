extends Node2D

class_name Collectibles

# Need to expprt all the essences
@export var collectible_essence : Array[EssenceData] =[]

@onready var current_essence = pick_random_essence()
@onready var sp_essence: Control = $"../Player/Camera2D/CanvasLayer/SPEssence"

func pick_random_essence():
	return collectible_essence[randi_range(0,collectible_essence.size()-1)]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:

		for check_essence in sp_essence.collected_essences:
			if check_essence == current_essence:
				queue_free()
				return
		
		sp_essence.collected_essences.append(current_essence)
		print("Player has collected " + current_essence.name)
		
		queue_free()
