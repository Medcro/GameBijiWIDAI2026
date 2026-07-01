extends CharacterBody2D

class_name Player

# Base Attribute
@export var hp : int = 5
@export var speed : float = 300
@export var jump : float = -500
@export var gravity : float = 980 

# Dash Attribute
@export var dash_speed : float = 1200.0
@export var dash_duration : float = 0.07
@export var dash_cooldown : float = 0.5 # Variabel bebas (boleh diganti angkanya kalo rasanya kelamaan)
var dash_timer : float = 0.0 
var dash_cooldown_timer : float = 0.0 # init
var is_dashing : bool = false
var facing_direction : float = 1.0 # positif -> kanan, negatif -> kiri

# Health
var hearts_list : Array[TextureRect]
var health = 5
var alive : bool = true

# Melee Attack Attributes
@export var combo_window_duration : float = 0.4 # window buat 2-hit
@export var attack_cooldown : float = 0.35 # cooldown duh
var attack_cooldown_timer : float = 0.0
var is_attacking : bool = false
var combo_step : int = 0
var combo_window_timer : float = 0.0

# Parry Attributes
@export var parry_duration : float = 0.2 # parry frames
@export var parry_cooldown : float = 1 # cooldown klo whiff
var is_parrying : bool = false
var parry_timer : float = 0.0
var invincibility_timer : float = 0.0 # i-frames after parry
var is_damage_iframes : bool = false
var parry_cooldown_timer : float = 0.0

# Essence Attributes
@export var has_agility_essence : bool = false 
@export var has_flight_essence : bool = true 

var is_invincible : bool = false
var can_double_jump : bool = false
var collected_essences = []

# Player Resources
@export var max_dream : int = 100
var dream : int = 0:
	set(value):
		dream = clamp(value, 0, max_dream)
		if dream_bar:
			dream_bar.value = dream

# Nodes
@onready var _animated_sprite = $AnimatedSprite2D
@onready var weapon_pet = $Dreamcatcher
@onready var attack_hitbox = $AttackHitbox
@onready var parry_box = $ParryBox
@onready var dream_bar = $Camera2D/CanvasLayer/DreamBar
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")
@onready var floor_particle: GPUParticles2D = $floorParticle
@onready var player_hitbox: CollisionShape2D = $CollisionShape2D


var player_hitbox_run: float = -7.0
var player_hitbox_idle: float = 0.5
var _is_first_frame: bool = true
@onready var inventory = $Camera2D/CanvasLayer/SPEssence

#audio steps
@export var step_sounds: AudioStream
# Tentukan frame ke-berapa kaki menyentuh tanah (contoh: frame 1 dan 4)
@export var step_frames_walk: Array[int] = [1, 4] 
@onready var step_audio: AudioStreamPlayer2D = $stepAudio

func _ready() -> void:
	if "player_health" in SaveManager.game_data:
		health = SaveManager.game_data["player_health"]
	if "player_dream" in SaveManager.game_data:
		dream = SaveManager.game_data["player_dream"]
	if SaveManager.game_data["player_position"] != Vector2.ZERO:
		global_position = SaveManager.game_data["player_position"]
	#if "collected_essences" in SaveManager.game_data:
		#collected_essences = SaveManager.game_data["collected_essences"]
		#if has_node("Camera2D"):
			#$Camera2D.reset_smoothing() 
			#$Camera2D.force_update_scroll()
		#if has_node("Dreamcatcher"):
			#$Dreamcatcher.snap_to_target()
		
	var hearts_parent = get_node_or_null("Camera2D/CanvasLayer/HBoxContainer")
	if hearts_parent:
		for child in hearts_parent.get_children():
			hearts_list.append(child)
	
	update_heart_display()

	# no hitbox yet
	_set_hitbox_active(false)
	_set_parry_box_active(false)
	
	# signal buat parry
	parry_box.area_entered.connect(_on_parry_box_area_entered)
	
	# signal buat hit enemy
	if attack_hitbox is Area2D and not attack_hitbox.body_entered.is_connected(_on_attack_hitbox_body_entered):
		attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)
	
	# initialize Dream Bar
	if dream_bar:
		dream_bar.max_value = max_dream
		dream_bar.value = dream
	#call_deferred("snap_camera_and_pet")

func take_damage(amount: int):
	if is_invincible or not alive or is_parrying:
		return
	else:
		if health>0:
			health -= amount
			CameraEffects.shake(10.0, 0.1)
			#$node.play("damage")
			update_heart_display()
			is_invincible = true
			invincibility_timer = 1.5
			is_damage_iframes = true
			hit_flash()
		else:
			death()
	print("HP: ", health)

func hit_flash():
	var tween = create_tween()
	tween.tween_property(_animated_sprite, "modulate", Color(10, 10, 10, 1), 0.05)
	tween.tween_property(_animated_sprite, "modulate", Color.WHITE, 0.05)

