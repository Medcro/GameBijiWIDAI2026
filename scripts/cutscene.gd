# based on Descent's cutscene system
extends Control

@onready var bg_nodes := [
	get_node_or_null("CanvasLayer/Backgrounds/BG_0"),
	get_node_or_null("CanvasLayer/Backgrounds/BG_1"),
	get_node_or_null("CanvasLayer/Backgrounds/BG_2"),
	get_node_or_null("CanvasLayer/Backgrounds/BG_3"),
	get_node_or_null("CanvasLayer/Backgrounds/BG_4"),
	get_node_or_null("CanvasLayer/Backgrounds/BG_5"),
	get_node_or_null("CanvasLayer/Backgrounds/BG_6"),
	get_node_or_null("CanvasLayer/Backgrounds/BG_7"),
	get_node_or_null("CanvasLayer/Backgrounds/BG_8"),
	get_node_or_null("CanvasLayer/Backgrounds/BG_9")
]

@onready var text_node: RichTextLabel = $CanvasLayer/Text
@onready var fade_node = $CanvasLayer/Fade
@onready var anime: AnimationPlayer = $AnimationPlayer
@onready var talk_sound: AudioStreamPlayer = $Typewriter
@onready var skip: Label = $CanvasLayer/skip

# "fade_bg": true -> fade dari gambar sebelumnya
# "blackout": true -> fade to black terus text nya di tengah
# "fade_out_after": true -> fade to black end cutscene

