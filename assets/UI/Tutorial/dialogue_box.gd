extends Control

@onready var text_node = $CanvasLayer/MarginContainer2/MarginContainer/Label
@onready var canvas_layer = $CanvasLayer
#@onready var talk_sound: AudioStreamPlayer = $Typewriter

# Different tutorial
var tutophase1: Array[Dictionary] = [
	{"text": "...Hello."},
	{"text": "I suppose we're together now."},
	{"text": "..."},
	{"text": "Well…"},
	{"text": "You picked me up."},
	{"text": "Surely you had a plan beyond that."},
	{"action": "wait_movement1"},
	{"action": "wait_movement2"},
	{"text": "Well done."},
	{"text": "Walking is an encouraging start."},
	{"text": "Now..."},
	{"text": "You'll have to jump."},
	{"action": "wait_jump"},
	{"text": "Excellent."},
	{"text": "You'll need more than a leisurely stroll."},
	{"text": "Go on."},
	{"action": "wait_dash"},
	{"text": "I may have underestimated you."},
	{"text": "...Slightly."},
	{"text": "Surely you brought a weapon."},
	{"text": "...No."},
	{"action": "spawn_mobu"},
	{"action": "wait_meleeattack"},
	{"text": "...Really?"},
	{"text": "Absolutely not, I am not designed for this."},
	{"action": "spawn_pippin"},
	{"action": "wait_parry"},
	{"text": "...It worked."},
	{"text": "...I dislike that it worked."},
	{"text": "I'd appreciate a little distance between us and the target."},
	{"text": "You may find this preferable..."},
	{"text": "...As will I."},
	{"action": "wait_rangeattack"},
	{"text": "See?"},
	{"text": "A more civilized method."},
	{"text": "Now, before you start flailing me at everything like a piece of toy…"},
	{"text": "Shouldn’t you at least make the effort to notice where you are?"}
]

var tutophase2: Array[Dictionary] = [
	{"text": "Remarkable, aren't you?"},
	{"text": "You've now understood every way to swing me."},
	{"text": "But, it's quite unfortunate you can't say the same about how to mend yourself."},
	{"action": "wait_heal"},
	{"text": "Do try not to die."},
	{"text": "You're terribly inconvenient to carry without a pulse."}
]

var tutophase3: Array[Dictionary] = [
	{"text": "I see that you've acquired some things."},
	{"text": "You should at least learn what they do. Don't your kind say ‘knowledge is key?"},
	{"action": "wait_inventory"},
	{"text": "You're carrying quite the untapped ability."},
	{"text": "I'd hate for all that effort to go unnoticed."}
]

var current_dialogue_list: Array[Dictionary] = []
var index_dialogue := 0
var wait_for_condition := false
var current_wait_action := ""
var keybind := ""

var chars_per_second := 50.0
var char_progress := 0.0
var is_typing := false
var last_visible_chars := 0
var target_visible_chars := 9999

var default_text_pos: Vector2

var tuto_enemy: Node2D = null
const MOBU_SCENE = preload("res://scenes/enemies/level1/mubu.tscn")

func _ready():
	canvas_layer.visible = false

#var typing_sounds := [
	#preload("res://assets/audio/Typewriter.ogg")
#]

# Built in func to start the tuto
func tutorial1():
	if not is_node_ready():
		await ready
	
	for door in get_tree().get_nodes_in_group("Doors"):
		if door.has_method("lock_room_door"):
			door.lock_room_door()
			print("found")
	await Transition.play_transition()
	canvas_layer.visible = true
	
	index_dialogue = 0
	#text_node.modulate.a = 1.0
	#default_text_pos = text_node.position
	#text_node.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	
	current_dialogue_list = tutophase1
	next_dialogue()
	
func tutorial2():
	canvas_layer.visible = true
	
	index_dialogue = 0
	#text_node.modulate.a = 1.0
	#default_text_pos = text_node.position
	text_node.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	
	current_dialogue_list = tutophase2
	next_dialogue()

func tutorial3():
	canvas_layer.visible = true
	
	index_dialogue = 0
	#text_node.modulate.a = 1.0
	#default_text_pos = text_node.position
	text_node.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	
	current_dialogue_list = tutophase3
	next_dialogue()

#func _play_random_typing_sound() -> void:
#	if talk_sound and typing_sounds.size() > 0:
#		var random_index = randi() % typing_sounds.size()
#		talk_sound.stream = typing_sounds[random_index]
#		talk_sound.play()

func _process(delta):
	if is_typing:
		char_progress += chars_per_second * delta
		var new_visible = int(char_progress)
		
		while last_visible_chars < new_visible:
			#_play_random_typing_sound()
			last_visible_chars += 1
		
		# buat blinky2 dot nya
		#if new_visible >= target_visible_chars:
			#text_node.visible_characters = -1
			#is_typing = false
		#else:
			#text_node.visible_characters = new_visible

