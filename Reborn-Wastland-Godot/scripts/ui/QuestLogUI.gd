extends Control
class_name QuestLogUI

## Quest Log UI - Displays and manages quests

var quest_system: QuestSystem
var quest_list: ItemList
var selected_quest_id: String = ""

func _ready():
	"""Initialize quest log UI"""
	setup_ui()
	visibility_changed.connect(_on_visibility_changed)

func setup_ui():
	"""Setup quest log UI elements"""
	# Main panel
	var panel = PanelContainer.new()
	panel.name = "QuestLogPanel"
	panel.anchor_left = 0.1
	panel.anchor_top = 0.1
	panel.anchor_right = 0.9
	panel.anchor_bottom = 0.9
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# Title
	var title = Label.new()
	title.text = "QUEST LOG"
	title.add_theme_font_size_override("font_size", 24)
	vbox.add_child(title)
	
	# Quest list
	quest_list = ItemList.new()
	quest_list.custom_minimum_size = Vector2(400, 300)
	quest_list.item_selected.connect(_on_quest_selected)
	vbox.add_child(quest_list)
	
	# Quest details panel
	var details_panel = PanelContainer.new()
	details_panel.name = "QuestDetails"
	details_panel.custom_minimum_size = Vector2(400, 200)
	var details_text = Label.new()
	details_text.name = "DetailsText"
	details_text.text = "Select a quest to view details"
	details_text.word_wrap_mode = TextServer.WORD_WRAP_WORD
	details_panel.add_child(details_text)
	vbox.add_child(details_panel)
	
	# Button container
	var button_box = HBoxContainer.new()
	
	var accept_button = Button.new()
	accept_button.text = "Accept Quest"
	accept_button.pressed.connect(_on_accept_quest)
	button_box.add_child(accept_button)
	
	var complete_button = Button.new()
	complete_button.text = "Complete Quest"
	complete_button.pressed.connect(_on_complete_quest)
	button_box.add_child(complete_button)
	
	var close_button = Button.new()
	close_button.text = "Close"
	close_button.pressed.connect(_on_close)
	button_box.add_child(close_button)
	
	vbox.add_child(button_box)
	add_child(panel)

func set_quest_system(quest_system: QuestSystem):
	"""Set the quest system reference"""
	self.quest_system = quest_system
	_update_quest_list()

func _update_quest_list():
	"""Update the quest list display"""
	if not quest_system or not quest_list:
		return
	
	quest_list.clear()
	var all_quests = quest_system.get_all_quests()
	
	for quest in all_quests:
		var status_text = " [%s]" % quest.status
		var display_text = "%s%s" % [quest.title, status_text]
		quest_list.add_item(display_text)

func _on_quest_selected(index: int):
	"""Handle quest selection"""
	var all_quests = quest_system.get_all_quests()
	if index < all_quests.size():
		var quest = all_quests[index]
		selected_quest_id = quest.quest_id
		_update_quest_details(quest)

func _update_quest_details(quest):
	"""Update quest details panel"""
	if not quest:
		return
	
	var details_text = "Quest: %s\n" % quest.title
	details_text += "Giver: %s\n\n" % quest.giver
	details_text += "Description:\n%s\n\n" % quest.description
	details_text += "Objectives:\n"
	
	for objective in quest.objectives:
		var progress = ""
		if "current" in objective and "target" in objective:
			progress = " (%d/%d)" % [objective.current, objective.target]
		details_text += "- %s%s\n" % [objective.text, progress]
	
	details_text += "\nRewards:\n"
	details_text += "- XP: %d\n" % quest.reward_xp
	details_text += "- Reputation: +%d\n" % quest.reward_reputation
	if quest.reward_items.size() > 0:
		details_text += "- Items: %s\n" % ", ".join(quest.reward_items)
	
	# Find and update details label
	for child in get_children():
		if child is PanelContainer:
			for subchild in child.get_children():
				if subchild.name == "DetailsText":
					subchild.text = details_text

func _on_accept_quest():
	"""Accept the selected quest"""
	if not selected_quest_id or not quest_system:
		return
	
	quest_system.accept_quest(selected_quest_id)
	_update_quest_list()
	print("Accepted quest: " + selected_quest_id)

func _on_complete_quest():
	"""Complete the selected quest"""
	if not selected_quest_id or not quest_system:
		return
	
	quest_system.complete_quest(selected_quest_id)
	_update_quest_list()
	print("Completed quest: " + selected_quest_id)

func _on_close():
	"""Close quest log UI"""
	hide()

func _on_visibility_changed():
	"""Update when visibility changes"""
	if visible:
		_update_quest_list()

func show_quest_log():
	"""Show quest log panel"""
	show()
	_update_quest_list()

func hide_quest_log():
	"""Hide quest log panel"""
	hide()

func update_quest_progress(quest_id: String, objective_index: int, progress: int):
	"""Update progress for a specific objective"""
	if not quest_system:
		return
	
	quest_system.update_progress(quest_id, objective_index, progress)
	_update_quest_list()