const CUTSCENE_DATA = {
	"intro": [
		{"text": "Another day, another pile of work that needs doing.", "bg": 0},
		{"text": "You wake up, you go to work for a few hours, go back to your apartment, sleep, repeat.", "bg": 0},
		{"text": "While everyone else is busy packing up and planning their evenings…", "bg": 0},
		{"text": "You're at your desk, still finishing up work.", "bg": 0},
		{"text": "It's a dreary and dull cycle, but you don't really belong anywhere else.", "bg": 0},
		{"text": "There's always more work that you could be finishing.", "bg": 0},
		{"text": "After all, they're always counting on you to do it.", "bg": 0},
		
		{"text": "It wasn't always like this, was it?", "bg": 1},
		{"text": "When you were little, you'd lose hours sitting in front of a screen, watching Let's Play videos.", "bg": 1},
		{"text": "You liked having fun, and you had fun watching other people have fun.", "bg": 1},
		{"text": "All those videos shaped a humble dream.", "bg": 1},
		{"text": "You wanted to own a complete, powerful gaming setup and lose yourself in virtual worlds, like your favorite creators did.", "bg": 1},
		
		{"text": "But growing up stole your time...", "bg": 1}, 
		{"text": "…and eventually, that childhood dream was ultimately buried under a mountain of corporate responsibilities.", "bg": 2, "fade_bg": true}, 
		
		{"text": "One evening...", "bg": 99, "blackout": true}, # make sure pilih BG yang kosong
		{"text": "While walking home from the station, a dreamcatcher by a small shop's window catches your eye.", "bg": 3},
		{"text": "You didn't know what drove you to buy it.", "bg": 3},
		{"text": "However...", "bg": 3},
		
		{"text": "That night, the artifact would awaken, emitting a magical light that pulls you into a vivid dreamscape.", "bg": 4, "fade_bg": true},
		{"text": "As you fall deeper into sleep, the dream forms, and your journey begins….", "bg": 4, "fade_out_after": true} 
	],
	"level_1_end": [
		{"text": "Despite the struggle that you experienced, you managed to triumph over the dream", "bg": 5},
		{"text": "The victory rings in your mind, hooking it onto your soul, bringing happiness to your face.", "bg": 6},
		{"text": "In front of you, there is a bright light that appears as if the dream is guiding you towards it.", "bg": 7},
		{"text": "As you enter the light...", "bg": 7},
		{"text": "You wake up in the daytime.", "bg": 8},
		{"text": "A new sense of determination seems to have filled you.", "bg": 8},
		{"text": "For once, you're ready to face the usual routine with a smile.", "bg": 8},
	],
	"level_2_end": [
		{"text": "Another dream.", "bg": 7},
		{"text": "You began to realize what all this madness is about.", "bg": 7},
		{"text": "You remembered seeing these digital worlds somewhere.", "bg": 7},
		{"text": "Worlds you longed to lose yourself in.", "bg": 7},
		{"text": "Confusion existed, yet a sense of euphoria began clouding your mind.", "bg": 9},
		{"text": "Past victories made you forget more about your stressful real life.", "bg": 9},
		{"text": "The feeling is as fascinating as it was addictive, a feeling you didn't have whenever you worked in that job.", "bg": 9},
		{"text": "High on this feeling, you’re determined to experience more dreams and decide to march onwards towards the light once more.", "bg": 7},
		{"text": "You wake up in the daytime.", "bg": 99},
		{"text": "Once again, you're put back to your usual routine.", "bg": 8},
		{"text": "But this time, a slight anticipation to sleep and pursue more of these dreams lingers.", "bg": 8}
	],
		"level_3_end": [
		{"text": "Completing a dream didn’t feel like an accomplishment anymore, it felt like a burden waiting to ruin your day.", "bg": 10},
		{"text": "If it weren't for the people around you needing you to stay past hours to help with their work...", "bg": 10},
		{"text": "You would've already rushed back home to that dreamscape again.", "bg": 10},
		{"text": "As you grit your teeth, your leg unstoppably shaking underneath, you can't wait to get home.", "bg": 10},
		{"text": "The dream was as usual, addicting and dangerous.", "bg": 7},
		{"text": "Your soul was practically on fire, you did not want to wake up", "bg": 7},
		{"text": "Suddenly returning to reality sounds more like torture you dreaded.", "bg": 7},
		{"text": "But alas, the light still approached you, waking you up to reality..", "bg": 7},
		{"text": "It took everything in you to not sleep in again, and you would've if not for your colleagues calling you.", "bg": 8},
		{"text": "With a grumble, you went to work.", "bg": 99}
	],
		"level_4_end": [
		{"text": "A sudden realization came to mind.", "bg": 11},
		{"text": "These dreams, this dreamcatcher...", "bg": 11},
		{"text": "It's trying to show you something.", "bg": 11},
		{"text": "It's trying to make you realize...", "bg": 11},
		{"text": "You've stopped enjoying your life for yourself, instead running away every night to some dream where you're actually happy.", "bg": 11},
		{"text": "When was the last time you did things for yourself?", "bg": 99, "blackout": true},
		{"text": "You woke up feeling cold and dreadful.", "bg": 8},
		{"text": "You feel ridiculous, as even with this realization you couldn't muster up the courage to ask for a day off.", "bg": 8},
		{"text": "Instead, you've decided to force yourself to come to work late.", "bg": 8},
		{"text": "Your train of thought died when your colleagues called your phone, you frantically ran to work.", "bg": 99}
	],
	"outro": [
		{"text": "Gazing upon the larger dream version of yourself, you find yourself not recognizing that stranger.", "bg": 12},
		{"text": "It has your face, but it looks like a corpse.", "bg": 12},
		{"text": "You don't know what's more terrifying, that being how you feel on the inside, or that being how you look now.", "bg": 12},
		{"text": "Depressed, stressed, and dead inside.", "bg": 12},
		{"text": "You woke up in a gasp after defeating it, cold sweat falling down your face.", "bg": 8},
		{"text": "That battle was on your mind the whole day, while you prepared to work and both at work.", "bg": 8},
		{"text": "Is that how you look like now?", "bg": 13},
		{"text": "Exhausted, dragging yourself around the office by their pleas and commands?", "bg": 13},
		{"text": "Has this way of living made you be like that the whole time?", "bg": 13},
		{"text": "Has this job sucked the life, soul, and dream out of your days?", "bg": 13},
		{"text": "And if it has, do you really want to continue living like this?", "bg": 13},
		{"text": " ", "bg": 99, "blackout": true},
		{"text": "Your train of thought was stopped by a colleague, asking for your help on god knows what for what it feels like the 50th amount of time that week.", "bg": 14},
		{"text": "It's like the universe knew, and gave you a chance by testing your determination.", "bg": 14},
		{"text": "Maybe, it's time to change", "bg": 14},
		{"text": "This time you stood up from your chair and stared at the clock.", "bg": 14},
		{"text": "You said it, something along the lines of it being late and your office hours are over.", "bg": 14},
		{"text": "You expected a sneer or anger, but you never expected a smile and a pat on the back.", "bg": 14},
		{"text": "“That's alright, I'll ask someone else.”", "bg": 14},
		{"text": "You were dazed the whole walk back, your eyes catching the glint of the discounted gaming set you always saw on your way home.", "bg": 15},
		{"text": "Next thing you know, you brought it home.", "bg": 15},
		{"text": "That night you finally slept soundly and dreamless. Ever since that day, the dreams left your world completely.", "bg": 15},
		{"text": "Ever since that day, the dreams left your world completely.", "bg": 15},
		{"text": "But now, your reality isn't looking as bad either.", "bg": 99, "blackout": true}
	]
}

