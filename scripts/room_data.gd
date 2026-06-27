extends Resource
class_name RoomData

enum Type { SPAWN, PLATFORM, MINION, TREASURE, PASSIVE, BOSS }

var grid_position: Vector2i
var type: Type
var variation_id: int
var scene_path: String

## buat minimap
var is_discovered: bool = false
var is_cleared: bool = false

func _init(pos: Vector2i, t: Type) -> void:
	grid_position = pos
	type = t
