extends Node
class_name MutationAdvancedSystem

## Advanced Mutation System - Mutation progression, research, and evolution

signal mutation_evolved(mutation_name: String, old_tier: int, new_tier: int)
signal mutation_researched(research_id: String, benefit: String)
signal mutation_infected(mutation_name: String)
signal mutation_resisted(mutation_name: String)

class MutationTier:
	var tier: int
	var name: String
	var description: String
	var stat_bonuses: Dictionary
	var special_ability: String
	var unlock_requirements: Dictionary
	
	func _init(t: int, n: String, desc: String):
		tier = t
		name = n
		description = desc
		stat_bonuses = {}
		special_ability = ""
		unlock_requirements = {}

class MutationResearch:
	var research_id: String
	var mutation_name: String
	var research_tier: int
	var progress: float = 0.0
	var completed: bool = false
	var benefit: String
	var cost: Dictionary  # Materials needed
	
	func _init(id: String, mutation: String, tier: int):
		research_id = id
		mutation_name = mutation
		research_tier = tier

var player_mutations: Dictionary = {}  # {mutation_name: {tier: int, progress: float}}
var mutation_tiers: Dictionary = {}    # {mutation_name: [MutationTier, ...]}
var research_queue: Array = []
var active_research: MutationResearch = null
var research_history: Array = []

var mutation_resistance: Dictionary = {}  # {mutation_name: float (0-1)}
var mutation_evolution_points: int = 0
var total_mutations_discovered: int = 0

func _ready():
	"""Initialize advanced mutation system"""
	_setup_mutation_tiers()
	print("Advanced mutation system initialized")

func _process(delta):
	"""Process active research"""
	if active_research:
		active_research.progress += delta
		
		if active_research.progress >= 30.0:  # 30 seconds per research
			_complete_research()

func _setup_mutation_tiers():
	"""Setup mutation tier data"""
	
	# Acid mutation tiers
	_add_mutation_tier("acid", 1, "Acid Veins", "Basic acidic secretion")
	mutation_tiers["acid"][0].stat_bonuses = {"damage": 5, "corrosion": 1}
	mutation_tiers["acid"][0].special_ability = "acid_spit"
	
	_add_mutation_tier("acid", 2, "Caustic Shell", "Enhanced acidic armor")
	mutation_tiers["acid"][1].stat_bonuses = {"defense": 10, "corrosion": 3}
	mutation_tiers["acid"][1].special_ability = "acid_pool"
	
	_add_mutation_tier("acid", 3, "Dissolution Form", "Complete acidic evolution")
	mutation_tiers["acid"][2].stat_bonuses = {"damage": 15, "defense": 5, "corrosion": 5}
	mutation_tiers["acid"][2].special_ability = "acid_transformation"
	
	# Psychic mutation tiers
	_add_mutation_tier("psychic", 1, "Mental Link", "Basic telepathic connection")
	mutation_tiers["psychic"][0].stat_bonuses = {"intelligence": 8, "awareness": 3}
	mutation_tiers["psychic"][0].special_ability = "mind_sense"
	
	_add_mutation_tier("psychic", 2, "Psychic Barrier", "Mental defense field")
	mutation_tiers["psychic"][1].stat_bonuses = {"intelligence": 12, "awareness": 6, "defense": 5}
	mutation_tiers["psychic"][1].special_ability = "mind_shield"
	
	_add_mutation_tier("psychic", 3, "Omniscience", "Advanced mental mastery")
	mutation_tiers["psychic"][2].stat_bonuses = {"intelligence": 20, "awareness": 10}
	mutation_tiers["psychic"][2].special_ability = "psychic_blast"
	
	# Regeneration mutation tiers
	_add_mutation_tier("regeneration", 1, "Rapid Healing", "Enhanced recovery")
	mutation_tiers["regeneration"][0].stat_bonuses = {"health_regen": 2}
	mutation_tiers["regeneration"][0].special_ability = "self_heal"
	
	_add_mutation_tier("regeneration", 2, "Cellular Regeneration", "Advanced healing factor")
	mutation_tiers["regeneration"][1].stat_bonuses = {"health_regen": 5, "limb_regrowth": 0.5}
	mutation_tiers["regeneration"][1].special_ability = "rapid_recovery"
	
	_add_mutation_tier("regeneration", 3, "Immortal Cells", "Complete regeneration mastery")
	mutation_tiers["regeneration"][2].stat_bonuses = {"health_regen": 10, "limb_regrowth": 1.0}
	mutation_tiers["regeneration"][2].special_ability = "resurrection"
	
	print("Mutation tiers setup complete: %d mutations" % mutation_tiers.size())

