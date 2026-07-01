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

	_spawn_player()
	
	if room_data.is_cleared:
		for enemy in enemies_in_room:
			if is_instance_valid(enemy):
				enemy.queue_free()
		enemies_in_room.clear()
	else:
		# kunci pintu dlu yh klo ada musuh
		if enemies_in_room.size() > 0:
			for door in doors_in_room:
				door.lock_room_door()
				
			# ksih signal buat musuh biar tau fungsi di sini tau kapan matinya
			for enemy in enemies_in_room:
				enemy.tree_exited.connect(_check_enemies)
		else:
			room_data.is_cleared = true

# fungsi rekursif nyari node yg musuh
func _scan_room_nodes(node: Node) -> void:
	for child in node.get_children():
		if child is DoorBehavior:
			doors_in_room.append(child)
			
		# klo bisa take_damage dia enemy, exclude player dari enemy
		elif child.has_method("take_damage") and not child.is_in_group("Player"):
			enemies_in_room.append(child)
			
		_scan_room_nodes(child)

func _check_enemies() -> void:
	if not is_inside_tree() or get_tree() == null:
		return
	
	await get_tree().process_frame
	
	# cek kehidupam
	var still_alive = false
	for enemy in enemies_in_room:
		if is_instance_valid(enemy) and not enemy.is_queued_for_deletion():
			still_alive = true
			break
			
	var room_data: RoomData = LevelManager.current_map.get(LevelManager.current_room_coords)
	if not room_data: return

	if not still_alive and not room_data.is_cleared:
		room_data.is_cleared = true # update shi
		
		# FREEDOM!
		for door in doors_in_room:
			door.unlock_room_door()

func _spawn_player() -> void:
	# ZERO artinya dari menu
	if LevelManager.target_entrance_vector == Vector2i.ZERO:
		return

	var player = get_tree().get_first_node_in_group("Player") as Node2D
	if not is_instance_valid(player):
		return

	for door in doors_in_room:
		if door.get_direction_vector() == LevelManager.target_entrance_vector:
			var offset_into_room = -door.get_direction_vector() * 120.0 #spawn player dengan offset 60 ke kiri/kanan/atas/bawah tergantung arah masuk
			player.global_position = door.global_position + Vector2(offset_into_room)
			break