func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i<health
		
	#if health == 1:
		#hearts_list[0].get_child(0).play("")
	#elif health > 1:
		#hearts_list[0].get_child(0).play("")
	if health <= 0:
		alive = false
		death()

func heal():
	# harusnya ada if dream bar disini si
	health += 1
	update_heart_display()
	#$node.play("heal")
	
func death():
	health == 0
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")
	#trigger game over scene

func _physics_process(delta: float) -> void:
	#if Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left"):
		#_animated_sprite.play("walk")
	#else:
		#_animated_sprite.play("default")
	if _is_first_frame:
		snap_camera_and_pet()
		_is_first_frame = false
		
	if Transition.is_transitioning:
		velocity.x = move_toward(velocity.x, 0, speed) # Hentikan jalan secara mulus
		
		# Tetap terapkan gravitasi agar player tidak melayang aneh jika transisi terpicu saat melompat
		if not is_on_floor():
			velocity.y += gravity * delta
			
		move_and_slide()
		state_machine.travel("Idle") # Paksa animasi diam
		return # Keluar dari fungsi agar input di bawah tidak dibaca
		
	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0 and not is_dashing and not is_attacking:
		facing_direction = sign(direction)
		attack_hitbox.scale.x = facing_direction
		_animated_sprite.scale.x = facing_direction * 0.249
		_animated_sprite.position.x = facing_direction * -9.88
		floor_particle.position.x = facing_direction * -53.0
		
		
	#if state_machine.get_current_node() == "fall":
		#state_machine.travel("endFall")

	# Invincibility delay (parry)
	if invincibility_timer > 0:
		invincibility_timer -= delta
		if is_damage_iframes:
			if int(invincibility_timer * 15) % 2 == 0:
				_animated_sprite.modulate.a = 0.3
			else:
				_animated_sprite.modulate.a = 1.0
			
		if invincibility_timer <= 0 and not is_dashing:
			is_invincible = false
			is_damage_iframes = false
			_animated_sprite.modulate.a = 1.0
	
	# Dash delay
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			is_invincible = false 
			dash_cooldown_timer = dash_cooldown
			
	if is_on_floor() and velocity.x != 0:
		floor_particle.emitting = true
	else:
		floor_particle.emitting = false
	
	if Input.is_action_just_pressed("Dash") and not is_dashing and dash_cooldown_timer <= 0:
		is_dashing = true
		dash_timer = dash_duration
		
		if has_agility_essence:
			is_invincible = true
			pass # add visual later
	
	# Melee delay
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta
	
	# Combo window
	if combo_window_timer > 0 and not is_attacking:
		combo_window_timer -= delta
		if combo_window_timer <= 0 or direction != 0:
			combo_step = 0
			combo_window_timer = 0.0
			attack_cooldown_timer = attack_cooldown
	
	if Input.is_action_just_pressed("Melee") and not is_dashing:
		perform_attack()
		
	# Parry cooldown delay
	if parry_cooldown_timer > 0:
		parry_cooldown_timer -= delta
	
	if is_parrying:
		parry_timer -= delta
		if parry_timer <= 0:
			# whiff
			is_parrying = false
			_set_parry_box_active(false)
			parry_cooldown_timer = parry_cooldown # cooldown parry
	
	if Input.is_action_just_pressed("Parry") and parry_cooldown_timer <= 0 and not is_dashing and not is_parrying and not is_damage_iframes:
		# attack cancel with parry
		if is_attacking:
			is_attacking = false
			combo_step = 0
			_set_hitbox_active(false)
			if weapon_pet:
				weapon_pet.show_after_attack()
				
		perform_parry()

	if is_on_floor():
		if direction != 0:
			state_machine.travel("run")
			player_hitbox.shape.size.x = 70.0
			player_hitbox.position.x = facing_direction * player_hitbox_run
			_play_step_sound()
		else:
			state_machine.travel("Idle")
			player_hitbox.shape.size.x = 55.0
			player_hitbox.position.x = facing_direction * player_hitbox_idle
		can_double_jump = true
	else:
		velocity.y += gravity * delta
		if velocity.y < 0:
			state_machine.travel("jump")
		else:
			state_machine.travel("fall")
		
		
	if Input.is_action_just_pressed("move_down") and is_on_floor():
		position.y += 1.2
		
	if Input.is_action_just_pressed("Jump") and not is_dashing and not is_attacking:
		if is_on_floor():
			velocity.y = jump
		elif can_double_jump and has_flight_essence:
			velocity.y = jump
			can_double_jump = false 
			CameraEffects.shake(5.0, 0.3)

	# Movement 
	if is_dashing:
		velocity.x = facing_direction * dash_speed
		velocity.y = 0 
	else:
		if direction:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()

