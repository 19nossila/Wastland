extends Node
class_name ItemSystem

## Item System - Manages items, inventory, and crafting

const ITEMS = {
	"metal_scrap": {
		"name": "Metal Scrap",
		"type": "material",
		"weight": 0.1,
		"value": 5,
		"description": "Recyclable metal pieces"
	},
	"wood_plank": {
		"name": "Wood Plank",
		"type": "material",
		"weight": 0.2,
		"value": 3,
		"description": "Cut wood for building"
	},
	"circuit": {
		"name": "Electronic Circuit",
		"type": "material",
		"weight": 0.05,
		"value": 20,
		"description": "Advanced electronic component"
	},
	"battery": {
		"name": "Battery",
		"type": "material",
		"weight": 0.3,
		"value": 15,
		"description": "Rechargeable power cell"
	},
	"cloth": {
		"name": "Cloth",
		"type": "material",
		"weight": 0.1,
		"value": 2,
		"description": "Fabric for clothing"
	},
	"leather": {
		"name": "Leather",
		"type": "material",
		"weight": 0.15,
		"value": 8,
		"description": "Animal hide"
	},
	"food_can": {
		"name": "Canned Food",
		"type": "food",
		"weight": 0.3,
		"value": 10,
		"hunger_restore": 30,
		"description": "Preserved food"
	},
	"water_bottle": {
		"name": "Water Bottle",
		"type": "drink",
		"weight": 0.5,
		"value": 5,
		"thirst_restore": 40,
		"description": "Purified drinking water"
	},
	"medical_kit": {
		"name": "Medical Kit",
		"type": "medical",
		"weight": 0.4,
		"value": 30,
		"health_restore": 50,
		"description": "First aid supplies"
	},
	"pistol": {
		"name": "Pistol",
		"type": "weapon",
		"weight": 1.0,
		"value": 80,
		"damage": 15,
		"description": "Semi-automatic pistol"
	},
	"rifle": {
		"name": "Rifle",
		"type": "weapon",
		"weight": 2.5,
		"value": 150,
		"damage": 30,
		"description": "Bolt-action rifle"
	},
	"ammo_9mm": {
		"name": "9mm Ammo",
		"type": "ammo",
		"weight": 0.01,
		"value": 1,
		"description": "Ammunition for pistols"
	},
	"ammo_rifle": {
		"name": "Rifle Ammo",
		"type": "ammo",
		"weight": 0.02,
		"value": 2,
		"description": "Ammunition for rifles"
	}
}

const RECIPES = {
	"workbench": {
		"name": "Workbench",
		"type": "structure",
		"requires": {
			"wood_plank": 20,
			"metal_scrap": 10,
			"cloth": 5
		},
		"produces": "workbench",
		"time": 60.0
	},
	"furnace": {
		"name": "Furnace",
		"type": "structure",
		"requires": {
			"metal_scrap": 50,
			"stone": 100,
			"wood_plank": 20
		},
		"produces": "furnace",
		"time": 120.0
	},
	"storage_box": {
		"name": "Storage Box",
		"type": "structure",
		"requires": {
			"wood_plank": 15,
			"metal_scrap": 5,
			"cloth": 3
		},
		"produces": "storage_box",
		"time": 30.0
	},
	"repair_pistol": {
		"name": "Repair Pistol",
		"type": "crafting",
		"requires": {
			"metal_scrap": 5,
			"leather": 2
		},
		"produces": "pistol",
		"time": 15.0
	}
}

var all_items: Dictionary = {}  # Tracks all items on ground
var item_id_counter: int = 0

func _ready():
	pass

func drop_item(item_name: String, position: Vector3, quantity: int = 1):
	"""Drop item at location"""
	if item_name not in ITEMS:
		push_error("Unknown item: %s" % item_name)
		return null
	
	item_id_counter += 1
	var item_id = "item_%d" % item_id_counter
	
	all_items[item_id] = {
		"name": item_name,
		"position": position,
		"quantity": quantity,
		"data": ITEMS[item_name]
	}
	
	return item_id

func pickup_item(item_id: String) -> Dictionary:
	"""Pick up item"""
	if item_id not in all_items:
		return {}
	
	var item = all_items[item_id]
	all_items.erase(item_id)
	return item

func get_item_data(item_name: String) -> Dictionary:
	"""Get item properties"""
	return ITEMS.get(item_name, {})

func get_recipe(recipe_name: String) -> Dictionary:
	"""Get crafting recipe"""
	return RECIPES.get(recipe_name, {})

func can_craft(recipe_name: String, inventory: Dictionary) -> bool:
	"""Check if recipe can be crafted"""
	if recipe_name not in RECIPES:
		return false
	
	var recipe = RECIPES[recipe_name]
	for item_name in recipe["requires"]:
		var required = recipe["requires"][item_name]
		var available = inventory.get(item_name, 0)
		if available < required:
			return false
	
	return true

func craft_item(recipe_name: String, inventory: Dictionary) -> bool:
	"""Craft item, consume materials"""
	if not can_craft(recipe_name, inventory):
		return false
	
	var recipe = RECIPES[recipe_name]
	
	# Consume materials
	for item_name in recipe["requires"]:
		inventory[item_name] -= recipe["requires"][item_name]
	
	# Add product
	var product = recipe["produces"]
	if product not in inventory:
		inventory[product] = 0
	inventory[product] += 1
	
	return true

func get_all_recipes() -> Array:
	"""Get all available recipes"""
	return RECIPES.keys()
