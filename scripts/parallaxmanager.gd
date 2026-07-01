extends Node
class_name ParallaxManager

@export var base_shift_per_room := Vector2(300, 150) # Tweak this to control how much the background shifts!

func _ready() -> void:
	# Wait a frame to ensure the scene is fully loaded
	await get_tree().process_frame
	
	var coords = LevelManager.current_room_coords
	
	# If we are at the center (0, 0), no shift is needed
	if coords == Vector2i.ZERO:
		return
		
	# Start searching from the root of the current room scene
	_shift_parallaxes(get_tree().current_scene, coords)

func _shift_parallaxes(node: Node, coords: Vector2i) -> void:
	for child in node.get_children():
		if child is Parallax2D:
			# Multiply the coordinate grid (e.g. 1, 0) by our base shift, 
			# THEN multiply by the node's scroll_scale so further backgrounds shift slower (preserving depth!)
			var final_shift = Vector2(coords) * base_shift_per_room * child.scroll_scale
			
			# Apply the shift
			child.scroll_offset += final_shift
			
		# Keep searching recursively down the tree
		_shift_parallaxes(child, coords)
