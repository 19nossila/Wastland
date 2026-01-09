extends Node
class_name InputManager

## Input Manager - Handles all player inputs and menu controls

signal inventory_toggled
signal crafting_toggled
signal quest_log_toggled
signal pause_toggled

var inventory_ui: InventoryUI
var crafting_ui: CraftingUI
var quest_log_ui: QuestLogUI
var dialogue_ui: DialogueUI

func _ready():
	"""Initialize input manager"""
	_setup_input_map()
	print("Input manager initialized")

func _setup_input_map():
	"""Setup custom input actions"""
	if not InputMap.has_action("inventory"):
		InputMap.add_action("inventory")
		InputMap.action_add_event("inventory", InputEventKey.new())
		InputMap.action_get_events("inventory")[0].keycode = KEY_I
	
	if not InputMap.has_action("crafting"):
		InputMap.add_action("crafting")
		InputMap.action_add_event("crafting", InputEventKey.new())
		InputMap.action_get_events("crafting")[0].keycode = KEY_C
	
	if not InputMap.has_action("quest_log"):
		InputMap.add_action("quest_log")
		InputMap.action_add_event("quest_log", InputEventKey.new())
		InputMap.action_get_events("quest_log")[0].keycode = KEY_Q
	
	if not InputMap.has_action("pause"):
		InputMap.add_action("pause")
		InputMap.action_add_event("pause", InputEventKey.new())
		InputMap.action_get_events("pause")[0].keycode = KEY_ESCAPE

func _process(delta):
	"""Handle input events"""
	if Input.is_action_just_pressed("inventory"):
		_toggle_inventory()
	
	if Input.is_action_just_pressed("crafting"):
		_toggle_crafting()
	
	if Input.is_action_just_pressed("quest_log"):
		_toggle_quest_log()
	
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

func set_ui_references(inventory: InventoryUI, crafting: CraftingUI, quest_log: QuestLogUI, dialogue: DialogueUI):
	"""Set references to UI systems"""
	inventory_ui = inventory
	crafting_ui = crafting
	quest_log_ui = quest_log
	dialogue_ui = dialogue

func _toggle_inventory():
	"""Toggle inventory UI"""
	if inventory_ui:
		if inventory_ui.visible:
			inventory_ui.hide_inventory()
		else:
			inventory_ui.show_inventory()
		inventory_toggled.emit()

func _toggle_crafting():
	"""Toggle crafting UI"""
	if crafting_ui:
		if crafting_ui.visible:
			crafting_ui.hide_crafting()
		else:
			crafting_ui.show_crafting()
		crafting_toggled.emit()

func _toggle_quest_log():
	"""Toggle quest log UI"""
	if quest_log_ui:
		if quest_log_ui.visible:
			quest_log_ui.hide_quest_log()
		else:
			quest_log_ui.show_quest_log()
		quest_log_toggled.emit()

func _toggle_pause():
	"""Toggle pause menu"""
	get_tree().paused = !get_tree().paused
	pause_toggled.emit()

func is_menu_open() -> bool:
	"""Check if any menu is open"""
	return (inventory_ui and inventory_ui.visible) or \
	       (crafting_ui and crafting_ui.visible) or \
	       (quest_log_ui and quest_log_ui.visible)

func close_all_menus():
	"""Close all open menus"""
	if inventory_ui:
		inventory_ui.hide_inventory()
	if crafting_ui:
		crafting_ui.hide_crafting()
	if quest_log_ui:
		quest_log_ui.hide_quest_log()

func is_dialogue_active() -> bool:
	"""Check if dialogue is currently active"""
	return dialogue_ui and dialogue_ui.is_dialogue_active()
