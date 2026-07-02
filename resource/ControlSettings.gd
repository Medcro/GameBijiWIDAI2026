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
const ESSENCETAB : String = "EssenceTab"

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
	PARRY: "Parry",
	ESSENCETAB: "Essence Menu"
}

# Get keybind function
static func get_keybind(target_title: String) -> String:
	for action in ControlSettings.input_actions:
		if ControlSettings.input_actions[action] == target_title:
			var events = InputMap.action_get_events(action)
			
			# Standard if/else block for readability
			if events.size() > 0:
				return events[0].as_text().trim_suffix(" (Physical)")
			else:
				return ""
				
	return ""