var current_dialog_list = []
var index_dialog := 0

var is_skipping := false
var input_locked := false

var chars_per_second := 50.0
var char_progress := 0.0
var is_typing := false
var last_visible_chars := 0
var target_visible_chars := 9999

var current_bg_idx: int = -1
var default_text_pos: Vector2

var typing_sounds := [
	preload("res://assets/audio/Typewriter.ogg")
]

func _ready():
	text_node.bbcode_enabled = true
	text_node.modulate.a = 1.0
	default_text_pos = text_node.position
	
	text_node.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	
	fade_node.visible = true
	fade_node.modulate.a = 1.0
	fade_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var start_tween = create_tween()
	start_tween.tween_property(fade_node, "modulate:a", 0.0, 1.5)
	start_tween.finished.connect(func(): fade_node.visible = false)
		
	skip.modulate.a = 0.0 

	if anime and anime.has_signal("animation_finished"):
		anime.animation_finished.connect(_on_anim_finished)
		
	# pilih cutscene
	var target_id = LevelManager.target_cutscene
	if target_id == "":
		target_id = "intro"
		LevelManager.target_cutscene = "intro"
		
	if CUTSCENE_DATA.has(target_id):
		current_dialog_list = CUTSCENE_DATA[target_id]
	else:
		current_dialog_list = [{"text": "...", "bg": 0}] 
		
	run_cutscene()

	# tombol skip muncul beres 2 detik
	get_tree().create_timer(2.0).timeout.connect(_start_skip_pulse)

func _play_random_typing_sound() -> void:
	if talk_sound and typing_sounds.size() > 0:
		var random_index = randi() % typing_sounds.size()
		talk_sound.stream = typing_sounds[random_index]
		talk_sound.play()

func _process(delta):
	if is_typing:
		char_progress += chars_per_second * delta
		var new_visible = int(char_progress)
		
		while last_visible_chars < new_visible:
			_play_random_typing_sound()
			last_visible_chars += 1
		
		# buat blinky2 dot nya
		if new_visible >= target_visible_chars:
			text_node.visible_characters = -1
			is_typing = false
		else:
			text_node.visible_characters = new_visible

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		skip_cutscene()
		return

	if input_locked: return

	if not (event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed)): return

	if is_typing:
		# munculin blinky2 dot klo beres
		text_node.visible_characters = -1
		is_typing = false
		return

	if anime.is_playing() and anime.current_animation != "last_cutscene":
		anime.speed_scale = 5.0
		await get_tree().create_timer(0.1).timeout
		anime.speed_scale = 1.0
	
	index_dialog += 1
	run_cutscene()

func run_cutscene():
	if index_dialog >= current_dialog_list.size():
		finish_cutscene()
		return
		
	_show_dialog(current_dialog_list[index_dialog])

