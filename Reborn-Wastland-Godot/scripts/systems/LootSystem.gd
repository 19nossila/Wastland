extends Node
class_name LootSystem

## Loot System - Manages zombie drops and item spawning

var loot_tables: Dictionary = {}
var spawned_loot: Array = []

class LootDrop:
	var item_name: String
	var quantity: int
	var drop_chance: float  # 0.0 to 1.0
	
	func _init(item: String, qty: int, chance: float):
		item_name = item
		quantity = qty
		drop_chance = chance

func _ready():
	"""Initialize loot system"""
	_create_loot_tables()
	print("Loot system initialized")

func _create_loot_tables():
	"""Create loot tables for different zombie types"""
	
	# Drifter loot table
	loot_tables["drifter"] = [
		LootDrop.new("metal_scrap", 1, 0.6),
		LootDrop.new("cloth", 1, 0.4),
		LootDrop.new("wood_plank", 1, 0.3),
	]
	
	# Runner loot table
	loot_tables["runner"] = [
		LootDrop.new("metal_scrap", 2, 0.7),
		LootDrop.new("ammo_9mm", 5, 0.3),
		LootDrop.new("cloth", 2, 0.5),
	]
	
	# Mutant loot table
	loot_tables["mutant"] = [
		LootDrop.new("leather", 2, 0.6),
		LootDrop.new("circuit", 1, 0.4),
		LootDrop.new("medical_kit", 1, 0.2),
	]
	
	# Camouflaged loot table
	loot_tables["camouflaged"] = [
		LootDrop.new("circuit", 2, 0.7),
		LootDrop.new("metal_scrap", 3, 0.8),
		LootDrop.new("battery", 1, 0.3),
	]
	
	# Frozen loot table (mountain zombies)
	loot_tables["frozen"] = [
		LootDrop.new("metal_scrap", 1, 0.5),
		LootDrop.new("leather", 1, 0.4),
		LootDrop.new("ammo_rifle", 5, 0.2),
	]

func generate_loot(zombie_type: String) -> Array:
	"""Generate loot for killed zombie"""
	var drops = []
	
	if zombie_type not in loot_tables:
		return drops
	
	var loot_table = loot_tables[zombie_type]
	
	for loot_drop in loot_table:
		if randf() < loot_drop.drop_chance:
			drops.append({
				"item": loot_drop.item_name,
				"quantity": loot_drop.quantity
			})
	
	return drops

func spawn_loot_on_ground(position: Vector3, zombie_type: String):
	"""Spawn loot items on the ground"""
	var drops = generate_loot(zombie_type)
	
	for drop in drops:
		var item_node = Node3D.new()
		item_node.name = drop["item"]
		item_node.global_position = position + Vector3(randf_range(-2, 2), 1, randf_range(-2, 2))
		
		# Store loot data for pickup
		item_node.set_meta("item_name", drop["item"])
		item_node.set_meta("item_quantity", drop["quantity"])
		
		spawned_loot.append(item_node)

func get_drops_by_type(zombie_type: String) -> Array:
	"""Get all possible drops for zombie type"""
	if zombie_type not in loot_tables:
		return []
	
	var drops = []
	for loot_drop in loot_tables[zombie_type]:
		drops.append(loot_drop.item_name)
	
	return drops

func add_custom_loot_table(zombie_type: String, drops: Array):
	"""Add custom loot table"""
	loot_tables[zombie_type] = drops

func clear_spawned_loot():
	"""Clear all spawned loot"""
	for loot in spawned_loot:
		if is_instance_valid(loot):
			loot.queue_free()
	spawned_loot.clear()
