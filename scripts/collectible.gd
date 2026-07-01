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
	essence.texture = load(current_essence.icon)

func pick_random_essence(current_level : level):
	match current_level:
		level.ONE:
			return essence_level_one[randi_range(0,essence_level_one.size()-1)]
		level.TWO:
			return essence_level_two[randi_range(0,essence_level_two.size()-1)]

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:

		for check_essence in sp_essence.collected_essences:
			if check_essence == current_essence:
				queue_free()
				return
		
		sp_essence.collected_essences.append(current_essence)
		print("Player has collected " + current_essence.name)
		
		queue_free()
