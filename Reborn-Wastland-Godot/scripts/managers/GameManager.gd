extends Node

## Game Manager - Central hub for all game systems
## Handles initialization, game state, and system coordination

var game_state: String = "menu"  # menu, loading, playing, paused, game_over
var current_season: String = "spring"
var current_day: int = 0
var game_time: float = 0.0  # In-game time

# System references
var mutation_system: MutationSystem
var faction_system: FactionSystem
var weather_system: WeatherSystem
var drone_system: DroneSystem
var item_system: ItemSystem
var quest_system: QuestSystem
var building_system: BuildingSystem
var inventory_system: InventorySystem
var dialogue_system: DialogueSystem
var hud_manager: HUDManager
var player: PlayerCharacter

# Configuration
var quality_preset: String = "low"  # very_low, low, medium, high

func _ready():
	set_multiplayer_authority(1)
	_initialize_systems()
	_load_configuration()

func _initialize_systems():
	"""Initialize all game systems"""
	mutation_system = MutationSystem.new()
	add_child(mutation_system)
	
	faction_system = FactionSystem.new()
	add_child(faction_system)
	
	weather_system = WeatherSystem.new()
	add_child(weather_system)
	
	drone_system = DroneSystem.new()
	add_child(drone_system)
	
	item_system = ItemSystem.new()
	add_child(item_system)
	
	quest_system = QuestSystem.new()
	add_child(quest_system)
	
	building_system = BuildingSystem.new()
	add_child(building_system)
	
	inventory_system = InventorySystem.new()
	add_child(inventory_system)
	
	dialogue_system = DialogueSystem.new()
	add_child(dialogue_system)
	
	hud_manager = HUDManager.new()
	add_child(hud_manager)
	
	print("All systems initialized")

func _load_configuration():
	"""Load game configuration based on hardware"""
	var ram_gb = OS.get_static_memory_usage() / (1024 * 1024 * 1024)
	var processor_count = OS.get_processor_count()
	
	if ram_gb < 4.5 or processor_count < 2:
		quality_preset = "very_low"
	elif ram_gb < 8 or processor_count < 4:
		quality_preset = "low"
	elif ram_gb < 16:
		quality_preset = "medium"
	else:
		quality_preset = "high"
	
	print("Quality preset: %s (RAM: %.1f GB, Cores: %d)" % [quality_preset, ram_gb, processor_count])
	_apply_quality_settings()

func _apply_quality_settings():
	"""Apply graphics settings based on quality preset"""
	match quality_preset:
		"very_low":
			get_tree().root.get_window().size = Vector2i(720, 540)
			RenderingServer.global_shader_parameter("fog_distance", 50.0)
		"low":
			get_tree().root.get_window().size = Vector2i(1024, 768)
			RenderingServer.global_shader_parameter("fog_distance", 100.0)
		"medium":
			get_tree().root.get_window().size = Vector2i(1280, 720)
			RenderingServer.global_shader_parameter("fog_distance", 200.0)
		"high":
			get_tree().root.get_window().size = Vector2i(1920, 1080)
			RenderingServer.global_shader_parameter("fog_distance", 400.0)

func _process(delta):
	if game_state == "playing":
		game_time += delta
		_update_day_cycle()
		_update_season_cycle()

func _update_day_cycle():
	"""Update day/night cycle"""
	var day_length = 1800.0  # 30 minutes per in-game day
	var cycle_progress = fmod(game_time, day_length) / day_length
	
	# Update lighting based on time
	if get_tree().root.get_node_or_null("DirectionalLight3D"):
		var sun = get_tree().root.get_node("DirectionalLight3D")
		sun.rotation.x = lerp(-PI/2, PI/2, cycle_progress)

func _update_season_cycle():
	"""Update season progression"""
	var season_length = 45 * 1800.0  # 45 in-game days per season
	var total_cycle = season_length * 4
	var cycle_progress = fmod(game_time, total_cycle)
	
	var season_index = int(cycle_progress / season_length)
	var seasons = ["spring", "summer", "autumn", "winter"]
	current_season = seasons[season_index]
	current_day = int(cycle_progress / 1800.0)

func get_quality_config(setting: String):
	"""Get configuration value for current quality preset"""
	var configs = {
		"very_low": {
			"max_zombies": 30,
			"render_distance": 100,
			"particle_count": 0,
			"shadow_quality": 256,
			"fog_distance": 50
		},
		"low": {
			"max_zombies": 50,
			"render_distance": 150,
			"particle_count": 50,
			"shadow_quality": 512,
			"fog_distance": 100
		},
		"medium": {
			"max_zombies": 80,
			"render_distance": 250,
			"particle_count": 100,
			"shadow_quality": 1024,
			"fog_distance": 200
		},
		"high": {
			"max_zombies": 150,
			"render_distance": 500,
			"particle_count": 200,
			"shadow_quality": 2048,
			"fog_distance": 400
		}
	}
	
	return configs[quality_preset].get(setting, 0)

@rpc("authority")
func sync_game_state():
	"""Synchronize game state across network"""
	if not is_multiplayer_authority():
		return
	
	var state = {
		"time": game_time,
		"season": current_season,
		"day": current_day
	}
	
	rpc("receive_game_state", state)

@rpc
func receive_game_state(state: Dictionary):
	"""Receive game state from authority"""
	game_time = state["time"]
	current_season = state["season"]
	current_day = state["day"]
