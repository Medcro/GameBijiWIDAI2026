extends Node2D
class_name RoomController

var enemies_in_room: Array[Node] = []
var doors_in_room: Array[DoorBehavior] = []

func _ready() -> void:
	await get_tree().process_frame

	var current_room_coords = LevelManager.current_room_coords
	var room_data: RoomData = LevelManager.current_map.get(current_room_coords)
	
	if not room_data: return

	# search the room for doors and enemies
	_scan_room_nodes(self)

	if room_data.is_cleared:
		for enemy in enemies_in_room:
			if is_instance_valid(enemy):
				enemy.queue_free()
		enemies_in_room.clear()
	else:
		# If this is a fresh room with enemies, lock the doors!
		if enemies_in_room.size() > 0:
			for door in doors_in_room:
				door.lock_room_door()
				
			# Attach a signal to every enemy so we know when they die/despawn
			for enemy in enemies_in_room:
				enemy.tree_exited.connect(_check_enemies)
		else:
			# If there are no enemies (e.g. passive room, spawn room), instantly mark it cleared
			room_data.is_cleared = true

# Recursively crawls through all children in the scene looking for specific nodes
func _scan_room_nodes(node: Node) -> void:
	for child in node.get_children():
		if child is DoorBehavior:
			doors_in_room.append(child)
			
		# Identify enemies based on the fact that they have health/damage logic 
		# (We exclude the player just in case they spawned in early)
		elif child.has_method("take_damage") and not child.is_in_group("player"):
			enemies_in_room.append(child)
			
		# Check this child's children too
		_scan_room_nodes(child)

# Called automatically whenever any enemy leaves the scene tree (via queue_free)
func _check_enemies() -> void:
	# Wait one frame to ensure the dead enemy is fully removed from memory
	await get_tree().process_frame
	
	# Verify if ANY enemies are still alive
	var still_alive = false
	for enemy in enemies_in_room:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			still_alive = true
			break
			
	var room_data: RoomData = LevelManager.current_map.get(LevelManager.current_room_coords)
	if not room_data: return

	# If everyone is dead and the room isn't already cleared...
	if not still_alive and not room_data.is_cleared:
		room_data.is_cleared = true # Update the minimap/save data
		
		# FREEDOM!
		for door in doors_in_room:
			door.unlock_room_door()
