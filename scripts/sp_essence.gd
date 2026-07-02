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
@onready var desc_label: Label = $inventoryPanel/descLabel

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
	
	if SaveManager.game_data.has("collected_essences"):
			# Gunakan assign atau looping agar tipenya tetap Array[EssenceData]
			for essence in SaveManager.game_data["collected_essences"]:
				collected_essences.append(essence)
	
	# Load item ke slot masing-masing
	if SaveManager.game_data.has("equipped_slot1") and SaveManager.game_data["equipped_slot1"] != null:
		slot1.set_essence(SaveManager.game_data["equipped_slot1"])
		
	if SaveManager.game_data.has("equipped_slot2") and SaveManager.game_data["equipped_slot2"] != null:
		slot2.set_essence(SaveManager.game_data["equipped_slot2"])
		
	if SaveManager.game_data.has("equipped_slot3") and SaveManager.game_data["equipped_slot3"] != null:
		slot3.set_essence(SaveManager.game_data["equipped_slot3"])
	
	call_deferred("_sync_powerups_to_player")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("EssenceTab"):
		var pause_menu_node = get_parent().find_child("Pause Menu")
		if pause_menu_node != null and not pause_menu_node.visible:
			if open:
				# Jika menu essence sedang TERBUKA
				if inventory_panel.visible:
					# Jika panel inventory kecil sedang terbuka, tutup panelnya saja
					close_inventory()
				else:
					# Jika panel inventory kecil tidak terbuka, tutup keseluruhan menu
					close_menu()
			else:
				# Jika menu essence sedang TERTUTUP, buka menunya
				open_menu()
				
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
	_clear_description()
	
	if active_slot.current_essence != null:
		unequip_button.show() # Munculkan jika slot ada isinya
	else:
		unequip_button.hide() # Sembunyikan jika slot masih kosong
		
	for child in grid_container.get_children():
		child.queue_free()
		
	# 1. AMBIL DAFTAR ESSENCE YANG SEDANG DIPAKAI DI SLOT LAIN
	var equipped_essences = get_all_equipped_essences()
	for essence in collected_essences:
		if essence != null:
			if essence.type == allowed_type:
				# 2. Cek apakah essence ini sudah ada di salah satu slot
				var is_already_equipped = false
				for eq_essence in equipped_essences:
					if eq_essence != null and eq_essence.name == essence.name:
						is_already_equipped = true
						break
				
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
	if slot1 and slot1.current_essence != null: 
		list.append(slot1.current_essence)
	if slot2 and slot2.current_essence != null: 
		list.append(slot2.current_essence)
	if slot3 and slot3.current_essence != null: 
		list.append(slot3.current_essence)
	return list

func create_inventory_button(essence_data: EssenceData, is_equipped: bool):
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(80, 80)
	
	if essence_data.icon:
		btn.icon = essence_data.icon
		btn.expand_icon = true
	else:
		btn.text = essence_data.name 
	# Saat mouse masuk atau tombol di-focus keyboard, tampilkan deskripsi
	btn.mouse_entered.connect(func(): _show_description(essence_data.name + ": " + essence_data.description))
	btn.focus_entered.connect(func(): _show_description(essence_data.name + ": " + essence_data.description))
	
	# Saat mouse keluar atau fokus pindah, kosongkan teks/beri teks default
	btn.mouse_exited.connect(func(): _clear_description())
	btn.focus_exited.connect(func(): _clear_description())
	
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
		_sync_powerups_to_player()
		_save_equipped_slots_to_manager()

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
		_sync_powerups_to_player()
		_save_equipped_slots_to_manager()

func _show_description(text: String):
	desc_label.text = text

func _clear_description():
	desc_label.text = "Pick an Essence to see the description."

func _sync_powerups_to_player():
	# Cari player di dalam scene menggunakan Group
	var player = get_tree().get_first_node_in_group("Player")
	
	# Pastikan playernya ketemu dan punya fungsinya
	if player != null and player.has_method("update_active_essences"):
		var equipped_list = get_all_equipped_essences()
		player.update_active_essences(equipped_list)

func _save_equipped_slots_to_manager():
	SaveManager.game_data["equipped_slot1"] = slot1.current_essence
	SaveManager.game_data["equipped_slot2"] = slot2.current_essence
	SaveManager.game_data["equipped_slot3"] = slot3.current_essence
	SaveManager.save_game()
