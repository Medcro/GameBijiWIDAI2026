extends Control

@onready var slot1: Control = $VBoxContainer/slot1
@onready var slot2: Control = $VBoxContainer/Control/HBoxContainer/slot2
@onready var slot3: Control = $VBoxContainer/Control/HBoxContainer/slot3

@onready var inventory_panel: Panel = $inventoryPanel
@onready var close_button: Button = $inventoryPanel/MarginContainer/VBoxContainer/HBoxContainer/close
@onready var grid_container: GridContainer = $inventoryPanel/MarginContainer/VBoxContainer/VScrollBar/GridContainer
@onready var unequip_button: Button = $inventoryPanel/MarginContainer/VBoxContainer/HBoxContainer/unequipButton
@onready var slots_container: VBoxContainer = $VBoxContainer
@onready var inventory_dream_catcher: TextureRect = $inventoryDreamCatcher
@onready var right_point: Control = $rightPoint
@onready var left_point: Control = $leftPoint

var open = false

# Variabel untuk menyimpan slot mana yang sedang mau diisi
var active_slot = null

# Simulasi inventory pemain (Essence yang sudah didapatkan)
@export var collected_essences: Array[EssenceData] = []
@export var inventoryLeft: Texture2D
@export var inventoryRight: Texture2D

func _ready() -> void:
	hide()
	inventory_panel.hide()
	inventory_dream_catcher.hide()
	
	# Sambungkan sinyal slot_clicked dari masing-masing slot ke fungsi open_inventory
	slot1.slot_clicked.connect(open_inventory)
	slot2.slot_clicked.connect(open_inventory)
	slot3.slot_clicked.connect(open_inventory)
	
	# Sambungkan tombol close
	close_button.pressed.connect(close_inventory)
	unequip_button.pressed.connect(_on_unequip_pressed)
	
	## --- CONTOH DATA: Ceritanya pemain sudah ngumpulin 3 item ini ---
	#var pedang = EssenceData.new()
	#pedang.name = "Super Sword"; pedang.type = EssenceData.Type.ACTIVE
	#pedang.icon = preload("res://assets/icon.svg")
	#
	#var api = EssenceData.new()
	#api.name = "Fireball"; api.type = EssenceData.Type.ACTIVE
	#
	#var sepatu = EssenceData.new()
	#sepatu.name = "Dash Boots"; sepatu.type = EssenceData.Type.PASSIVE
	#
	#collected_essences.append_array([pedang, api, sepatu])
	# ----------------------------------------------------------------
	#if "collected_essences" in SaveManager.game_data:
		#collected_essences.append_array(SaveManager.game_data["collected_essences"])
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("EssenceTab"):
		var pause_menu_node = get_parent().find_child("Pause Menu")
		if pause_menu_node != null:
			if not pause_menu_node.visible:
				if open:
					close_menu()
				else:
					open_menu()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("esc") and open:
		if inventory_panel.visible:
			close_inventory()
		else:
			close_menu()
		get_viewport().set_input_as_handled()
	
func open_menu() -> void:
	open = true
	get_tree().paused = true
	show()
	slot1.button.grab_focus()
	
func close_menu() -> void:
	open = false
	get_tree().paused = false
	hide()

func open_inventory(slot_reference, allowed_type):
	active_slot = slot_reference
	
	if active_slot == slot1 || active_slot == slot3:
		inventory_panel.global_position = right_point.global_position - inventory_panel.size/2
		inventory_dream_catcher.texture = inventoryRight
	elif active_slot == slot2:
		inventory_panel.global_position = left_point.global_position - inventory_panel.size/2
		inventory_dream_catcher.texture = inventoryLeft
	#elif active_slot == slot3:
		#inventory_panel.global_position = active_slot.global_position + Vector2(250, 100)
		#inventory_dream_catcher.texture = inventoryRight
	
	inventory_panel.show()
	inventory_dream_catcher.show()
	
	if active_slot.current_essence != null:
		unequip_button.show() # Munculkan jika slot ada isinya
	else:
		unequip_button.hide() # Sembunyikan jika slot masih kosong
		
	for child in grid_container.get_children():
		child.queue_free()
		
	# 1. AMBIL DAFTAR ESSENCE YANG SEDANG DIPAKAI DI SLOT LAIN
	var equipped_essences = get_all_equipped_essences()
	if equipped_essences != []:
		for essence in collected_essences:
			if essence.type == allowed_type:
				# 2. Cek apakah essence ini sudah ada di salah satu slot
				var is_already_equipped = essence in equipped_essences
				
				create_inventory_button(essence, is_already_equipped)
				
	await get_tree().process_frame 
	
	if grid_container.get_child_count() > 0:
		# Kasih fokus ke item pertama di daftar
		grid_container.get_child(0).grab_focus()
	elif unequip_button.visible:
		# Kalau tas kosong tapi ada item di slot, fokus ke tombol unequip
		unequip_button.grab_focus()
	else:
		# Kalau bener-bener kosong, fokus ke tombol close
		close_button.grab_focus()


# Fungsi bantuan untuk mengumpulkan semua essence yang sedang terpasang
func get_all_equipped_essences() -> Array[EssenceData]:
	var list: Array[EssenceData] = []
	if slot1.current_essence != null: list.append(slot1.current_essence)
	if slot2.current_essence != null: list.append(slot2.current_essence)
	if slot3.current_essence != null: list.append(slot3.current_essence)
	return list

func create_inventory_button(essence_data: EssenceData, is_equipped: bool):
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(80, 80)
	
	if essence_data.icon:
		btn.icon = essence_data.icon
		btn.expand_icon = true
	else:
		btn.text = essence_data.name 
		
	grid_container.add_child(btn)
	
	# 3. JIKA SUDAH DIPAKAI, MATIKAN TOMBOLNYA DAN BERI VISUAL GREYED OUT
	if is_equipped:
		btn.disabled = true
		btn.modulate = Color(0.5, 0.5, 0.5, 0.6) # Membuat tombol jadi agak gelap & transparan
		if not essence_data.icon:
			btn.text = essence_data.name + "\n(Equipped)" # Memberi teks penanda tambahan
	else:
		# Jika belum dipakai, tombol berfungsi normal seperti biasa
		btn.pressed.connect(func(): _on_item_selected(essence_data))
		
func _on_item_selected(essence_data: EssenceData):
	if active_slot != null:
		active_slot.set_essence(essence_data) # Masukkan item ke slot
		close_inventory()

func close_inventory():
	inventory_panel.hide()
	inventory_dream_catcher.hide()
	if active_slot != null:
		active_slot.button.grab_focus()
	active_slot = null


func _on_unequip_pressed():
	if active_slot != null:
		active_slot.set_essence(null) # Kirim "null" ke slot untuk mengosongkannya
		close_inventory()
