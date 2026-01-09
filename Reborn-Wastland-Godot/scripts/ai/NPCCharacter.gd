extends Node3D
class_name NPCCharacter

## NPC Character - Base class for non-player characters

@export var npc_id: String = "npc_default"
@export var npc_name: String = "Stranger"
@export var npc_type: String = "merchant"  # merchant, guard, survivor, scientist
@export var faction: String = "nomads"

var dialogue_tree: Dictionary = {}
var trades: Array = []
var quests: Array = []
var is_talking: bool = false

func _ready():
	_initialize_npc()

func _initialize_npc():
	"""Initialize NPC based on type"""
	match npc_type:
		"merchant":
			_setup_merchant()
		"guard":
			_setup_guard()
		"survivor":
			_setup_survivor()
		"scientist":
			_setup_scientist()

func _setup_merchant():
	"""Setup merchant NPC"""
	dialogue_tree = {
		"greeting": {
			"text": "Looking for supplies? I've got everything you need.",
			"options": [
				{"text": "Show me your trades", "next": "trades"},
				{"text": "What faction are you?", "next": "faction_info"},
				{"text": "Goodbye", "next": "end"}
			]
		},
		"trades": {
			"text": "Pick what you need.",
			"options": [
				{"text": "Back", "next": "greeting"},
				{"text": "Goodbye", "next": "end"}
			]
		},
		"faction_info": {
			"text": "I work with the %s." % faction,
			"options": [
				{"text": "Back", "next": "greeting"},
				{"text": "Goodbye", "next": "end"}
			]
		},
		"end": {
			"text": "Farewell.",
			"options": []
		}
	}
	
	# Add default trades
	trades = [
		{"sell": "food_can", "price": 10},
		{"sell": "water_bottle", "price": 8},
		{"sell": "medical_kit", "price": 40}
	]

func _setup_guard():
	"""Setup guard NPC"""
	dialogue_tree = {
		"greeting": {
			"text": "State your business, stranger.",
			"options": [
				{"text": "I'm just passing through", "next": "passing"},
				{"text": "I work with %s" % faction, "next": "faction_ally"},
				{"text": "Leave me alone", "next": "end"}
			]
		},
		"passing": {
			"text": "Keep your hands visible.",
			"options": [
				{"text": "Will do", "next": "end"}
			]
		},
		"faction_ally": {
			"text": "Ah, one of us. Welcome.",
			"options": [
				{"text": "Thanks", "next": "end"}
			]
		},
		"end": {
			"text": "Move along.",
			"options": []
		}
	}

func _setup_survivor():
	"""Setup survivor NPC"""
	dialogue_tree = {
		"greeting": {
			"text": "You seem like you know how to survive. Maybe we can help each other?",
			"options": [
				{"text": "What do you need?", "next": "quest"},
				{"text": "Not interested", "next": "end"}
			]
		},
		"quest": {
			"text": "I need supplies from the north. Risky area.",
			"options": [
				{"text": "I'll help", "next": "accept_quest"},
				{"text": "Too risky", "next": "end"}
			]
		},
		"accept_quest": {
			"text": "Thank you! Bring back 5 medical kits.",
			"options": [
				{"text": "Will do", "next": "end"}
			]
		},
		"end": {
			"text": "Good luck out there.",
			"options": []
		}
	}

func _setup_scientist():
	"""Setup scientist NPC"""
	dialogue_tree = {
		"greeting": {
			"text": "Fascinating! Your mutations are quite advanced. Have you been studying them?",
			"options": [
				{"text": "Tell me about mutations", "next": "science"},
				{"text": "Not interested in science", "next": "end"}
			]
		},
		"science": {
			"text": "Mutations are fascinating. Each one has unique properties we could exploit.",
			"options": [
				{"text": "Can you help me evolve?", "next": "mutation_quest"},
				{"text": "Back", "next": "greeting"}
			]
		},
		"mutation_quest": {
			"text": "Bring me zombie samples. We'll study them together.",
			"options": [
				{"text": "I'll gather samples", "next": "end"}
			]
		},
		"end": {
			"text": "Excellent work, my friend.",
			"options": []
		}
	}

func start_dialogue() -> Dictionary:
	"""Start dialogue with NPC"""
	is_talking = true
	return dialogue_tree.get("greeting", {})

func get_dialogue_option(option_index: int) -> String:
	"""Get next dialogue state from option"""
	var current = dialogue_tree.get("greeting", {})
	if "options" in current and option_index < current["options"].size():
		return current["options"][option_index].get("next", "end")
	return "end"

func end_dialogue():
	"""End dialogue"""
	is_talking = false

func add_trade(item: String, price: int):
	"""Add trade option"""
	trades.append({"sell": item, "price": price})

func add_quest(quest_data: Dictionary):
	"""Add quest"""
	quests.append(quest_data)
