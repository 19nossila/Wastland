extends CanvasLayer
class_name HUDManager

## HUD Manager - Manages all user interface elements

var player: PlayerCharacter
var visible_elements: Dictionary = {}

func _ready():
	_create_ui_elements()

func _create_ui_elements():
	"""Create all UI elements"""
	# Health bar
	var health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.value = 100
	health_bar.min_value = 0
	health_bar.max_value = 100
	health_bar.anchor_left = 0.0
	health_bar.anchor_top = 0.0
	health_bar.anchor_right = 0.2
	health_bar.anchor_bottom = 0.05
	health_bar.offset_left = 10
	health_bar.offset_top = 10
	add_child(health_bar)
	visible_elements["health_bar"] = health_bar
	
	# Hunger bar
	var hunger_bar = ProgressBar.new()
	hunger_bar.name = "HungerBar"
	hunger_bar.value = 50
	hunger_bar.min_value = 0
	hunger_bar.max_value = 100
	hunger_bar.anchor_left = 0.0
	hunger_bar.anchor_top = 0.06
	hunger_bar.anchor_right = 0.2
	hunger_bar.anchor_bottom = 0.11
	hunger_bar.offset_left = 10
	hunger_bar.offset_top = 10
	add_child(hunger_bar)
	visible_elements["hunger_bar"] = hunger_bar
	
	# Thirst bar
	var thirst_bar = ProgressBar.new()
	thirst_bar.name = "ThirstBar"
	thirst_bar.value = 50
	thirst_bar.min_value = 0
	thirst_bar.max_value = 100
	thirst_bar.anchor_left = 0.0
	thirst_bar.anchor_top = 0.12
	thirst_bar.anchor_right = 0.2
	thirst_bar.anchor_bottom = 0.17
	thirst_bar.offset_left = 10
	thirst_bar.offset_top = 10
	add_child(thirst_bar)
	visible_elements["thirst_bar"] = thirst_bar
	
	# Compass/Minimap
	var compass = Label.new()
	compass.name = "Compass"
	compass.text = "N"
	compass.anchor_left = 0.45
	compass.anchor_top = 0.0
	compass.anchor_right = 0.55
	compass.anchor_bottom = 0.05
	compass.alignment = TextServer.HORIZONTAL_ALIGNMENT_CENTER
	add_child(compass)
	visible_elements["compass"] = compass
	
	# Location label
	var location = Label.new()
	location.name = "Location"
	location.text = "Unknown Location"
	location.anchor_left = 0.35
	location.anchor_top = 0.05
	location.anchor_right = 0.65
	location.anchor_bottom = 0.1
	location.alignment = TextServer.HORIZONTAL_ALIGNMENT_CENTER
	add_child(location)
	visible_elements["location"] = location
	
	# Inventory counter
	var inventory_counter = Label.new()
	inventory_counter.name = "InventoryCounter"
	inventory_counter.text = "Items: 0/50"
	inventory_counter.anchor_left = 0.8
	inventory_counter.anchor_top = 0.0
	inventory_counter.anchor_right = 1.0
	inventory_counter.anchor_bottom = 0.05
	inventory_counter.alignment = TextServer.HORIZONTAL_ALIGNMENT_RIGHT
	add_child(inventory_counter)
	visible_elements["inventory_counter"] = inventory_counter
	
	# Mutation indicator
	var mutation_indicator = Label.new()
	mutation_indicator.name = "MutationIndicator"
	mutation_indicator.text = "Mutation: 0%"
	mutation_indicator.anchor_left = 0.8
	mutation_indicator.anchor_top = 0.06
	mutation_indicator.anchor_right = 1.0
	mutation_indicator.anchor_bottom = 0.11
	mutation_indicator.alignment = TextServer.HORIZONTAL_ALIGNMENT_RIGHT
	add_child(mutation_indicator)
	visible_elements["mutation_indicator"] = mutation_indicator
	
	# FPS Counter
	var fps_counter = Label.new()
	fps_counter.name = "FPSCounter"
	fps_counter.text = "FPS: 60"
	fps_counter.anchor_left = 0.0
	fps_counter.anchor_top = 0.95
	fps_counter.anchor_right = 0.1
	fps_counter.anchor_bottom = 1.0
	add_child(fps_counter)
	visible_elements["fps_counter"] = fps_counter
	
	print("HUD initialized with elements")

