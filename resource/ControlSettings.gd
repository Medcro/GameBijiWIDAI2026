class_name ControlSettings
extends Resource

const MOVE_LEFT : String = "move_left"
const MOVE_RIGHT : String = "move_right"
const MOVE_DOWN : String = "move_down"
const JUMP : String = "Jump"
const MELEE : String = "Melee"
const RANGED : String = "Ranged"
const HEAL : String = "Heal"
const SP1 : String = "SP1" 
const SP2 : String = "SP2"
const PARRY : String = "Parry"
const DASH : String = "Dash"

@export var default_left = InputEventKey.new()
@export var default_right= InputEventKey.new()
@export var default_down = InputEventKey.new()
@export var default_jump = InputEventKey.new()
@export var default_melee = InputEventKey.new()
@export var default_ranged = InputEventKey.new()
@export var default_heal = InputEventKey.new()
@export var default_sp1 = InputEventKey.new()
@export var default_sp2 = InputEventKey.new()
@export var default_parry = InputEventKey.new()
@export var default_dash = InputEventKey.new()

const input_actions = {
	MOVE_LEFT : "Move Left",
	MOVE_RIGHT : "Move Right",
	MOVE_DOWN : "Move Down",
	JUMP: "Jump",
	DASH: "Dash",
	MELEE: "Melee",
	RANGED: "Ranged Attack",
	HEAL: "Heal",
	SP1: "Special 1",
	SP2: "Special 2",
	PARRY: "Parry"
}
