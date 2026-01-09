extends Control
class_name WorldMapUI

## World Map UI - Display world map with POI discovery and threats

@onready var container = $VBoxContainer
@onready var title_label = $VBoxContainer/Title
@onready var map_grid = $VBoxContainer/MapScroll/MapGrid
@onready var info_panel = $VBoxContainer/InfoPanel

var world_manager: WorldManager
var world_dynamics: WorldDynamicsSystem
var selected_location: String = ""
var location_buttons: Dictionary = {}

func _ready():
	"""Initialize world map UI"""
	_find_systems()
	_setup_map()
	hide()

func _find_systems():
	"""Find game systems"""
	world_manager = get_tree().get_first_node_in_group("world_manager")
	world_dynamics = get_tree().get_first_node_in_group("world_dynamics")

func _setup_map():
	"""Setup map grid with locations"""
	if not world_manager:
		print("World manager not found!")
		return
	
	_clear_map()
	
	var locations = world_manager.get_all_locations()
	var columns = 3
	
	for i in range(locations.size()):
		var location = locations[i]
		_create_location_button(location, i)

func _create_location_button(location: String, index: int):
	"""Create button for location"""
	var is_discovered = world_manager.is_location_discovered(location)
	var threat = world_manager.get_location_threat(location)
	
	var button = Button.new()
	button.text = location if is_discovered else "???"
	button.custom_minimum_size = Vector2(120, 100)
	button.mouse_entered.connect(func(): _on_location_hovered(location))
	button.pressed.connect(func(): _on_location_selected(location))
	
	# Color based on discovery
	if is_discovered:
		var threat_color = _get_threat_color(threat)
		button.add_theme_color_override("font_color", threat_color)
	else:
		button.add_theme_color_override("font_color", Color.GRAY)
	
	# Biome icon
	var biome = world_manager.get_location_biome(location)
	var emoji = _get_biome_emoji(biome)
	
	if is_discovered:
		button.text = emoji + "\n" + location
	else:
		button.text = "?\n?"
	
	map_grid.add_child(button)
	location_buttons[location] = button

func _on_location_hovered(location: String):
	"""Handle location hover"""
	_update_info_panel(location)

func _on_location_selected(location: String):
	"""Handle location selection"""
	selected_location = location
	world_manager.discover_location(location)
	_update_location_button(location)
	_update_info_panel(location)

func _update_location_button(location: String):
	"""Update button appearance after discovery"""
	if location not in location_buttons:
		return
	
	var button = location_buttons[location]
	var threat = world_manager.get_location_threat(location)
	var biome = world_manager.get_location_biome(location)
	var emoji = _get_biome_emoji(biome)
	
	button.text = emoji + "\n" + location
	button.add_theme_color_override("font_color", _get_threat_color(threat))

func _update_info_panel(location: String):
	"""Update info panel with location details"""
	var is_discovered = world_manager.is_location_discovered(location)
	
	info_panel.clear()
	
	if not is_discovered:
		info_panel.append_text("Location Unknown\n\n")
		info_panel.append_text("Discover this location to learn more.")
		return
	
	var threat = world_manager.get_location_threat(location)
	var biome = world_manager.get_location_biome(location)
	var poi_data = world_manager.get_location_data(location)
	
	# Title
	info_panel.append_text("[b]%s[/b]\n" % location)
	
	# Biome
	info_panel.append_text("Biome: %s\n" % biome)
	
	# Threat level
	var threat_color = "#%s" % _get_threat_color(threat).to_html()
	info_panel.append_text("Threat: [color=%s]%s[/color] (%.1f%%)\n" % [
		threat_color,
		_get_threat_description(threat),
		threat * 100
	])
	
	# Resources
	if poi_data and "resources" in poi_data:
		info_panel.append_text("\n[b]Resources:[/b]\n")
		for resource in poi_data["resources"]:
			info_panel.append_text("  • %s\n" % resource)
	
	# NPCs
	if poi_data and "npcs" in poi_data:
		info_panel.append_text("\n[b]NPCs:[/b]\n")
		for npc in poi_data["npcs"]:
			info_panel.append_text("  • %s\n" % npc)
	
	# Active events
	if world_dynamics:
		var location_state = world_dynamics.get_location_state(location)
		if "active_events" in location_state and location_state["active_events"].size() > 0:
			info_panel.append_text("\n[b][color=red]Active Events:[/color][/b]\n")
			for event in location_state["active_events"]:
				info_panel.append_text("  ⚠️ %s (%.0f%% intensity)\n" % [
					event["type"],
					event["intensity"] * 100
				])
	
	# Hazards
	if world_dynamics:
		var hazards = world_dynamics._get_location_hazards(location)
		if hazards.size() > 0:
			info_panel.append_text("\n[b]Environmental Hazards:[/b]\n")
			for hazard in hazards:
				info_panel.append_text("  • %s\n" % hazard.replace("_", " ").to_title())

func _clear_map():
	"""Clear map grid"""
	for child in map_grid.get_children():
		child.queue_free()
	location_buttons.clear()

func _get_threat_color(threat: float) -> Color:
	"""Get color based on threat level"""
	match true:
		threat < 0.2:
			return Color.GREEN
		threat < 0.4:
			return Color.YELLOW
		threat < 0.6:
			return Color.ORANGE
		threat < 0.8:
			return Color.RED
		_:
			return Color.DARK_RED

func _get_threat_description(threat: float) -> String:
	"""Get threat description"""
	match true:
		threat < 0.2:
			return "Safe"
		threat < 0.4:
			return "Low"
		threat < 0.6:
			return "Moderate"
		threat < 0.8:
			return "High"
		_:
			return "Critical"

func _get_biome_emoji(biome: String) -> String:
	"""Get emoji for biome"""
	match biome:
		"urban":
			return "🏙️"
		"forest":
			return "🌲"
		"desert":
			return "🏜️"
		"mountain":
			return "⛰️"
		"wasteland":
			return "💀"
		_:
			return "📍"

func update_map():
	"""Refresh map display"""
	_setup_map()

func toggle_visibility():
	"""Toggle map visibility"""
	if visible:
		hide()
	else:
		show()

func get_selected_location() -> String:
	"""Get currently selected location"""
	return selected_location
