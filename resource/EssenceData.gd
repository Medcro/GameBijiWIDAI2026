# EssenceData.gd
class_name EssenceData
extends Resource

enum Type { ATTACK, MOVEMENT }

@export var name: String
@export var icon: Texture2D
@export var type: Type
@export var description: String
