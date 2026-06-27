extends Node2D

@export var follow_speed: float = 8.0
@export var return_speed: float = 25.0
@export var base_offset: Vector2 = Vector2(-30, -40)
@export var float_speed: float = 5.0
@export var float_amount: float = 10.0

var player: Node2D
var is_attacking: bool = false
var is_returning: bool = false
var time_passed: float = 0.0

func _ready() -> void:
	# Assume this node is a direct child of the Player
	player = get_parent() as Node2D
	
	# biar g snap ke player
	top_level = true 
	
	# offset dari player
	if player:
		global_position = player.global_position + base_offset

func _process(delta: float) -> void:
	if player == null:
		return
		
	if is_attacking:
		return
		
	time_passed += delta
	
	# efek floaty atas bawah
	var float_offset := Vector2(0, sin(time_passed * float_speed) * float_amount)
	
	# pindah2 sesuai facing
	var current_offset := base_offset
	if "facing_direction" in player:
		current_offset.x = base_offset.x * player.facing_direction
	
	# target ikutin player
	var target_pos: Vector2 = player.global_position + current_offset + float_offset
	
	var current_speed = return_speed if is_returning else follow_speed
	
	if is_returning and global_position.distance_to(target_pos) < 5.0:
		is_returning = false
	
	# biar smooth2 agak ngelag gitu
	global_position = global_position.lerp(target_pos, 1.0 - exp(-follow_speed * delta))

# ini buat melee attack
func hide_for_attack(duration: float = -1.0) -> void:
	if is_attacking:
		return
		
	is_attacking = true
	
	var tween = create_tween()
	tween.tween_property(self, "global_position", player.global_position, 0.05)
	await tween.finished
	
	visible = false # biar ilang pas animasi
	
	# jaga2 buat animasi
	if duration > 0:
		await get_tree().create_timer(duration).timeout
		show_after_attack()

# animasi beres munculin lgi
func show_after_attack() -> void:
	global_position = player.global_position
	visible = true
	is_returning = true
	is_attacking = false
	
func snap_to_target() -> void:
	if player == null:
		return
		
	var current_offset := base_offset
	if "facing_direction" in player:
		current_offset.x = base_offset.x * player.facing_direction
		
	# Langsung timpa posisi tanpa lerp
	global_position = player.global_position + current_offset
