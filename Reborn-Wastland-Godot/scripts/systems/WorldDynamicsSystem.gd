extends Node
class_name WorldDynamicsSystem

## World Dynamics System - Connects all world systems for immersive gameplay

signal world_state_changed(new_state: Dictionary)
signal location_threat_level_changed(location: String, threat: float)
signal npc_migration_triggered(from_location: String, to_location: String)

var world_manager: WorldManager
var event_system: EventSystem
var game_manager: GameManager
var biome_manager: BiomeManager
var npc_spawner: NPCSpawner
var zombie_spawner: ZombieSpawner

var world_time: float = 0.0
var day_night_cycle: float = 0.0  # 0 = night, 0.5 = day, 1.0 = night
var season: int = 0  # 0-3: spring, summer, autumn, winter
var world_threat_level: float = 0.5

var location_history: Dictionary = {}
var dynamic_difficulty_multiplier: float = 1.0

func _ready():
	"""Initialize world dynamics"""
	_find_systems()
	print("World dynamics system initialized")

func _process(delta):
	"""Update world dynamics"""
	world_time += delta
	day_night_cycle = fmod(world_time / 3600.0, 1.0)  # 1 hour = full cycle
	
	# Update threat levels every 10 seconds
	if int(world_time) % 10 == 0:
		_update_threat_levels()
	
	# Check for random events every 30 seconds
	if int(world_time) % 30 == 0:
		_check_random_events()
	
	# Update world state every 60 seconds
	if int(world_time) % 60 == 0:
		_update_world_state()

func _find_systems():
	"""Find all necessary systems"""
	world_manager = get_tree().get_first_node_in_group("world_manager")
	event_system = get_tree().get_first_node_in_group("event_system")
	game_manager = get_tree().get_first_node_in_group("game_manager")
	biome_manager = get_tree().get_first_node_in_group("biome_manager")
	npc_spawner = get_tree().get_first_node_in_group("npc_spawner")
	zombie_spawner = get_tree().get_first_node_in_group("zombie_spawner")

func get_current_world_state() -> Dictionary:
	"""Get comprehensive world state"""
	var active_events = event_system.get_active_events() if event_system else []
	var location_count = world_manager.get_location_count() if world_manager else 0
	var threat_avg = _calculate_average_threat()
	
	return {
		"world_time": world_time,
		"day_night_cycle": day_night_cycle,
		"is_day": day_night_cycle < 0.5,
		"is_night": day_night_cycle >= 0.5,
		"season": _get_season_name(season),
		"threat_level": world_threat_level,
		"threat_description": _get_threat_description(),
		"average_location_threat": threat_avg,
		"active_events": active_events.size(),
		"discovered_locations": location_count,
		"difficulty_multiplier": dynamic_difficulty_multiplier
	}

func _update_threat_levels():
	"""Update threat level for each location"""
	if not world_manager:
		return
	
	# Threat increases at night
	var time_multiplier = 1.0 if day_night_cycle >= 0.5 else 0.7
	
	# Base world threat
	world_threat_level = 0.3 + (0.4 * sin(world_time / 600.0))  # Oscillates 0.3-0.7
	world_threat_level *= time_multiplier
	
	# Update difficulty multiplier
	dynamic_difficulty_multiplier = 1.0 + (world_threat_level * 0.5)
	
	location_threat_level_changed.emit("world", world_threat_level)

func _check_random_events():
	"""Check if random events should trigger"""
	if not event_system or not world_manager:
		return
	
	# Random event every 5-10 minutes
	if randf() < 0.15:  # ~15% chance per check
		var locations = world_manager.get_all_locations()
		if locations.size() > 0:
			var location = locations[randi() % locations.size()]
			var event_type = _select_random_event_type()
			event_system.trigger_event(event_type, location, world_threat_level)

func _select_random_event_type() -> String:
	"""Select random event type based on probabilities"""
	var roll = randf()
	
	match true:
		roll < 0.4:  # 40%
			return "zombie_horde"
		roll < 0.65:  # 25%
			return "resource_discovery"
		roll < 0.8:  # 15%
			return "anomaly"
		roll < 0.9:  # 10%
			return "faction_activity"
		_:  # 10%
			return "weather"

