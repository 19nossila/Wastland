extends Node
class_name BuildingSystem

## Building System - Manages base construction and structures

const BUILDING_TYPES = {
	"wall": {
		"name": "Wall",
		"health": 100,
		"cost": {"wood_plank": 10, "metal_scrap": 5},
		"size": Vector3(1, 2, 0.1)
	},
	"door": {
		"name": "Door",
		"health": 50,
		"cost": {"wood_plank": 15, "metal_scrap": 8},
		"size": Vector3(1, 2, 0.1)
	},
	"roof": {
		"name": "Roof",
		"health": 80,
		"cost": {"wood_plank": 20, "metal_scrap": 10},
		"size": Vector3(1, 0.1, 1)
	},
	"floor": {
		"name": "Floor",
		"health": 150,
		"cost": {"wood_plank": 15, "metal_scrap": 10},
		"size": Vector3(1, 0.1, 1)
	},
	"workbench": {
		"name": "Workbench",
		"health": 100,
		"cost": {"wood_plank": 20, "metal_scrap": 15},
		"size": Vector3(1, 1, 1),
		"functional": true
	},
	"furnace": {
		"name": "Furnace",
		"health": 150,
		"cost": {"metal_scrap": 50, "stone": 100},
		"size": Vector3(1, 2, 1),
		"functional": true
	},
	"storage": {
		"name": "Storage Box",
		"health": 80,
		"cost": {"wood_plank": 15, "metal_scrap": 10},
		"size": Vector3(1, 1, 1),
		"functional": true,
		"capacity": 100
	},
	"bed": {
		"name": "Bed",
		"health": 50,
		"cost": {"wood_plank": 10, "cloth": 10},
		"size": Vector3(2, 0.5, 1),
		"functional": true,
		"rest_bonus": 0.5
	}
}

class Structure:
	var structure_id: String
	var building_type: String
	var position: Vector3
	var rotation: float
	var health: float
	var max_health: float
	var owner_id: int
	var inventory: Array = []
	
	func _init(id: String, type: String, pos: Vector3):
		structure_id = id
		building_type = type
		position = pos
		rotation = 0.0
		max_health = BUILDING_TYPES[type]["health"]
		health = max_health

var all_structures: Dictionary = {}  # structure_id -> Structure
var structure_id_counter: int = 0
var player_bases: Dictionary = {}  # player_id -> [structure_ids]

func _ready():
	pass

func place_structure(player_id: int, building_type: String, position: Vector3) -> String:
	"""Place a structure at location"""
	if building_type not in BUILDING_TYPES:
		push_error("Unknown building type: %s" % building_type)
		return ""
	
	structure_id_counter += 1
	var structure_id = "struct_%d" % structure_id_counter
	
	var structure = Structure.new(structure_id, building_type, position)
	structure.owner_id = player_id
	
	all_structures[structure_id] = structure
	
	if player_id not in player_bases:
		player_bases[player_id] = []
	player_bases[player_id].append(structure_id)
	
	print("Structure placed: %s (%s)" % [structure.building_type, structure_id])
	return structure_id

func damage_structure(structure_id: String, damage: float):
	"""Damage a structure"""
	if structure_id not in all_structures:
		return
	
	var structure = all_structures[structure_id]
	structure.health = max(0, structure.health - damage)
	
	if structure.health <= 0:
		destroy_structure(structure_id)

func destroy_structure(structure_id: String):
	"""Destroy a structure"""
	if structure_id not in all_structures:
		return
	
	var structure = all_structures[structure_id]
	var owner_id = structure.owner_id
	
	all_structures.erase(structure_id)
	
	if owner_id in player_bases:
		player_bases[owner_id].erase(structure_id)
	
	print("Structure destroyed: %s" % structure_id)

func repair_structure(structure_id: String, repair_amount: float):
	"""Repair a structure"""
	if structure_id not in all_structures:
		return
	
	var structure = all_structures[structure_id]
	structure.health = min(structure.max_health, structure.health + repair_amount)

func get_structure_data(structure_id: String) -> Dictionary:
	"""Get structure information"""
	if structure_id not in all_structures:
		return {}
	
	var structure = all_structures[structure_id]
	var building_data = BUILDING_TYPES[structure.building_type]
	
	return {
		"id": structure.structure_id,
		"type": structure.building_type,
		"name": building_data["name"],
		"position": structure.position,
		"health": structure.health,
		"max_health": structure.max_health,
		"owner": structure.owner_id,
		"condition": (structure.health / structure.max_health) * 100.0
	}

func get_player_structures(player_id: int) -> Array:
	"""Get all structures owned by player"""
	return player_bases.get(player_id, [])

func add_to_storage(structure_id: String, item: String, quantity: int) -> bool:
	"""Add item to storage structure"""
	if structure_id not in all_structures:
		return false
	
	var structure = all_structures[structure_id]
	var building_data = BUILDING_TYPES[structure.building_type]
	
	if "capacity" not in building_data:
		return false
	
	structure.inventory.append({
		"item": item,
		"quantity": quantity
	})
	
	return true

func remove_from_storage(structure_id: String, item: String, quantity: int) -> bool:
	"""Remove item from storage"""
	if structure_id not in all_structures:
		return false
	
	var structure = all_structures[structure_id]
	
	for inv_item in structure.inventory:
		if inv_item["item"] == item and inv_item["quantity"] >= quantity:
			inv_item["quantity"] -= quantity
			return true
	
	return false

func get_storage_contents(structure_id: String) -> Array:
	"""Get contents of storage"""
	if structure_id not in all_structures:
		return []
	
	return all_structures[structure_id].inventory

func get_building_cost(building_type: String) -> Dictionary:
	"""Get cost to build structure"""
	if building_type not in BUILDING_TYPES:
		return {}
	
	return BUILDING_TYPES[building_type]["cost"]

func can_build(building_type: String, inventory: Dictionary) -> bool:
	"""Check if player has resources to build"""
	var cost = get_building_cost(building_type)
	
	for item in cost:
		if inventory.get(item, 0) < cost[item]:
			return false
	
	return true
