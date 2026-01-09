extends Node
class_name MutationSystem

## Mutation System - Manages player mutations and genetic evolution

const MUTATIONS = {
	"night_vision": {
		"name": "Night Vision",
		"hunger_increase": 0.3,
		"benefits": {"vision_range": 50},
		"description": "See in darkness but sensitive to sunlight"
	},
	"armored_skin": {
		"name": "Armored Skin",
		"hunger_increase": 0.5,
		"benefits": {"damage_reduction": 0.25},
		"description": "Reduced physical damage, but high metabolism"
	},
	"regeneration": {
		"name": "Regeneration",
		"hunger_increase": 0.4,
		"benefits": {"hp_regen": 5},
		"description": "Heal automatically but slower movement"
	},
	"enhanced_limbs": {
		"name": "Enhanced Limbs",
		"hunger_increase": 0.35,
		"benefits": {"movement_speed": 1.2},
		"description": "Faster movement but reduced accuracy"
	},
	"enhanced_senses": {
		"name": "Enhanced Senses",
		"hunger_increase": 0.6,
		"benefits": {"detection_range": 100},
		"description": "Detect enemies and resources far away"
	},
	"exoskeleton": {
		"name": "Exoskeleton",
		"hunger_increase": 0.45,
		"benefits": {"carry_capacity": 1.5, "movement_speed": 0.85},
		"description": "Carry more items but reduced agility"
	}
}

var player_mutations: Dictionary = {}  # player_id -> mutation_data
var mutation_level: float = 0.0  # 0-100%

func _ready():
	pass

func add_mutation(player_id: int, mutation_type: String, intensity: float):
	"""Add or increase a mutation for a player"""
	if mutation_type not in MUTATIONS:
		push_error("Unknown mutation: %s" % mutation_type)
		return
	
	if player_id not in player_mutations:
		player_mutations[player_id] = {}
	
	if mutation_type not in player_mutations[player_id]:
		player_mutations[player_id][mutation_type] = 0.0
	
	player_mutations[player_id][mutation_type] = min(100.0, 
		player_mutations[player_id][mutation_type] + intensity)
	
	mutation_level += intensity * 0.01
	mutation_level = min(100.0, mutation_level)
	
	print("Mutation added: %s (intensity: %.1f)" % [mutation_type, intensity])
	sync_mutations.rpc_id(1, player_id)

func remove_mutation(player_id: int, mutation_type: String, intensity: float):
	"""Remove or reduce a mutation"""
	if player_id in player_mutations and mutation_type in player_mutations[player_id]:
		player_mutations[player_id][mutation_type] = max(0.0,
			player_mutations[player_id][mutation_type] - intensity)
		
		mutation_level -= intensity * 0.01
		mutation_level = max(0.0, mutation_level)

func get_player_mutations(player_id: int) -> Dictionary:
	"""Get all mutations for a player"""
	return player_mutations.get(player_id, {})

func get_mutation_benefit(player_id: int, benefit: String) -> float:
	"""Calculate cumulative benefit from mutations"""
	var total_benefit = 0.0
	
	if player_id not in player_mutations:
		return total_benefit
	
	for mutation_type in player_mutations[player_id]:
		if mutation_type in MUTATIONS:
			var mutation_data = MUTATIONS[mutation_type]
			if benefit in mutation_data["benefits"]:
				var intensity = player_mutations[player_id][mutation_type] / 100.0
				total_benefit += mutation_data["benefits"][benefit] * intensity
	
	return total_benefit

func get_hunger_modifier(player_id: int) -> float:
	"""Get hunger increase from mutations"""
	var modifier = 1.0
	
	if player_id not in player_mutations:
		return modifier
	
	for mutation_type in player_mutations[player_id]:
		if mutation_type in MUTATIONS:
			var intensity = player_mutations[player_id][mutation_type] / 100.0
			modifier += MUTATIONS[mutation_type]["hunger_increase"] * intensity
	
	return modifier

@rpc("authority")
func sync_mutations(player_id: int):
	"""Synchronize mutations across network"""
	var mutation_data = get_player_mutations(player_id)
	rpc("receive_mutations", player_id, mutation_data)

@rpc
func receive_mutations(player_id: int, mutation_data: Dictionary):
	"""Receive mutation data from server"""
	player_mutations[player_id] = mutation_data