func _add_mutation_tier(mutation_name: String, tier: int, name: String, description: String):
	"""Add mutation tier"""
	if mutation_name not in mutation_tiers:
		mutation_tiers[mutation_name] = []
	
	var tier_obj = MutationTier.new(tier, name, description)
	mutation_tiers[mutation_name].append(tier_obj)

func infect_with_mutation(mutation_name: String, intensity: float = 0.5) -> bool:
	"""Attempt to infect player with mutation"""
	
	# Check resistance
	var resistance = mutation_resistance.get(mutation_name, 0.0)
	var infection_chance = (1.0 - resistance) * intensity
	
	if randf() > infection_chance:
		mutation_resisted.emit(mutation_name)
		print("Resisted mutation: %s" % mutation_name)
		return false
	
	# Apply infection
	if mutation_name not in player_mutations:
		player_mutations[mutation_name] = {
			"tier": 0,
			"progress": 0.0,
			"discovered": true
		}
		total_mutations_discovered += 1
	
	player_mutations[mutation_name]["progress"] += intensity * 100.0
	mutation_infected.emit(mutation_name)
	
	print("Infected with mutation: %s (progress: %.0f%%)" % [
		mutation_name,
		player_mutations[mutation_name]["progress"]
	])
	
	# Check for evolution
	_check_mutation_evolution(mutation_name)
	return true

func research_mutation(mutation_name: String) -> bool:
	"""Start researching mutation"""
	if mutation_name not in mutation_tiers:
		print("Unknown mutation: %s" % mutation_name)
		return false
	
	if mutation_name not in player_mutations:
		print("Must be infected to research: %s" % mutation_name)
		return false
	
	var current_tier = player_mutations[mutation_name]["tier"]
	if current_tier >= mutation_tiers[mutation_name].size() - 1:
		print("Mutation already fully evolved: %s" % mutation_name)
		return false
	
	var research = MutationResearch.new(
		"research_%s_tier%d" % [mutation_name, current_tier + 1],
		mutation_name,
		current_tier + 1
	)
	
	research_queue.append(research)
	
	# Start research if none active
	if active_research == null and research_queue.size() > 0:
		active_research = research_queue.pop_front()
	
	print("Queued mutation research: %s -> Tier %d" % [mutation_name, current_tier + 1])
	return true

func _check_mutation_evolution(mutation_name: String):
	"""Check if mutation should evolve"""
	var data = player_mutations[mutation_name]
	var current_tier = data["tier"]
	
	# Each tier requires 100% progress
	if data["progress"] >= 100.0 and current_tier < mutation_tiers[mutation_name].size() - 1:
		var new_tier = current_tier + 1
		var old_name = mutation_tiers[mutation_name][current_tier].name if current_tier < len(mutation_tiers[mutation_name]) else "Unknown"
		
		data["tier"] = new_tier
		data["progress"] = 0.0
		mutation_evolution_points += 1
		
		mutation_evolved.emit(mutation_name, current_tier, new_tier)
		print("Mutation evolved: %s (Tier %d -> %d)" % [mutation_name, current_tier, new_tier])

