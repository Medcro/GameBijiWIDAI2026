extends Area2D
class_name DoorBehavior

enum Direction { UP, DOWN, LEFT, RIGHT }
@export var door_direction: Direction
const META_USED := &"_door_used"

var is_valid_door: bool = false
var is_room_locked: bool = false

func _ready() -> void:
	var target_vector = _get_target_room_vector()
	
	if target_vector == Vector2i.ZERO:
		# NO ROOM FOUND (Or access blocked): Act as a wall
		
		# Since we now extend Area2D, we can call these directly!
		set_deferred("monitoring", false)
		set_deferred("monitorable", false)
			
		var wall_visual = get_node_or_null("WallVisual")
		var door_visual = get_node_or_null("DoorVisual")
		var wall_collision = get_node_or_null("WallCollision")
		
		if wall_visual: wall_visual.visible = true
		if door_visual: door_visual.visible = false
		if wall_collision: wall_collision.set_deferred("disabled", false)
	else:
		# ROOM FOUND & ACCESSIBLE: Act as a normal door
		var wall_visual = get_node_or_null("WallVisual")
		var door_visual = get_node_or_null("DoorVisual")
		var wall_collision = get_node_or_null("WallCollision")
		
		if wall_visual: wall_visual.visible = false
		if door_visual: door_visual.visible = true
		if wall_collision: wall_collision.set_deferred("disabled", true)

func lock_room_door() -> void:
	if not is_valid_door: return # Ignore if this is already a permanent wall
	
	is_room_locked = true
	var wall_collision = get_node_or_null("WallCollision")
	var door_visual = get_node_or_null("DoorVisual")
	
	if wall_collision: wall_collision.set_deferred("disabled", false) # Turn on physics
	if door_visual: door_visual.modulate = Color(1.0, 0.4, 0.4) # Tint the door red!

func unlock_room_door() -> void:
	if not is_valid_door: return 
	
	is_room_locked = false
	var wall_collision = get_node_or_null("WallCollision")
	var door_visual = get_node_or_null("DoorVisual")
	
	if wall_collision: wall_collision.set_deferred("disabled", true) # Turn off physics
	if door_visual: door_visual.modulate = Color(1, 1, 1) # Return to normal color

func _get_target_room_vector() -> Vector2i:
	var dir_vector: Vector2i = Vector2i.ZERO
	match door_direction:
		Direction.UP: dir_vector = Vector2i.UP
		Direction.DOWN: dir_vector = Vector2i.DOWN
		Direction.LEFT: dir_vector = Vector2i.LEFT
		Direction.RIGHT: dir_vector = Vector2i.RIGHT

	for distance in range(1, 3):
		var check_vector = dir_vector * distance
		var target_coords = LevelManager.current_room_coords + check_vector
		
		if LevelManager.current_map.has(target_coords):
			var target_room: RoomData = LevelManager.current_map[target_coords]
			
			# The side we are entering on the target room is the OPPOSITE of our travel direction
			# (e.g. If we travel DOWN, we enter through the target room's UP door)
			var entrance_side = -dir_vector
			
			if entrance_side in target_room.allowed_entrances:
				return check_vector
			else:
				# The room exists, but the door on this side is blocked off!
				# We return ZERO so we don't accidentally skip over it to find another room.
				return Vector2i.ZERO
				
	return Vector2i.ZERO

func _try_transition(owner_node: Node) -> void:
	var final_jump_vector = _get_target_room_vector()
	
	if final_jump_vector == Vector2i.ZERO:
		push_warning("Door points to a blocked room or empty space!")
		return

	owner_node.set_meta(META_USED, true)
	LevelManager.move_to_room(final_jump_vector)

#func save_state(owner_node: Node) -> Dictionary:

#func load_state(owner_node: Node, state: Dictionary) -> void:

func _on_body_entered(body: Node2D) -> void:
	if is_room_locked:
		return
	
	if body.is_in_group("Player"):
		_try_transition(self)
