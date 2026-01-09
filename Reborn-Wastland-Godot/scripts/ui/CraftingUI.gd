extends Control
class_name CraftingUI

## Crafting UI - Displays and manages crafting recipes

var item_system: ItemSystem
var inventory_system: InventorySystem
var recipe_list: ItemList
var selected_recipe: String = ""

func _ready():
	"""Initialize crafting UI"""
	setup_ui()
	visibility_changed.connect(_on_visibility_changed)

func setup_ui():
	"""Setup crafting UI elements"""
	# Main panel
	var panel = PanelContainer.new()
	panel.name = "CraftingPanel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.1
	panel.anchor_right = 0.9
	panel.anchor_bottom = 0.9
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "CRAFTING"
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Recipe list
	recipe_list = ItemList.new()
	recipe_list.custom_minimum_size = Vector2(300, 400)
	recipe_list.item_selected.connect(_on_recipe_selected)
	vbox.add_child(recipe_list)
	
	# Recipe details panel
	var details_panel = PanelContainer.new()
	details_panel.name = "RecipeDetails"
	details_panel.custom_minimum_size = Vector2(300, 100)
	var details_text = Label.new()
	details_text.name = "DetailsText"
	details_text.text = "Select a recipe to view details"
	details_text.word_wrap_mode = TextServer.WORD_WRAP_WORD
	details_panel.add_child(details_text)
	vbox.add_child(details_panel)
	
	# Button container
	var button_box = HBoxContainer.new()
	
	var craft_button = Button.new()
	craft_button.text = "Craft"
	craft_button.pressed.connect(_on_craft)
	button_box.add_child(craft_button)
	
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_on_close)
	button_box.add_child(close_button)
	
	vbox.add_child(button_box)
	add_child(panel)

func set_systems(item_system: ItemSystem, inventory: InventorySystem):
	"""Set system references"""
	self.item_system = item_system
	self.inventory_system = inventory
	_update_recipe_list()

func _update_recipe_list():
	"""Update the recipe list display"""
	if not item_system or not recipe_list:
		return
	
	recipe_list.clear()
	var recipes = item_system.get_all_recipes()
	
	for recipe_name in recipes:
		recipe_list.add_item(recipe_name.replace("_", " ").to_title())

func _on_recipe_selected(index: int):
	"""Handle recipe selection"""
	var recipes = item_system.get_all_recipes()
	if index < recipes.size():
		selected_recipe = recipes[index]
		_update_recipe_details()

func _update_recipe_details():
	"""Update recipe details panel"""
	if not selected_recipe or not item_system:
		return
	
	var recipe = item_system.get_recipe(selected_recipe)
	var details_text = "Recipe: %s\n\n" % selected_recipe.replace("_", " ").to_title()
	
	# Add ingredients
	details_text += "Ingredients:\n"
	for ingredient in recipe.keys():
		var amount = recipe[ingredient]
		var have = inventory_system.get_item_amount(ingredient) if inventory_system else 0
		var color = "00ff00" if have >= amount else "ff0000"
		details_text += "- %s: %d/%d\n" % [ingredient.replace("_", " ").to_title(), have, amount]
	
	# Find and update details label
	for child in get_children():
		if child is PanelContainer:
			for subchild in child.get_children():
				if subchild.name == "DetailsText":
					subchild.text = details_text

func _on_craft():
	"""Craft the selected recipe"""
	if not selected_recipe or not item_system or not inventory_system:
		return
	
	var recipe = item_system.get_recipe(selected_recipe)
	var can_craft = true
	
	# Check if we have all ingredients
	for ingredient in recipe.keys():
		var amount = recipe[ingredient]
		if inventory_system.get_item_amount(ingredient) < amount:
			can_craft = false
			break
	
	if not can_craft:
		print("Not enough ingredients to craft: " + selected_recipe)
		return
	
	# Remove ingredients
	for ingredient in recipe.keys():
		var amount = recipe[ingredient]
		inventory_system.remove_item(ingredient, amount)
	
	# Add crafted item
	inventory_system.add_item(selected_recipe, 1)
	print("Crafted: " + selected_recipe)
	_update_recipe_details()

func _on_close():
	"""Close crafting UI"""
	hide()

func _on_visibility_changed():
	"""Update when visibility changes"""
	if visible:
		_update_recipe_list()

func show_crafting():
	"""Show crafting panel"""
	show()
	_update_recipe_list()

func hide_crafting():
	"""Hide crafting panel"""
	hide()
