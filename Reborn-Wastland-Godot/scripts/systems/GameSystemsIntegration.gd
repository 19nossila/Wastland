extends Node
class_name GameSystemsIntegration

## Game Systems Integration - Coordinates all game systems seamlessly

signal all_systems_ready()
signal system_error(system_name: String, error: String)

# Core systems
var game_manager: GameManager
var audio_manager: AudioManager
var effect_manager: EffectManager
var save_system: SaveSystem
var input_manager: InputManager

# Phase 1 systems
var mutation_system: MutationSystem
var faction_system: FactionSystem
var weather_system: WeatherSystem
var drone_system: DroneSystem
var zombie_ai: ZombieAI

# Phase 2 systems
var item_system: ItemSystem
var quest_system: QuestSystem
var building_system: BuildingSystem
var inventory_system: InventorySystem
var dialogue_system: DialogueSystem
var npc_spawner: NPCSpawner
var zombie_spawner: ZombieSpawner

# Phase 3 systems
var loot_system: LootSystem
var biome_manager: BiomeManager
var quest_chain_system: QuestChainSystem
var world_manager: WorldManager
var event_system: EventSystem
var world_dynamics: WorldDynamicsSystem
var mutation_advanced: MutationAdvancedSystem

# UI systems
var hud_manager: HUDManager
var inventory_ui: InventoryUI
var crafting_ui: CraftingUI
var quest_log_ui: QuestLogUI
var dialogue_ui: DialogueUI
var world_map_ui: WorldMapUI

var systems_initialized: int = 0
var total_systems: int = 0

func _ready():
	"""Initialize all systems and coordinate them"""
	_find_all_systems()
	_setup_system_groups()
	_connect_system_signals()
	print("Game systems integration complete: %d/%d systems active" % [systems_initialized, total_systems])

func _find_all_systems():
	"""Find all system nodes in the scene tree"""
	
	# Core managers
	game_manager = get_tree().get_first_node_in_group("game_manager")
	audio_manager = get_tree().get_first_node_in_group("audio_manager")
	effect_manager = get_tree().get_first_node_in_group("effect_manager")
	save_system = get_tree().get_first_node_in_group("save_system")
	input_manager = get_tree().get_first_node_in_group("input_manager")
	
	# Phase 1 systems
	mutation_system = get_tree().get_first_node_in_group("mutation_system")
	faction_system = get_tree().get_first_node_in_group("faction_system")
	weather_system = get_tree().get_first_node_in_group("weather_system")
	drone_system = get_tree().get_first_node_in_group("drone_system")
	zombie_ai = get_tree().get_first_node_in_group("zombie_ai")
	
	# Phase 2 systems
	item_system = get_tree().get_first_node_in_group("item_system")
	quest_system = get_tree().get_first_node_in_group("quest_system")
	building_system = get_tree().get_first_node_in_group("building_system")
	inventory_system = get_tree().get_first_node_in_group("inventory_system")
	dialogue_system = get_tree().get_first_node_in_group("dialogue_system")
	npc_spawner = get_tree().get_first_node_in_group("npc_spawner")
	zombie_spawner = get_tree().get_first_node_in_group("zombie_spawner")
	
	# Phase 3 systems
	loot_system = get_tree().get_first_node_in_group("loot_system")
	biome_manager = get_tree().get_first_node_in_group("biome_manager")
	quest_chain_system = get_tree().get_first_node_in_group("quest_chain_system")
	world_manager = get_tree().get_first_node_in_group("world_manager")
	event_system = get_tree().get_first_node_in_group("event_system")
	world_dynamics = get_tree().get_first_node_in_group("world_dynamics")
	mutation_advanced = get_tree().get_first_node_in_group("mutation_advanced")
	
	# UI systems
	hud_manager = get_tree().get_first_node_in_group("hud_manager")
	inventory_ui = get_tree().get_first_node_in_group("inventory_ui")
	crafting_ui = get_tree().get_first_node_in_group("crafting_ui")
	quest_log_ui = get_tree().get_first_node_in_group("quest_log_ui")
	dialogue_ui = get_tree().get_first_node_in_group("dialogue_ui")
	world_map_ui = get_tree().get_first_node_in_group("world_map_ui")
	
	_count_initialized_systems()

func _count_initialized_systems():
	"""Count how many systems are initialized"""
	var systems = [
		game_manager, audio_manager, effect_manager, save_system, input_manager,
		mutation_system, faction_system, weather_system, drone_system, zombie_ai,
		item_system, quest_system, building_system, inventory_system, dialogue_system,
		npc_spawner, zombie_spawner, loot_system, biome_manager, quest_chain_system,
		world_manager, event_system, world_dynamics, mutation_advanced,
		hud_manager, inventory_ui, crafting_ui, quest_log_ui, dialogue_ui, world_map_ui
	]
	
	for system in systems:
		if system != null:
			systems_initialized += 1
	
	total_systems = systems.size()

