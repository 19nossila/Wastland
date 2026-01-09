extends Node3D
class_name NPCSpawner

## NPC Spawner - Manages NPC spawning and placement

var npc_database: Array = []
var spawned_npcs: Array = []
var spawn_points: Array = []

class NPCData:
	var name: String
	var type: String
	var position: Vector3
	var faction: String
	var dialogue_greeting: String
	
	func _init(name: String, type: String, position: Vector3, faction: String, greeting: String = ""):
		self.name = name
		self.type = type
		self.position = position
		self.faction = faction
		self.dialogue_greeting = greeting

func _ready():
	"""Initialize NPC spawner"""
	_create_spawn_points()
	_load_npc_database()
	_spawn_npcs()
	print("NPC spawner initialized with %d NPCs" % spawned_npcs.size())

func _create_spawn_points():
	"""Create spawn points for NPCs"""
	spawn_points = [
		Vector3(10, 0, 0),    # Town center
		Vector3(-10, 0, 0),   # Town edge
		Vector3(0, 0, 10),    # Market
		Vector3(0, 0, -10),   # Guard post
		Vector3(20, 0, 20),   # Outskirts
	]

func _load_npc_database():
	"""Load NPC data"""
	npc_database.clear()
	
	# Merchant NPCs
	npc_database.append(NPCData.new(
		"Marcus",
		"merchant",
		spawn_points[2],
		"nomads",
		"Welcome! I have the finest supplies in the wasteland."
	))
	
	# Guard NPCs
	npc_database.append(NPCData.new(
		"Captain Lee",
		"guard",
		spawn_points[3],
		"enclave",
		"Keep your eyes open. Zombies everywhere."
	))
	
	# Survivor NPCs
	npc_database.append(NPCData.new(
		"Sarah",
		"survivor",
		spawn_points[0],
		"nomads",
		"Have you seen any other survivors around?"
	))
	
	# Scientist NPCs
	npc_database.append(NPCData.new(
		"Dr. Evans",
		"scientist",
		spawn_points[4],
		"eden",
		"Fascinating mutations... I need samples for research."
	))

func _spawn_npcs():
	"""Spawn all NPCs in the world"""
	for npc_data in npc_database:
		var npc = NPCCharacter.new()
		npc.name = npc_data.name
		npc.global_position = npc_data.position
		add_child(npc)
		spawned_npcs.append(npc)
		
		print("Spawned NPC: %s (%s)" % [npc_data.name, npc_data.type])

func get_npcs_by_type(npc_type: String) -> Array:
	"""Get all NPCs of a specific type"""
	return spawned_npcs.filter(func(npc): return npc.npc_type == npc_type)

func get_npcs_by_faction(faction: String) -> Array:
	"""Get all NPCs of a specific faction"""
	return spawned_npcs.filter(func(npc): return npc.faction == faction)

func get_nearest_npc(position: Vector3) -> NPCCharacter:
	"""Get nearest NPC to position"""
	var nearest = null
	var nearest_distance = INF
	
	for npc in spawned_npcs:
		var distance = position.distance_to(npc.global_position)
		if distance < nearest_distance:
			nearest = npc
			nearest_distance = distance
	
	return nearest

func spawn_npc(npc_type: String, position: Vector3, faction: String = "nomads") -> NPCCharacter:
	"""Spawn a single NPC"""
	var npc = NPCCharacter.new()
	npc.npc_type = npc_type
	npc.faction = faction
	npc.global_position = position
	add_child(npc)
	spawned_npcs.append(npc)
	
	return npc

func despawn_all():
	"""Remove all spawned NPCs"""
	for npc in spawned_npcs:
		npc.queue_free()
	spawned_npcs.clear()