func _show_dialog(dialog_data: Dictionary):
	var text = dialog_data.get("text", "")
	var bg_idx = dialog_data.get("bg", 0)
	var do_fade_bg = dialog_data.get("fade_bg", false)
	var do_blackout = dialog_data.get("blackout", false)
	
	_update_background(bg_idx, do_fade_bg)
	
	if do_blackout:
		var screen_center_y = get_viewport_rect().size.y / 2.0
		text_node.position.y = screen_center_y - (text_node.size.y / 2.0)
	else:
		text_node.position.y = default_text_pos.y
	
	# efek dot blinky2 thing at the end
	text_node.modulate.a = 1.0
	text_node.bbcode_text = "[center]" + text + "[pulse freq=4.0 color=#ffffff00] •[/pulse][/center]"
	text_node.visible_characters = 0
	
	char_progress = 0.0
	last_visible_chars = 0
	is_typing = true
	
	# biar ga glitchy2 ahh text
	target_visible_chars = 9999
	await get_tree().process_frame
	target_visible_chars = text_node.get_total_character_count() - 2

	# Fade in masuk
	if index_dialog == 0 and anime.has_animation("opening_cutscene"):
		anime.play("opening_cutscene")
	elif anime.has_animation("cutscenes"):
		anime.play("cutscenes")

func _update_background(idx: int, do_fade: bool = false) -> void:
	if bg_nodes.is_empty(): return
	if current_bg_idx == idx: return

	for i in range(bg_nodes.size()):
		var bg = bg_nodes[i]
		if bg == null: continue
		
		if i == idx:
			bg.visible = true
			if do_fade:
				bg.modulate.a = 0.0
				create_tween().tween_property(bg, "modulate:a", 1.0, 1.0)
			else:
				bg.modulate.a = 1.0
				
			if "texture" in bg and bg.texture is AnimatedTexture:
				bg.texture.pause = false 
				bg.texture.current_frame = 0 
		else:
			if bg.visible:
				if do_fade:
					var tween = create_tween()
					tween.tween_property(bg, "modulate:a", 0.0, 1.0)
					# Ensure the correct node is targeted in the callback
					tween.finished.connect(func(node=bg):
						node.visible = false
						if "texture" in node and node.texture is AnimatedTexture:
							node.texture.pause = true
					)
				else:
					bg.visible = false
					if "texture" in bg and bg.texture is AnimatedTexture:
						bg.texture.pause = true

	current_bg_idx = idx

func finish_cutscene():
	input_locked = true
	
	var last_dialog = current_dialog_list.back()
	
	# Cek ada tag nya
	if last_dialog is Dictionary and last_dialog.get("fade_out_after", false):
		if fade_node:
			fade_node.visible = true
			fade_node.modulate.a = 0.0
			var tween = create_tween()
			tween.tween_property(fade_node, "modulate:a", 1.0, 1.5)
			tween.finished.connect(_end_scene)
		else:
			_end_scene()
		return
		
	if anime.has_animation("last_cutscene"):
		anime.play("last_cutscene")
	else:
		_end_scene()

func _on_anim_finished(anim_name):
	if anim_name == "last_cutscene":
		_end_scene()

func skip_cutscene() -> void:
	if is_skipping: return
	is_skipping = true
	input_locked = true
	
	if anime: anime.stop()
	if talk_sound: talk_sound.stop()
	
	_end_scene()

func _end_scene() -> void:
	# Intro -> Main Menu
	if LevelManager.target_cutscene == "intro":
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	else:
		# Level End -> Next Level
		LevelManager.proceed_from_cutscene()

func _start_skip_pulse() -> void:
	if skip == null: return
	
	var initial_tween = create_tween()
	initial_tween.tween_property(skip, "modulate:a", 0.2, 1.5).set_trans(Tween.TRANS_SINE)
	initial_tween.finished.connect(_pulse_skip)

func _pulse_skip() -> void:
	if skip == null: return
	var tween = create_tween().set_loops() 
	tween.tween_property(skip, "modulate:a", 0.8, 1.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(skip, "modulate:a", 0.2, 1.5).set_trans(Tween.TRANS_SINE)
