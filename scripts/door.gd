extends Node
class_name DoorBehavior

enum Direction { UP, DOWN, LEFT, RIGHT }
@export var door_direction: Direction = Direction.RIGHT

@export var locked: bool = false
@export var auto_trigger: bool = true # Changed default to true for typical room borders
@export var one_shot: bool = false

const META_USED := &"_door_used"

func on_ready(owner: Node) -> void:
	if not owner.has_meta(META_USED):
		owner.set_meta(META_USED, false)

func on_player_entered(owner: Node, _player: Node) -> void:
	if auto_trigger:
		_try_transition(owner)

func on_interacted(owner: Node, _player: Node) -> void:
	if auto_trigger:
		return
	_try_transition(owner)

func _try_transition(owner: Node) -> void:
	if one_shot and bool(owner.get_meta(META_USED, false)):
		return

	# 1. Convert our Enum into a Vector2i coordinate direction
	var dir_vector: Vector2i = Vector2i.ZERO

	match door_direction:
		Direction.UP: dir_vector = Vector2i.UP       # (0, -1)
		Direction.DOWN: dir_vector = Vector2i.DOWN   # (0, 1)
		Direction.LEFT: dir_vector = Vector2i.LEFT   # (-1, 0)
		Direction.RIGHT: dir_vector = Vector2i.RIGHT # (1, 0)

	# 2. Safety Check: Verify the room exists in the LevelManager's map dictionary
	var target_coords = LevelManager.current_room_coords + dir_vector
	if not LevelManager.current_map.has(target_coords):
		push_warning("Door points to a grid coordinate that has no room generated!")
		return

	# 3. Trigger the transition!
	owner.set_meta(META_USED, true)
	LevelManager.move_to_room(dir_vector)

func save_state(owner: Node) -> Dictionary:
	return {"used": bool(owner.get_meta(META_USED, false))}

func load_state(owner: Node, state: Dictionary) -> void:
	owner.set_meta(META_USED, bool(state.get("used", false)))
