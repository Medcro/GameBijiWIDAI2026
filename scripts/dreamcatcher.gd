extends Node2D

@export var follow_speed: float = 8.0
@export var base_offset: Vector2 = Vector2(-30, -40) # Position relative to player
@export var float_speed: float = 5.0
@export var float_amount: float = 10.0

var player: Node2D
var is_attacking: bool = false
var time_passed: float = 0.0

func _ready() -> void:
	# Assume this node is a direct child of the Player
	player = get_parent() as Node2D
	
	# CRITICAL: This detaches the node's transform from the player.
	# This prevents it from instantly snapping to the player's position, 
	# allowing us to manually lerp it for that "lagging" effect.
	top_level = true 
	
	# Start instantly at the correct position so it doesn't fly in from (0,0)
	if player:
		global_position = player.global_position + base_offset

func _process(delta: float) -> void:
	if player == null:
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
	
	# biar smooth2 agak ngelag gitu
	global_position = global_position.lerp(target_pos, 1.0 - exp(-follow_speed * delta))

# ini buat melee attack, belum implement
#func hide_for_attack(duration: float = -1.0) -> void:
	#if is_attacking:
		#return
		#
	#is_attacking = true
	#visible = false # biar ilang pas animasi
	#
	## jaga2 buat animasi
	#if duration > 0:
		#await get_tree().create_timer(duration).timeout
		#show_after_attack()
#
## animasi beres munculin lgi
#func show_after_attack() -> void:
	#visible = true
	#is_attacking = false
