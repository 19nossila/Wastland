extends Control
class_name DialogueUI

## Dialogue UI - Displays NPC dialogue and options

var dialogue_system: DialogueSystem
var npc_name_label: Label
var dialogue_text_label: Label
var options_container: VBoxContainer
var current_dialogue_data: Dictionary = {}

func _ready():
	"""Initialize dialogue UI"""
	setup_ui()
	hide()

func setup_ui():
	"""Setup dialogue UI elements"""
	# Main dialogue panel
	var panel = PanelContainer.new()
	panel.name = "DialoguePanel"
	panel.anchor_left = 0.15
	panel.anchor_top = 0.6
	panel.anchor_right = 0.85
	panel.anchor_bottom = 0.95
	panel.custom_minimum_size = Vector2(700, 250)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	# NPC name
	npc_name_label = Label.new()
	npc_name_label.text = "NPC Name"
	npc_name_label.add_theme_font_size_override("font_size", 18)
	vbox.add_child(npc_name_label)
	
	# Dialogue text
	dialogue_text_label = Label.new()
	dialogue_text_label.text = "Dialogue text appears here..."
	dialogue_text_label.word_wrap_mode = TextServer.WORD_WRAP_WORD
	dialogue_text_label.custom_minimum_size = Vector2(600, 80)
	vbox.add_child(dialogue_text_label)
	
	# Options container
	options_container = VBoxContainer.new()
	options_container.name = "OptionsContainer"
	options_container.custom_minimum_size = Vector2(600, 100)
	vbox.add_child(options_container)
	
	add_child(panel)

func set_dialogue_system(dialogue_system: DialogueSystem):
	"""Set the dialogue system reference"""
	self.dialogue_system = dialogue_system

func start_dialogue(npc_type: String, npc_name: String):
	"""Start dialogue with NPC"""
	if not dialogue_system:
		return
	
	npc_name_label.text = npc_name
	current_dialogue_data = dialogue_system.start_dialogue(npc_type, npc_name)
	_update_dialogue_display()
	show()

func _update_dialogue_display():
	"""Update dialogue display with current dialogue"""
	if current_dialogue_data.is_empty():
		hide()
		return
	
	dialogue_text_label.text = current_dialogue_data.get("text", "")
	_update_options(current_dialogue_data.get("options", []))

func _update_options(options: Array):
	"""Update dialogue options buttons"""
	# Clear existing options
	for child in options_container.get_children():
		child.queue_free()
	
	# Add new option buttons
	for i in range(options.size()):
		var option = options[i]
		var button = Button.new()
		button.text = option.get("text", "")
		button.pressed.connect(_on_option_selected.bindv([i]))
		options_container.add_child(button)
	
	# Add close button
	var close_button = Button.new()
	close_button.text = "[Close Dialogue]"
	close_button.pressed.connect(_on_dialogue_closed)
	options_container.add_child(close_button)

func _on_option_selected(option_index: int):
	"""Handle option selection"""
	if not dialogue_system:
		return
	
	dialogue_system.select_option(option_index)
	current_dialogue_data = dialogue_system.get_current_dialogue()
	_update_dialogue_display()

func _on_dialogue_closed():
	"""Close dialogue"""
	if dialogue_system:
		dialogue_system.end_dialogue()
	hide()

func is_dialogue_active() -> bool:
	"""Check if dialogue is currently active"""
	return visible and not current_dialogue_data.is_empty()

func get_dialogue_text() -> String:
	"""Get current dialogue text"""
	return dialogue_text_label.text

func get_options_count() -> int:
	"""Get number of current dialogue options"""
	return current_dialogue_data.get("options", []).size()