func perform_attack() -> void:
	# biar g bisa spam
	if is_attacking or attack_cooldown_timer > 0:
		return 
		
	# check lgi combo ke-brp (stage 0 first hit)
	if combo_step == 0 or (combo_step == 1 and combo_window_timer > 0):
		is_attacking = true
		combo_step += 1
		combo_window_timer = 0.0 # timernya mati pas masih attack
		
		# hilangin dreamcatcher dulu
		if weapon_pet:
			weapon_pet.hide_for_attack()
		
		# nyalain hitbox
		_set_hitbox_active(true)
		
		# buat animasi, belum diimplement
		# if combo_step == 1:
		# 	_animated_sprite.play("attack_1")
		# elif combo_step == 2:
		# 	_animated_sprite.play("attack_2")
		
		# placeholder smpe ada animasi
		var fake_anim = "attack_1" if combo_step == 1 else "attack_2"
		$attack.play()
		_simulate_attack_delay(fake_anim)

func _set_hitbox_active(active: bool) -> void:
	for child in attack_hitbox.get_children():
			child.set_deferred("disabled", not active)

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body == self:
		return
	elif body.has_method("take_damage"):
		CameraEffects.shake(10.0, 0.05)
		body.take_damage(5)

# placeholder smpe ada animasi
func _simulate_attack_delay(anim_name: StringName) -> void:
	await get_tree().create_timer(0.3).timeout
	_on_animation_player_animation_finished(anim_name)

# connect ke signal 'animation_finished' nya AnimationPlayer nanti
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	_set_hitbox_active(false)
	
	if anim_name == "attack_1":
		is_attacking = false
		combo_window_timer = combo_window_duration # mulai combo window
		
		# munculin lagi dreamcatchernya
		if weapon_pet:
			weapon_pet.show_after_attack()
			
	elif anim_name == "attack_2":
		is_attacking = false
		combo_step = 0 # balik step 0 beres combo
		attack_cooldown_timer = attack_cooldown # start cooldown
		
		# munculin lagi dreamcatchernya
		if weapon_pet:
			weapon_pet.show_after_attack()

func perform_parry() -> void:
	is_parrying = true
	$parrystart.play()
	parry_timer = parry_duration
	_set_parry_box_active(true)
	
func _on_parry_box_area_entered(area: Area2D) -> void:
	if not is_parrying:
		return
		
	# serangan musuh yg masuk group ini bisa diparry
	if area.is_in_group("enemy_attack"):
		
		# klo unparryable
		if "is_unparryable" in area and area.is_unparryable:
			return
			
		trigger_parry_success()

func trigger_parry_success() -> void:
	is_parrying = false
	_set_parry_box_active(false)
	parry_cooldown_timer = 0.0 # instant parry reset (bisa mke lagI)
	
	var dream_gain = 20
	
	# Menambahkan jumlah dream yang didapat jika sedang mengequipped essence radiance
	if has_essence_equipped("Radiance"):
		dream_gain *= 1.25
	
	# buat nambahin dream
	dream += dream_gain
	
	# ksih iframe dikit habis parry
	is_invincible = true
	invincibility_timer = 0.5 
	
	is_damage_iframes = false 
	
	# camera shake after parry
	CameraEffects.shake(8.0, 0.2)
		
	# stopframe (i dotn reall know what this means so i just went with slow down)
	Engine.time_scale = 0.05 
	await get_tree().create_timer(0.1, true, false, true).timeout
	Engine.time_scale = 1.0
	
	$parry.play()

func _set_parry_box_active(active: bool) -> void:
	if parry_box:
		for child in parry_box.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", not active)

func prepare_for_room_change() -> void:
	SaveManager.game_data["player_health"] = health
	SaveManager.game_data["player_dream"] = dream
	#SaveManager.game_data["player_position"] = global_position
	
	SaveManager.game_data["current_level_num"] = LevelManager.current_level_num
	SaveManager.game_data["current_room_coords"] = LevelManager.current_room_coords
	SaveManager.game_data["current_scene_path"] = get_tree().current_scene.scene_file_path
	
	SaveManager.game_data["level_map_data"] = LevelManager.get_map_save_data()
	# Immediately lock the changes into memory/file
	SaveManager.save_game()

func snap_camera_and_pet() -> void:
	# 1. Paksa kamera berteleportasi secara bersih
	if has_node("Camera2D"):
		var cam = $Camera2D
		cam.global_position = global_position
		cam.reset_smoothing() 
		cam.force_update_scroll()
	# 2. Paksa Dreamcatcher berteleportasi
	if has_node("Dreamcatcher"):
		$Dreamcatcher.snap_to_target()
# Fungsi untuk mengecek apakah ada nama essence tertentu yang sedang terequip
func has_essence_equipped(essence_name: String) -> bool:
	if inventory == null:
		return false
	var equipped_essences = inventory.get_all_equipped_essences()
	
	for essence in equipped_essences:
		if essence != null and essence.name == essence_name:
			return true
			
	return false

func _play_step_sound() -> void:
	if (not step_sounds) or step_audio == null:
		return
	# Tambahkan pengecekan ini:
	if not step_audio.playing:
		step_audio.pitch_scale = randf_range(0.9, 1.2)
		step_audio.play()