func _update_world_state():
	"""Update overall world state"""
	var new_state = get_current_world_state()
	world_state_changed.emit(new_state)
	
	# Potentially trigger NPC migration
	if randf() < 0.1:  # 10% chance per minute
		_trigger_npc_migration()

func _trigger_npc_migration():
	"""Trigger NPC migration between locations"""
	if not world_manager or not npc_spawner:
		return
	
	var locations = world_manager.get_all_locations()
	if locations.size() < 2:
		return
	
	var from_location = locations[randi() % locations.size()]
	var to_location = locations[randi() % locations.size()]
	
	while to_location == from_location and locations.size() > 1:
		to_location = locations[randi() % locations.size()]
	
	npc_migration_triggered.emit(from_location, to_location)
	print("NPC migration: %s -> %s" % [from_location, to_location])

func _calculate_average_threat() -> float:
	"""Calculate average threat level across discovered locations"""
	if not world_manager:
		return 0.5
	
	var total_threat = 0.0
	var location_count = 0
	
	var locations = world_manager.get_all_locations()
	for location in locations:
		if world_manager.is_location_discovered(location):
			total_threat += world_manager.get_location_threat(location)
			location_count += 1
	
	if location_count == 0:
		return 0.5
	
	return total_threat / location_count

func get_location_state(location: String) -> Dictionary:
	"""Get current state of specific location"""
	if not world_manager:
		return {}
	
	var threat = world_manager.get_location_threat(location)
	var active_events = []
	
	if event_system:
		for event in event_system.get_active_events():
			if event["location"] == location:
				active_events.append(event)
	
	return {
		"location": location,
		"threat_level": threat,
		"adjusted_threat": threat * dynamic_difficulty_multiplier,
		"is_day": day_night_cycle < 0.5,
		"active_events": active_events,
		"environmental_hazards": _get_location_hazards(location)
	}

func _get_location_hazards(location: String) -> Array:
	"""Get environmental hazards for location"""
	if not biome_manager:
		return []
	
	var biome = world_manager.get_location_biome(location) if world_manager else "urban"
	var hazards = []
	
	match biome:
		"forest":
			hazards = ["dense_fog", "wild_animals", "toxic_plants"]
		"desert":
			hazards = ["sandstorm", "extreme_heat", "dehydration"]
		"mountain":
			hazards = ["avalanche", "extreme_cold", "altitude_sickness"]
		"wasteland":
			hazards = ["radiation", "toxic_clouds", "unstable_ground"]
		"urban":
			hazards = ["collapsed_buildings", "fires", "contaminated_water"]
	
	return hazards

func _get_season_name(season_idx: int) -> String:
	"""Get season name"""
	match season_idx % 4:
		0:
			return "spring"
		1:
			return "summer"
		2:
			return "autumn"
		3:
			return "winter"
		_:
			return "unknown"

func _get_threat_description() -> String:
	"""Get human-readable threat description"""
	match true:
		world_threat_level < 0.3:
			return "Safe"
		world_threat_level < 0.5:
			return "Caution"
		world_threat_level < 0.7:
			return "Danger"
		_:
			return "Critical"

func advance_season():
	"""Advance game season"""
	season = (season + 1) % 4
	print("Season advanced to: %s" % _get_season_name(season))
	
	# Trigger season-based events
	if event_system:
		match season:
			1:  # Summer
				event_system.trigger_weather_event("heat_wave", "wasteland")
			2:  # Autumn
				event_system.trigger_weather_event("storm", "forest")
			3:  # Winter
				event_system.trigger_weather_event("blizzard", "mountain")

func simulate_time(hours: int):
	"""Simulate passage of time (for testing)"""
	world_time += hours * 3600.0
	print("Time advanced by %d hours. Total: %.0f seconds" % [hours, world_time])

func get_system_status() -> Dictionary:
	"""Get status of all connected systems"""
	return {
		"world_manager_ready": world_manager != null,
		"event_system_ready": event_system != null,
		"game_manager_ready": game_manager != null,
		"biome_manager_ready": biome_manager != null,
		"npc_spawner_ready": npc_spawner != null,
		"zombie_spawner_ready": zombie_spawner != null,
		"world_time": world_time,
		"systems_count": 6
	}