func _setup_system_groups():
	"""Ensure all systems are in proper groups for easy finding"""
	var group_assignments = {
		"game_manager": game_manager,
		"audio_manager": audio_manager,
		"effect_manager": effect_manager,
		"save_system": save_system,
		"input_manager": input_manager,
		"mutation_system": mutation_system,
		"faction_system": faction_system,
		"weather_system": weather_system,
		"drone_system": drone_system,
		"zombie_ai": zombie_ai,
		"item_system": item_system,
		"quest_system": quest_system,
		"building_system": building_system,
		"inventory_system": inventory_system,
		"dialogue_system": dialogue_system,
		"npc_spawner": npc_spawner,
		"zombie_spawner": zombie_spawner,
		"loot_system": loot_system,
		"biome_manager": biome_manager,
		"quest_chain_system": quest_chain_system,
		"world_manager": world_manager,
		"event_system": event_system,
		"world_dynamics": world_dynamics,
		"mutation_advanced": mutation_advanced,
		"hud_manager": hud_manager,
		"inventory_ui": inventory_ui,
		"crafting_ui": crafting_ui,
		"quest_log_ui": quest_log_ui,
		"dialogue_ui": dialogue_ui,
		"world_map_ui": world_map_ui
	}
	
	for group_name in group_assignments:
		var system = group_assignments[group_name]
		if system != null and system.is_inside_tree():
			if not system.is_in_group(group_name):
				system.add_to_group(group_name)

func _connect_system_signals():
	"""Connect signals between systems for synchronization"""
	
	# Audio-Event integration
	if audio_manager and event_system:
		event_system.event_triggered.connect(func(event_type, location):
			_on_event_triggered_for_audio(event_type))
	
	# Effects-Event integration
	if effect_manager and event_system:
		event_system.event_triggered.connect(func(event_type, location):
			_on_event_triggered_for_effects(event_type))
	
	# Quest-UI integration
	if quest_system and quest_log_ui:
		quest_system.quest_updated.connect(func(quest_id):
			quest_log_ui.update_display())
	
	# Mutation-UI integration
	if mutation_advanced and hud_manager:
		mutation_advanced.mutation_infected.connect(func(mutation_name):
			hud_manager.show_mutation_alert(mutation_name))
	
	# World-Map UI integration
	if event_system and world_map_ui:
		event_system.event_triggered.connect(func(event_type, location):
			world_map_ui.update_location_status(location))
	
	# Save system integration
	if save_system:
		# Save on quest completion
		if quest_system:
			quest_system.quest_completed.connect(func(quest_id):
				save_system.save_game())
		
		# Save on mutation changes
		if mutation_advanced:
			mutation_advanced.mutation_evolved.connect(func(mutation, old_tier, new_tier):
				save_system.save_game())

func get_system(system_name: String) -> Node:
	"""Get system by name"""
	var systems = {
		"game_manager": game_manager,
		"audio_manager": audio_manager,
		"effect_manager": effect_manager,
		"save_system": save_system,
		"input_manager": input_manager,
		"mutation_system": mutation_system,
		"faction_system": faction_system,
		"weather_system": weather_system,
		"drone_system": drone_system,
		"zombie_ai": zombie_ai,
		"item_system": item_system,
		"quest_system": quest_system,
		"building_system": building_system,
		"inventory_system": inventory_system,
		"dialogue_system": dialogue_system,
		"npc_spawner": npc_spawner,
		"zombie_spawner": zombie_spawner,
		"loot_system": loot_system,
		"biome_manager": biome_manager,
		"quest_chain_system": quest_chain_system,
		"world_manager": world_manager,
		"event_system": event_system,
		"world_dynamics": world_dynamics,
		"mutation_advanced": mutation_advanced,
		"hud_manager": hud_manager,
		"inventory_ui": inventory_ui,
		"crafting_ui": crafting_ui,
		"quest_log_ui": quest_log_ui,
		"dialogue_ui": dialogue_ui,
		"world_map_ui": world_map_ui
	}
	
	if system_name in systems:
		return systems[system_name]
	return null

func _on_event_triggered_for_audio(event_type: String):
	"""Handle audio when events trigger"""
	if not audio_manager:
		return
	
	match event_type:
		"zombie_horde":
			audio_manager.play_sound("alert_horde")
		"anomaly":
			audio_manager.play_sound("alert_anomaly")
		"resource_discovery":
			audio_manager.play_sound("alert_resource")
		"faction_activity":
			audio_manager.play_sound("alert_faction")
		"weather":
			audio_manager.play_sound("weather_warning")

func _on_event_triggered_for_effects(event_type: String):
	"""Handle effects when events trigger"""
	if not effect_manager:
		return
	
	match event_type:
		"zombie_horde":
			effect_manager.play_effect("explosion")
		"anomaly":
			effect_manager.play_effect("mutation")
		"resource_discovery":
			effect_manager.play_effect("heal")

func get_integration_status() -> Dictionary:
	"""Get complete integration status"""
	return {
		"systems_ready": systems_initialized,
		"total_systems": total_systems,
		"ready_percentage": (systems_initialized / float(total_systems)) * 100.0 if total_systems > 0 else 0.0,
		"all_systems_ready": systems_initialized == total_systems,
		"core_systems_ready": game_manager != null and save_system != null,
		"gameplay_systems_ready": mutation_system != null and quest_system != null and faction_system != null,
		"advanced_systems_ready": event_system != null and world_dynamics != null and mutation_advanced != null
	}