func _input(event):
	if wait_for_condition:
		if current_wait_action == "wait_movement1":
			if event.is_action_pressed("move_left"):
				resume_dialogue()
		elif current_wait_action == "wait_movement2":
			if event.is_action_pressed("move_right"):
				resume_dialogue()
		elif current_wait_action == "wait_jump":
			if event.is_action_pressed("Jump"):
				resume_dialogue()
		elif current_wait_action == "wait_dash":
			if event.is_action_pressed("Dash"):
				resume_dialogue()
		elif current_wait_action == "wait_heal":
			if event.is_action_pressed("Heal"):
				resume_dialogue()
		elif current_wait_action == "wait_inventory":
			if event.is_action_pressed("EssenceTab"):
				resume_dialogue()
		elif current_wait_action == "wait_meleeattack":
			if event.is_action_pressed("EssenceTab"):
				resume_dialogue()
		return
	
	if not (event.is_action_pressed("Next Dialogue")): 
		return

	if is_typing:
		# munculin blinky2 dot klo beres
		text_node.visible_characters = -1
		is_typing = false
		return
	
	index_dialogue += 1
	next_dialogue()

func next_dialogue():
	if index_dialogue >= current_dialogue_list.size():
		canvas_layer.visible = false
		
		for door in get_tree().get_nodes_in_group("Doors"):
			if door.has_method("unlock_room_door"):
				door.unlock_room_door()
		
		return
	
	var current_line = current_dialogue_list[index_dialogue]
	if (current_line.has("action")):
		wait_for_action(current_line["action"])
		return
	if (current_line.has("text")):
		_show_dialogue(current_line["text"])

func wait_for_action(action_name: String):
	current_wait_action = action_name
	
	if action_name == "wait_movement1":
		wait_for_condition = true
		text_node.visible_characters = -1
		keybind = ControlSettings.get_keybind("Move Left")
		text_node.text = "Movement\n" + keybind
		
	elif action_name == "wait_movement2":
		wait_for_condition = true
		text_node.visible_characters = -1
		keybind = ControlSettings.get_keybind("Move Right")
		text_node.text = "Movement\n" + keybind
	
	elif action_name == "wait_jump":
		wait_for_condition = true
		text_node.visible_characters = -1
		keybind = ControlSettings.get_keybind("Jump")
		text_node.text = "Jump\n" + keybind
	
	elif action_name == "wait_dash":
		wait_for_condition = true
		text_node.visible_characters = -1
		keybind = ControlSettings.get_keybind("Dash")
		text_node.text = "Dash\n" + keybind
	
	elif action_name == "wait_meleeattack":
		wait_for_condition = true
		text_node.visible_characters = -1
		keybind = ControlSettings.get_keybind("Melee")
		text_node.text = "Dream Sweep\n" + keybind
		
		if is_instance_valid(tuto_enemy):
			tuto_enemy.tree_exited.connect(resume_dialogue)
		else:
			resume_dialogue()
	
	elif action_name == "wait_parry":
		wait_for_condition = true
		text_node.visible_characters = -1
		keybind = ControlSettings.get_keybind("Parry")
		text_node.text = "Parry\n" + keybind
	
	elif action_name == "wait_rangeattack":
		wait_for_condition = true
		text_node.visible_characters = -1
		keybind = ControlSettings.get_keybind("Ranged Attack")
		text_node.text = "Dream Cast\n" + keybind
	
	elif action_name == "wait_heal":
		wait_for_condition = true
		text_node.visible_characters = -1
		keybind = ControlSettings.get_keybind("Heal")
		text_node.text = "Heal\n" + keybind
	
	elif action_name == "wait_inventory":
		wait_for_condition = true
		text_node.visible_characters = -1
		keybind = "R"
		text_node.text = "Open Inventory\n" + keybind
	
	elif action_name == "spawn_mobu":
		var player = get_tree().get_first_node_in_group("Player") as Node2D
		player.is_invincible = true
		var new_mobu = MOBU_SCENE.instantiate()
		new_mobu.scale = Vector2(0.3, 0.3)
		new_mobu.player = player
		new_mobu.is_on_tuto = true
		new_mobu.global_position = player.global_position + Vector2(200, -25)
		tuto_enemy = new_mobu
		get_tree().current_scene.add_child(new_mobu)
		index_dialogue += 1
		next_dialogue()
	
	elif action_name == "spawn_pippin":
		var player = get_tree().get_first_node_in_group("Player") as Node2D
		player.is_invincible = true
		index_dialogue += 1
		next_dialogue()

# Call this if the condition is done
func resume_dialogue() -> void:
	if wait_for_condition:
		wait_for_condition = false
		index_dialogue += 1
		next_dialogue()

func _show_dialogue(text: String):
	# efek dot blinky2 thing at the end
	#text_node.modulate.a = 1.0
	text_node.text = text
	#text_node.visible_characters = 0
	
	char_progress = 0.0
	last_visible_chars = 0
	is_typing = false
	
	# biar ga glitchy2 ahh text
	#target_visible_chars = 9999
	await get_tree().process_frame
	#target_visible_chars = text_node.get_total_character_count() - 2
