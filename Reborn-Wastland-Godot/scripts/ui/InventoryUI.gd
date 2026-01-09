extends Control
class_name InventoryUI

## Inventory UI - Displays and manages player inventory

var inventory_system: InventorySystem
var item_grid: GridContainer
var item_list: ItemList
var selected_item: String = ""

func _ready():
	"""Initialize inventory UI"""
	setup_ui()
	visibility_changed.connect(_on_visibility_changed)

func setup_ui():
	"""Setup inventory UI elements"""
	# Main panel
	var panel = PanelContainer.new()
	panel.name = "InventoryPanel"
	panel.anchor_left = 0.1
	panel.anchor_top = 0.1
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.9
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "INVENTORY"
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Item list
	item_list = ItemList.new()
	item_list.custom_minimum_size = Vector2(300, 400)
	item_list.item_selected.connect(_on_item_selected)
	vbox.add_child(item_list)
	
	# Item details panel
	var details_panel = PanelContainer.new()
	details_panel.name = "ItemDetails"
	details_panel.custom_minimum_size = Vector2(300, 100)
	var details_text = Label.new()
	details_text.text = "Select an item to view details"
	details_text.word_wrap_mode = TextServer.WORD_WRAP_WORD
	details_panel.add_child(details_text)
	vbox.add_child(details_panel)
	
	# Button container
	var button_box = HBoxContainer.new()
	
	var use_button = Button.new()
	use_button.text = "Use Item"
	use_button.pressed.connect(_on_use_item)
	button_box.add_child(use_button)
	
	var drop_button = Button.new()
	drop_button.text = "Drop Item"
	drop_button.pressed.connect(_on_drop_item)
	button_box.add_child(drop_button)
	
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_on_close)
	button_box.add_child(close_button)
	
	vbox.add_child(button_box)
	add_child(panel)

func set_inventory_system(inventory: InventorySystem):
	"""Set the inventory system reference"""
	inventory_system = inventory
	if inventory_system:
		inventory_system.inventory_changed.connect(_on_inventory_changed)
		_update_inventory_display()

func _update_inventory_display():
	"""Update the inventory list display"""
	if not inventory_system or not item_list:
		return
	
	item_list.clear()
	var items = inventory_system.get_all_items()
	
	for item_name in items:
		var amount = inventory_system.get_item_amount(item_name)
		var display_text = "%s x%d" % [item_name.replace("_", " ").to_title(), amount]
		item_list.add_item(display_text)

func _on_item_selected(index: int):
	"""Handle item selection"""
	var items = inventory_system.get_all_items()
	if index < items.size():
		selected_item = items[index]
		_update_item_details()

func _update_item_details():
	"""Update item details panel"""
	if not selected_item or not inventory_system:
		return
	
	var amount = inventory_system.get_item_amount(selected_item)
	var details_text = "Item: %s\nQuantity: %d\n\nUse or drop items from the buttons below." % [
		selected_item.replace("_", " ").to_title(),
		amount
	]
	
	# Find and update details label
	for child in get_children():
		if child is PanelContainer:
			for subchild in child.get_children():
				if subchild is Label:
					subchild.text = details_text

func _on_use_item():
	"""Use the selected item"""
	if not selected_item or not inventory_system:
		return
	
	# Different behaviors for different item types
	match selected_item:
		"food_can":
			inventory_system.remove_item(selected_item, 1)
			print("Ate food can")
		"water_bottle":
			inventory_system.remove_item(selected_item, 1)
			print("Drank water")
		"medical_kit":
			inventory_system.remove_item(selected_item, 1)
			print("Used medical kit")
		_:
			print("Cannot use item: " + selected_item)

func _on_drop_item():
	"""Drop the selected item"""
	if not selected_item or not inventory_system:
		return
	
	inventory_system.drop_item(selected_item, 1)
	_update_inventory_display()
	print("Dropped: " + selected_item)

func _on_close():
	"""Close inventory UI"""
	hide()

func _on_inventory_changed():
	"""Update when inventory changes"""
	_update_inventory_display()

func show_inventory():
	"""Show inventory panel"""
	show()
	_update_inventory_display()

func hide_inventory():
	"""Hide inventory panel"""
	hide()
