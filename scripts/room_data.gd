extends Resource
class_name RoomData

enum Type { SPAWN, PLATFORM, MINION, TREASURE, PASSIVE, BOSS }

var grid_position: Vector2i
var type: Type
var variation_id: int
var scene_path: String

var is_discovered: bool = false
var is_cleared: bool = false

var allowed_entrances: Array = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

func _init(pos: Vector2i, t: Type) -> void:
	grid_position = pos
	type = t
