#taken from Descent's camera system
extends Camera2D

@export var bounds_path: NodePath

func _ready() -> void:
	if CameraEffects.has_method("register_camera"):
		CameraEffects.register_camera(self)
		
	_apply_bounds()

func _apply_bounds() -> void:
	if bounds_path == null or bounds_path.is_empty():
		return

	var bounds_body := get_node_or_null(bounds_path) as Node2D
	if bounds_body == null:
		return

	var cs := bounds_body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if cs == null or not (cs.shape is RectangleShape2D):
		push_warning("Camera Bounds: No valid RectangleShape2D found.")
		return

	var rect_shape := cs.shape as RectangleShape2D
	var ext: Vector2 = rect_shape.size * 0.5

	#Calculate rectangle limits in world space
	var center: Vector2 = cs.global_position
	var left: float = center.x - ext.x
	var right: float = center.x + ext.x
	var top: float = center.y - ext.y
	var bottom: float = center.y + ext.y

	#Apply to the Camera2D built-in limit properties
	limit_left = int(left)
	limit_right = int(right)
	limit_top = int(top)
	limit_bottom = int(bottom)

	#Enables smooth stopping when hitting the boundary
	limit_smoothed = true