func _complete_research():
	"""Complete current research"""
	if active_research == null:
		return
	
	var mutation_name = active_research.mutation_name
	var tier = active_research.research_tier
	
	# Apply research benefits
	_apply_research_benefits(mutation_name, tier)
	
	research_history.append(active_research)
	mutation_researched.emit(active_research.research_id, active_research.benefit)
	
	print("Research completed: %s Tier %d" % [mutation_name, tier])
	
	active_research = null
	
	# Start next research
	if research_queue.size() > 0:
		active_research = research_queue.pop_front()

func _apply_research_benefits(mutation_name: String, tier: int):
	"""Apply research benefits"""
	if mutation_name not in mutation_tiers or tier - 1 >= len(mutation_tiers[mutation_name]):
		return
	
	var tier_data = mutation_tiers[mutation_name][tier - 1]
	var benefit = "Unlocked: %s" % tier_data.name
	
	# Increase mutation resistance to other mutations by 5%
	for mutation in mutation_tiers:
		if mutation != mutation_name:
			mutation_resistance[mutation] = min(1.0, mutation_resistance.get(mutation, 0.0) + 0.05)

func get_player_mutation(mutation_name: String) -> Dictionary:
	"""Get player's mutation data"""
	if mutation_name not in player_mutations:
		return {}
	
	var data = player_mutations[mutation_name].duplicate()
	
	if mutation_name in mutation_tiers and data["tier"] < len(mutation_tiers[mutation_name]):
		var tier_info = mutation_tiers[mutation_name][data["tier"]]
		data["name"] = tier_info.name
		data["description"] = tier_info.description
		data["stat_bonuses"] = tier_info.stat_bonuses
		data["special_ability"] = tier_info.special_ability
	
	return data

func get_all_player_mutations() -> Dictionary:
	"""Get all player mutations"""
	var mutations = {}
	
	for mutation_name in player_mutations:
		mutations[mutation_name] = get_player_mutation(mutation_name)
	
	return mutations

func get_mutation_tier_info(mutation_name: String, tier: int) -> Dictionary:
	"""Get info about specific mutation tier"""
	if mutation_name not in mutation_tiers or tier >= len(mutation_tiers[mutation_name]):
		return {}
	
	var tier_obj = mutation_tiers[mutation_name][tier]
	return {
		"tier": tier_obj.tier,
		"name": tier_obj.name,
		"description": tier_obj.description,
		"stat_bonuses": tier_obj.stat_bonuses,
		"special_ability": tier_obj.special_ability
	}

func increase_mutation_resistance(mutation_name: String, amount: float = 0.1):
	"""Increase resistance to mutation"""
	mutation_resistance[mutation_name] = min(1.0, mutation_resistance.get(mutation_name, 0.0) + amount)
	print("Mutation resistance increased: %s (%.0f%%)" % [mutation_name, mutation_resistance[mutation_name] * 100])

func get_research_status() -> Dictionary:
	"""Get mutation research status"""
	var active_mutation = ""
	var progress = 0.0
	
	if active_research:
		active_mutation = active_research.mutation_name
		progress = active_research.progress / 30.0  # 30 seconds per research
	
	return {
		"active_mutation": active_mutation,
		"research_progress": progress,
		"queue_size": research_queue.size(),
		"completed_research": research_history.size(),
		"evolution_points": mutation_evolution_points
	}

func get_statistics() -> Dictionary:
	"""Get mutation statistics"""
	return {
		"mutations_discovered": total_mutations_discovered,
		"mutations_infected": player_mutations.size(),
		"total_mutations_available": mutation_tiers.size(),
		"evolution_points": mutation_evolution_points,
		"average_resistance": (mutation_resistance.values().reduce(func(a, b): return a + b, 0.0) / 
			max(mutation_resistance.size(), 1)) if mutation_resistance.size() > 0 else 0.0,
		"research_completed": research_history.size()
	}
