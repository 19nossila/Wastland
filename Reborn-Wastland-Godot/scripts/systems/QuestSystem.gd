extends Node
class_name QuestSystem

## Quest System - Manages quests, objectives, and rewards

class Quest:
	var quest_id: String
	var title: String
	var description: String
	var giver: String
	var objectives: Array
	var status: String = "available"  # available, active, complete, failed
	var reward_xp: int = 0
	var reward_items: Dictionary = {}
	var reward_reputation: Dictionary = {}
	
	func _init(id: String, t: String, desc: String):
		quest_id = id
		title = t
		description = desc

var available_quests: Dictionary = {}
var active_quests: Dictionary = {}  # player_id -> [quest_ids]
var completed_quests: Dictionary = {}  # player_id -> [quest_ids]

func _ready():
	_initialize_quests()

func _initialize_quests():
	"""Create default quests"""
	# Settler quests
	var quest1 = Quest.new("quest_supplies_01", "Gather Supplies", "Collect 5 medical kits from abandoned houses")
	quest1.giver = "npc_survivor_01"
	quest1.objectives = ["collect:medical_kit:5"]
	quest1.reward_xp = 100
	quest1.reward_items = {"food_can": 3}
	quest1.reward_reputation = {"nomads": 10, "eden": 5}
	available_quests["quest_supplies_01"] = quest1
	
	# Guard quests
	var quest2 = Quest.new("quest_patrol_01", "Clear Zombie Nest", "Eliminate 10 zombies near checkpoint")
	quest2.giver = "npc_guard_01"
	quest2.objectives = ["kill:zombie:10"]
	quest2.reward_xp = 150
	quest2.reward_items = {"ammo_9mm": 20}
	quest2.reward_reputation = {"enclave": 15}
	available_quests["quest_patrol_01"] = quest2
	
	# Merchant quests
	var quest3 = Quest.new("quest_trade_01", "Find Rare Parts", "Locate 3 electronic circuits")
	quest3.giver = "npc_merchant_01"
	quest3.objectives = ["collect:circuit:3"]
	quest3.reward_xp = 80
	quest3.reward_items = {"water_bottle": 5}
	quest3.reward_reputation = {"nomads": 8}
	available_quests["quest_trade_01"] = quest3
	
	# Scientist quests
	var quest4 = Quest.new("quest_mutation_01", "Study Mutations", "Kill 5 mutated zombies and collect samples")
	quest4.giver = "npc_scientist_01"
	quest4.objectives = ["kill:mutant_zombie:5", "collect:zombie_sample:5"]
	quest4.reward_xp = 200
	quest4.reward_reputation = {"eden": 15}
	available_quests["quest_mutation_01"] = quest4
	
	# Eden quests
	var quest5 = Quest.new("quest_farm_01", "Harvest Crops", "Collect 20 vegetables from farm")
	quest5.giver = "npc_farmer_01"
	quest5.objectives = ["collect:vegetable:20"]
	quest5.reward_xp = 60
	quest5.reward_items = {"food_can": 10}
	quest5.reward_reputation = {"eden": 20}
	available_quests["quest_farm_01"] = quest5

func accept_quest(player_id: int, quest_id: String) -> bool:
	"""Accept a quest"""
	if quest_id not in available_quests:
		return false
	
	var quest = available_quests[quest_id]
	quest.status = "active"
	
	if player_id not in active_quests:
		active_quests[player_id] = []
	
	active_quests[player_id].append(quest_id)
	print("Quest accepted: %s" % quest.title)
	return true

func complete_quest(player_id: int, quest_id: String) -> Dictionary:
	"""Complete a quest and get rewards"""
	if quest_id not in available_quests:
		return {}
	
	var quest = available_quests[quest_id]
	quest.status = "complete"
	
	# Move to completed
	if player_id not in completed_quests:
		completed_quests[player_id] = []
	completed_quests[player_id].append(quest_id)
	
	# Remove from active
	if player_id in active_quests:
		active_quests[player_id].erase(quest_id)
	
	print("Quest completed: %s (XP: %d)" % [quest.title, quest.reward_xp])
	
	return {
		"xp": quest.reward_xp,
		"items": quest.reward_items,
		"reputation": quest.reward_reputation
	}

func fail_quest(player_id: int, quest_id: String):
	"""Fail a quest"""
	if quest_id not in available_quests:
		return
	
	var quest = available_quests[quest_id]
	quest.status = "failed"
	
	if player_id in active_quests:
		active_quests[player_id].erase(quest_id)

func update_progress(player_id: int, quest_id: String, objective: String, value: int):
	"""Update quest progress"""
	if quest_id not in available_quests:
		return
	
	var quest = available_quests[quest_id]
	
	# Check objective completion
	for i in range(quest.objectives.size()):
		if objective in quest.objectives[i]:
			print("Progress on %s: %s" % [quest.title, objective])

func get_active_quests(player_id: int) -> Array:
	"""Get all active quests for player"""
	return active_quests.get(player_id, [])

func get_quest_data(quest_id: String) -> Dictionary:
	"""Get quest details"""
	if quest_id not in available_quests:
		return {}
	
	var quest = available_quests[quest_id]
	return {
		"id": quest.quest_id,
		"title": quest.title,
		"description": quest.description,
		"giver": quest.giver,
		"status": quest.status,
		"objectives": quest.objectives,
		"rewards": {
			"xp": quest.reward_xp,
			"items": quest.reward_items,
			"reputation": quest.reward_reputation
		}
	}

func get_available_quests() -> Array:
	"""Get all available quests"""
	return available_quests.keys()

func is_quest_complete(quest_id: String, progress: Dictionary) -> bool:
	"""Check if quest objectives are met"""
	if quest_id not in available_quests:
		return false
	
	var quest = available_quests[quest_id]
	
	for objective in quest.objectives:
		# Simple check: if objective data exists, consider it complete
		if objective not in str(progress):
			return false
	
	return true