func _process(delta):
	# Update FPS counter
	if "fps_counter" in visible_elements:
		visible_elements["fps_counter"].text = "FPS: %d" % Engine.get_frames_per_second()

func update_health(value: float):
	"""Update health bar"""
	if "health_bar" in visible_elements:
		visible_elements["health_bar"].value = value

func update_hunger(value: float):
	"""Update hunger bar"""
	if "hunger_bar" in visible_elements:
		visible_elements["hunger_bar"].value = value

func update_thirst(value: float):
	"""Update thirst bar"""
	if "thirst_bar" in visible_elements:
		visible_elements["thirst_bar"].value = value

func update_location(location_text: String):
	"""Update location display"""
	if "location" in visible_elements:
		visible_elements["location"].text = location_text

func update_mutation(mutation_level: float):
	"""Update mutation indicator"""
	if "mutation_indicator" in visible_elements:
		visible_elements["mutation_indicator"].text = "Mutation: %.1f%%" % mutation_level

func update_inventory_count(current: int, max_count: int):
	"""Update inventory counter"""
	if "inventory_counter" in visible_elements:
		visible_elements["inventory_counter"].text = "Items: %d/%d" % [current, max_count]

func show_message(message: String, duration: float = 3.0):
	"""Show temporary message"""
	var message_label = Label.new()
	message_label.text = message
	message_label.anchor_left = 0.25
	message_label.anchor_top = 0.45
	message_label.anchor_right = 0.75
	message_label.anchor_bottom = 0.55
	message_label.alignment = TextServer.HORIZONTAL_ALIGNMENT_CENTER
	add_child(message_label)
	
	# Auto-remove after duration
	await get_tree().create_timer(duration).timeout
	message_label.queue_free()

func show_dialogue(npc_name: String, dialogue_text: String):
	"""Show NPC dialogue"""
	var dialogue_box = PanelContainer.new()
	dialogue_box.name = "DialogueBox"
	dialogue_box.anchor_left = 0.1
	dialogue_box.anchor_top = 0.7
	dialogue_box.anchor_right = 0.9
	dialogue_box.anchor_bottom = 0.95
	
	var text_label = Label.new()
	text_label.text = "%s:\n%s" % [npc_name, dialogue_text]
	text_label.clip_text = true
	text_label.word_wrap_mode = TextServer.WORD_WRAP_WORD
	dialogue_box.add_child(text_label)
	
	add_child(dialogue_box)
	visible_elements["dialogue_box"] = dialogue_box

func hide_dialogue():
	"""Hide dialogue box"""
	if "dialogue_box" in visible_elements:
		visible_elements["dialogue_box"].queue_free()
		visible_elements.erase("dialogue_box")

func show_inventory():
	"""Show inventory panel"""
	var inventory_panel = PanelContainer.new()
	inventory_panel.name = "InventoryPanel"
	inventory_panel.anchor_left = 0.2
	inventory_panel.anchor_top = 0.1
	inventory_panel.anchor_right = 0.8
	inventory_panel.anchor_bottom = 0.9
	
	add_child(inventory_panel)
	visible_elements["inventory_panel"] = inventory_panel

func hide_inventory():
	"""Hide inventory panel"""
	if "inventory_panel" in visible_elements:
		visible_elements["inventory_panel"].queue_free()
		visible_elements.erase("inventory_panel")

func show_crafting_menu():
	"""Show crafting menu"""
	var crafting_panel = PanelContainer.new()
	crafting_panel.name = "CraftingMenu"
	crafting_panel.anchor_left = 0.2
	crafting_panel.anchor_top = 0.1
	crafting_panel.anchor_right = 0.8
	crafting_panel.anchor_bottom = 0.9
	
	add_child(crafting_panel)
	visible_elements["crafting_menu"] = crafting_panel

func hide_crafting_menu():
	"""Hide crafting menu"""
	if "crafting_menu" in visible_elements:
		visible_elements["crafting_menu"].queue_free()
		visible_elements.erase("crafting_menu")
