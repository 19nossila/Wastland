extends Node
class_name QuestChainSystem

## Quest Chain System - Links quests into multi-stage chains

signal chain_started(chain_id: String)
signal chain_completed(chain_id: String)
signal next_quest_unlocked(chain_id: String, quest_id: String)

var quest_chains: Dictionary = {}
var active_chains: Dictionary = {}

class QuestChain:
	var chain_id: String
	var title: String
	var description: String
	var quests: Array = []
	var current_stage: int = 0
	var completed: bool = false
	var rewards_final: Dictionary = {}
	
	func _init(id: String, title: String, desc: String):
		chain_id = id
		self.title = title
		description = desc

func _ready():
	"""Initialize quest chain system"""
	_create_quest_chains()
	print("Quest chain system initialized with %d chains" % quest_chains.size())

func _create_quest_chains():
	"""Create all quest chains"""
	
	# Survival Chain
	var survival_chain = QuestChain.new("chain_survival", "Survival", "Learn to survive in the wasteland")
	survival_chain.quests = [
		"quest_supplies_01",  # Gather supplies
		"quest_farm_01",      # Harvest vegetables
		"quest_trade_01"      # Locate circuits
	]
	survival_chain.rewards_final = {
		"xp": 300,
		"circuits": 50,
		"reputation_nomads": 30
	}
	quest_chains["chain_survival"] = survival_chain
	
	# Combat Chain
	var combat_chain = QuestChain.new("chain_combat", "Combat Training", "Become a skilled fighter")
	combat_chain.quests = [
		"quest_patrol_01",       # Kill 10 zombies
		"quest_mutation_01",     # Kill 5 mutated zombies
		"quest_horde_01"         # Eliminate zombie horde (to create)
	]
	combat_chain.rewards_final = {
		"xp": 500,
		"circuits": 30,
		"reputation_enclave": 50
	}
	quest_chains["chain_combat"] = combat_chain
	
	# Science Chain
	var science_chain = QuestChain.new("chain_science", "Scientific Research", "Unlock mutation secrets")
	science_chain.quests = [
		"quest_mutation_01",     # Kill mutated zombies
		"quest_samples_01",      # Collect mutation samples (to create)
		"quest_vaccine_01"       # Develop vaccine (to create)
	]
	science_chain.rewards_final = {
		"xp": 400,
		"research_data": 100,
		"reputation_eden": 50
	}
	quest_chains["chain_science"] = science_chain
	
	# Faction Chain
	var faction_chain = QuestChain.new("chain_faction", "Faction Rise", "Build faction power")
	faction_chain.quests = [
		"quest_patrol_01",       # Enclave patrol
		"quest_trade_01",        # Nomad trade
		"quest_farm_01"          # Eden farming
	]
	faction_chain.rewards_final = {
		"xp": 600,
		"circuits": 100,
		"reputation_all": 20
	}
	quest_chains["chain_faction"] = faction_chain

func start_chain(chain_id: String) -> bool:
	"""Start a quest chain"""
	if chain_id not in quest_chains:
		print("Chain not found: " + chain_id)
		return false
	
	if chain_id in active_chains:
		print("Chain already active: " + chain_id)
		return false
	
	var chain = quest_chains[chain_id]
	chain.current_stage = 0
	chain.completed = false
	active_chains[chain_id] = chain
	
	chain_started.emit(chain_id)
	print("Started chain: " + chain.title)
	return true

func get_current_quest(chain_id: String) -> String:
	"""Get current quest in chain"""
	if chain_id not in active_chains:
		return ""
	
	var chain = active_chains[chain_id]
	if chain.current_stage >= chain.quests.size():
		return ""
	
	return chain.quests[chain.current_stage]

func advance_chain(chain_id: String, quest_system: QuestSystem) -> bool:
	"""Move to next quest in chain"""
	if chain_id not in active_chains:
		return false
	
	var chain = active_chains[chain_id]
	chain.current_stage += 1
	
	if chain.current_stage >= chain.quests.size():
		# Chain complete
		complete_chain(chain_id, quest_system)
		return true
	else:
		# Unlock next quest
		var next_quest_id = chain.quests[chain.current_stage]
		next_quest_unlocked.emit(chain_id, next_quest_id)
		print("Unlocked next quest in chain %s: %s" % [chain_id, next_quest_id])
		return false

func complete_chain(chain_id: String, quest_system: QuestSystem):
	"""Complete entire quest chain"""
	if chain_id not in active_chains:
		return
	
	var chain = active_chains[chain_id]
	chain.completed = true
	
	# Distribute final rewards
	if quest_system:
		var rewards = chain.rewards_final
		if "xp" in rewards:
			print("Chain completed! Earned %d XP" % rewards["xp"])
		if "circuits" in rewards:
			print("Earned %d circuits" % rewards["circuits"])
	
	chain_completed.emit(chain_id)
	print("Completed chain: " + chain.title)

func get_chain_progress(chain_id: String) -> Dictionary:
	"""Get chain progress"""
	if chain_id not in active_chains:
		return {}
	
	var chain = active_chains[chain_id]
	return {
		"chain_id": chain_id,
		"title": chain.title,
		"current_stage": chain.current_stage,
		"total_stages": chain.quests.size(),
		"progress_percent": float(chain.current_stage) / chain.quests.size() * 100,
		"completed": chain.completed
	}

func get_all_chains() -> Array:
	"""Get all available chains"""
	return quest_chains.keys()

func get_active_chains() -> Array:
	"""Get all active chains"""
	return active_chains.keys()

func get_chain_quests(chain_id: String) -> Array:
	"""Get all quests in chain"""
	if chain_id not in quest_chains:
		return []
	
	return quest_chains[chain_id].quests

func is_chain_active(chain_id: String) -> bool:
	"""Check if chain is active"""
	return chain_id in active_chains

func is_chain_complete(chain_id: String) -> bool:
	"""Check if chain is complete"""
	if chain_id not in active_chains:
		return false
	
	return active_chains[chain_id].completed

func abandon_chain(chain_id: String):
	"""Abandon a quest chain"""
	if chain_id in active_chains:
		active_chains.erase(chain_id)
		print("Abandoned chain: " + chain_id)

func reset_chain(chain_id: String):
	"""Reset chain to beginning"""
	if chain_id in active_chains:
		active_chains[chain_id].current_stage = 0
		active_chains[chain_id].completed = false
		print("Reset chain: " + chain_id)
