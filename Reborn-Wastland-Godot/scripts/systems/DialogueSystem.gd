extends Node
class_name DialogueSystem

## Dialogue System - Manages dialogue trees and conversations

signal dialogue_started(npc_name: String)
signal dialogue_ended
signal dialogue_option_selected(option: String)

var current_dialogue: Dictionary = {}
var current_npc: String = ""
var dialogue_database: Dictionary = {}

class DialogueNode:
	var id: String
	var text: String
	var options: Array = []
	
	func _init(id: String, text: String):
		self.id = id
		self.text = text
	
	func add_option(option_text: String, next_node_id: String):
		options.append({"text": option_text, "next": next_node_id})

func _ready():
	"""Initialize dialogue system"""
	_load_dialogue_trees()
	print("Dialogue system initialized")

func _load_dialogue_trees():
	"""Load all dialogue trees"""
	# Merchant dialogue tree
	var merchant_greeting = DialogueNode.new("merchant_greeting", "Welcome, wanderer. Looking for supplies?")
	merchant_greeting.add_option("Show me your wares", "merchant_trade")
	merchant_greeting.add_option("Never mind", "end")
	
	var merchant_trade = DialogueNode.new("merchant_trade", "I have food, water, and medical supplies. What do you need?")
	merchant_trade.add_option("Food", "merchant_food")
	merchant_trade.add_option("Water", "merchant_water")
	merchant_trade.add_option("Medical supplies", "merchant_medical")
	merchant_trade.add_option("Never mind", "end")
	
	var merchant_food = DialogueNode.new("merchant_food", "3 circuits for a food can. Deal?")
	merchant_food.add_option("Agree", "merchant_trade_complete")
	merchant_food.add_option("Too expensive", "merchant_greeting")
	
	var merchant_water = DialogueNode.new("merchant_water", "2 circuits for a water bottle. Fair price?")
	merchant_water.add_option("Agree", "merchant_trade_complete")
	merchant_water.add_option("Too expensive", "merchant_greeting")
	
	var merchant_medical = DialogueNode.new("merchant_medical", "5 circuits for a medical kit. Best deal in town.")
	merchant_medical.add_option("Agree", "merchant_trade_complete")
	merchant_medical.add_option("Too expensive", "merchant_greeting")
	
	var merchant_complete = DialogueNode.new("merchant_trade_complete", "Good doing business with you! Come back anytime.")
	merchant_complete.add_option("Thanks!", "end")
	
	# Guard dialogue tree
	var guard_greeting = DialogueNode.new("guard_greeting", "Stop! State your business.")
	guard_greeting.add_option("Just passing through", "guard_pass")
	guard_greeting.add_option("Looking for trouble", "guard_hostile")
	guard_greeting.add_option("Looking for work", "guard_work")
	
	var guard_pass = DialogueNode.new("guard_pass", "Move along then.")
	guard_pass.add_option("Will do", "end")
	
	var guard_hostile = DialogueNode.new("guard_hostile", "Big mistake, wanderer!")
	guard_hostile.add_option("Fight!", "end")
	
	var guard_work = DialogueNode.new("guard_work", "We need someone to clear the zombie horde to the north.")
	guard_work.add_option("I'll do it", "guard_quest")
	guard_work.add_option("Too dangerous", "guard_greeting")
	
	var guard_quest = DialogueNode.new("guard_quest", "Good. Kill 10 zombies and come back. 150 XP reward.")
	guard_quest.add_option("I'll be back", "end")
	
	# Store dialogue trees
	dialogue_database["merchant"] = {
		"greeting": merchant_greeting,
		"trade": merchant_trade,
		"food": merchant_food,
		"water": merchant_water,
		"medical": merchant_medical,
		"trade_complete": merchant_complete
	}
	
	dialogue_database["guard"] = {
		"greeting": guard_greeting,
		"pass": guard_pass,
		"hostile": guard_hostile,
		"work": guard_work,
		"quest": guard_quest
	}

func start_dialogue(npc_type: String, npc_name: String) -> Dictionary:
	"""Start dialogue with NPC"""
	current_npc = npc_name
	dialogue_started.emit(npc_name)
	
	if npc_type in dialogue_database:
		var greeting_key = "greeting" if "greeting" in dialogue_database[npc_type] else dialogue_database[npc_type].keys()[0]
		current_dialogue = dialogue_database[npc_type][greeting_key]
		return get_current_dialogue()
	
	return {}

func get_current_dialogue() -> Dictionary:
	"""Get current dialogue node as dictionary"""
	if current_dialogue.is_empty():
		return {}
	
	return {
		"id": current_dialogue.id,
		"text": current_dialogue.text,
		"options": current_dialogue.options
	}

func select_option(option_index: int) -> Dictionary:
	"""Select a dialogue option"""
	if option_index >= current_dialogue.options.size():
		return {}
	
	var option = current_dialogue.options[option_index]
	dialogue_option_selected.emit(option["text"])
	
	if option["next"] == "end":
		end_dialogue()
		return {}
	
	# In a full implementation, you'd navigate to the next node here
	return {}

func end_dialogue():
	"""End current dialogue"""
	current_dialogue = {}
	current_npc = ""
	dialogue_ended.emit()

func has_dialogue_option(option_index: int) -> bool:
	"""Check if dialogue option exists"""
	return option_index < current_dialogue.options.size()

func get_npc_greeting(npc_type: String) -> String:
	"""Get NPC greeting text"""
	if npc_type in dialogue_database and "greeting" in dialogue_database[npc_type]:
		return dialogue_database[npc_type]["greeting"].text
	return "Hello there."

func get_dialogue_options() -> Array:
	"""Get current dialogue options"""
	return current_dialogue.options if not current_dialogue.is_empty() else []
