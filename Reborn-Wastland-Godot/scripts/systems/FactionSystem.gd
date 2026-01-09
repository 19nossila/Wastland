extends Node
class_name FactionSystem

## Faction System - Manages faction relationships and reputation

const FACTIONS = ["enclave", "nomads", "eden", "collective"]

var faction_reputation: Dictionary = {}  # player_id -> {faction -> reputation}

func _ready():
	pass

func initialize_player(player_id: int):
	"""Initialize faction reputation for new player"""
	faction_reputation[player_id] = {
		"enclave": 0,
		"nomads": 0,
		"eden": 0,
		"collective": 0
	}

func add_reputation(player_id: int, faction: String, amount: int):
	"""Add reputation with a faction"""
	if player_id not in faction_reputation:
		initialize_player(player_id)
	
	if faction not in faction_reputation[player_id]:
		return
	
	faction_reputation[player_id][faction] += amount
	faction_reputation[player_id][faction] = clamp(
		faction_reputation[player_id][faction], -100, 100)
	
	print("Reputation with %s: %d" % [faction, faction_reputation[player_id][faction]])
	sync_faction_reputation.rpc_id(1, player_id)

func get_reputation(player_id: int, faction: String) -> int:
	"""Get reputation with a faction"""
	if player_id not in faction_reputation:
		initialize_player(player_id)
	
	return faction_reputation[player_id].get(faction, 0)

func get_faction_status(player_id: int, faction: String) -> String:
	"""Get human-readable faction status"""
	var rep = get_reputation(player_id, faction)
	
	match rep:
		-100 to -50:
			return "MORTAL ENEMY"
		-49 to -20:
			return "ENEMY"
		-19 to 0:
			return "HOSTILE"
		1 to 19:
			return "NEUTRAL"
		20 to 49:
			return "FRIENDLY"
		50 to 100:
			return "ALLY"
		_:
			return "UNKNOWN"

func get_faction_discount(player_id: int, faction: String) -> float:
	"""Get shop discount from faction reputation"""
	var rep = get_reputation(player_id, faction)
	
	if rep >= 50:
		return 0.8  # 20% discount
	elif rep >= 20:
		return 0.9  # 10% discount
	
	return 1.0  # No discount

func faction_attacks_enabled(player_id: int, faction: String) -> bool:
	"""Check if faction will attack player"""
	var rep = get_reputation(player_id, faction)
	return rep < -50

@rpc("authority")
func sync_faction_reputation(player_id: int):
	"""Sync faction reputation across network"""
	var rep_data = faction_reputation.get(player_id, {})
	rpc("receive_faction_data", player_id, rep_data)

@rpc
func receive_faction_data(player_id: int, rep_data: Dictionary):
	"""Receive faction data from server"""
	faction_reputation[player_id] = rep_data
