extends Node
class_name InventorySystem

## Inventory System - Manages player inventory

signal inventory_changed
signal item_added(item_name: String, amount: int)
signal item_removed(item_name: String, amount: int)

var inventory: Dictionary = {}
var max_items: int = 50
var current_items: int = 0

class InventorySlot:
	var item_name: String
	var amount: int
	var max_stack: int
	
	func _init(name: String, amount: int, max_stack: int = 64):
		self.item_name = name
		self.amount = amount
		self.max_stack = max_stack

func _ready():
	"""Initialize inventory with starting items"""
	add_item("water_bottle", 5)
	add_item("food_can", 3)
	add_item("wood_plank", 10)
	print("Inventory initialized")

func add_item(item_name: String, amount: int = 1) -> bool:
	"""Add item to inventory"""
	if current_items + amount > max_items:
		return false
	
	if item_name not in inventory:
		inventory[item_name] = InventorySlot.new(item_name, amount)
	else:
		inventory[item_name].amount += amount
	
	current_items += amount
	item_added.emit(item_name, amount)
	inventory_changed.emit()
	return true

func remove_item(item_name: String, amount: int = 1) -> bool:
	"""Remove item from inventory"""
	if item_name not in inventory:
		return false
	
	if inventory[item_name].amount < amount:
		return false
	
	inventory[item_name].amount -= amount
	current_items -= amount
	
	if inventory[item_name].amount <= 0:
		inventory.erase(item_name)
	
	item_removed.emit(item_name, amount)
	inventory_changed.emit()
	return true

func has_item(item_name: String, amount: int = 1) -> bool:
	"""Check if inventory has item"""
	return item_name in inventory and inventory[item_name].amount >= amount

func get_item_amount(item_name: String) -> int:
	"""Get amount of item in inventory"""
	return inventory[item_name].amount if item_name in inventory else 0

func get_all_items() -> Array:
	"""Get list of all items"""
	return inventory.keys()

func get_inventory_percentage() -> float:
	"""Get inventory fullness percentage"""
	return float(current_items) / max_items

func clear_inventory():
	"""Clear entire inventory"""
	inventory.clear()
	current_items = 0
	inventory_changed.emit()

func drop_item(item_name: String, amount: int = 1) -> bool:
	"""Drop item from inventory"""
	return remove_item(item_name, amount)

func get_inventory_data() -> Dictionary:
	"""Get inventory as dictionary for saving"""
	var data = {}
	for item_name in inventory:
		data[item_name] = inventory[item_name].amount
	return data

func load_inventory_data(data: Dictionary):
	"""Load inventory from dictionary"""
	inventory.clear()
	current_items = 0
	for item_name in data:
		add_item(item_name, data[item_name])
