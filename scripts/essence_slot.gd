# essence_slot.gd
extends Control

signal slot_clicked(slot_reference, type)

@onready var button: Button = $Button

# Tentukan tipe slot ini di Inspector (Attack atau Movement)
@export var allowed_type: EssenceData.Type 

var current_essence: EssenceData

func _ready() -> void:
	update_ui()
	button.pressed.connect(_on_button_pressed)	

func _on_button_pressed():
	# Saat dipencet, pancarkan sinyal ke script sp_essence.gd
	slot_clicked.emit(self, allowed_type)

func update_ui():
	# Memaksa gambar sebesar apapun untuk menyusut seukuran tombol
	button.expand_icon = true 

	if current_essence:
		button.icon = current_essence.icon
		button.modulate = Color.WHITE
	else:
		# Jika kosong, beri warna transparan atau icon siluet
		button.icon = preload("res://assets/UI/EssenceMenu/dream essence.png") 
		button.modulate = Color(1, 1, 1, 0.3)
		
	# Opsional: Beri warna bingkai berbeda berdasarkan tipe slot
	if allowed_type == EssenceData.Type.ACTIVE:
		button.self_modulate = Color.INDIAN_RED # Merah untuk Attack
	else:
		button.self_modulate = Color.CORNFLOWER_BLUE # Biru untuk Movement

func set_essence(data: EssenceData):	
	# Jika data yang masuk adalah null, artinya perintah UNEQUIP
	if data == null:
		current_essence = null
		update_ui()
		print("Power up dilepas dari slot!")
		return
		
	if data.type == allowed_type:
		current_essence = data
		update_ui()
		print("Power up dipasang!")
	else:
		print("Tipe tidak cocok! Slot ini hanya untuk: ", EssenceData.Type.keys()[allowed_type])
