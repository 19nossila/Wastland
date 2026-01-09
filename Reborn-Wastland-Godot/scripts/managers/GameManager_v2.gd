extends Node

## Enhanced Game Manager - Central hub with asset integration

class_name GameManager_v2

signal game_started
signal game_paused
signal game_resumed
signal game_over

var game_state: String = "menu"  # menu, loading, playing, paused, game_over
var current_season: String = "spring"
var current_day: int = 0
var game_time: float = 0.0  # In-game time (minutes)
var game_speed: float = 1.0  # Time multiplier

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

# Asset systems
var asset_importer: AssetImporter
var fbx_converter: FBXConverter
var material_manager: MaterialManager
var world_builder: WorldBuilder

# Player reference
var player: PlayerCharacter_v2
var zombies: Array = []

# Configuration
var quality_preset: String = "low"  # very_low, low, medium, high
var max_zombies: int = 20
var difficulty_multiplier: float = 1.0

# Game statistics
var enemies_killed: int = 0
var items_collected: int = 0
var time_played: float = 0.0

func _ready():
	set_multiplayer_authority(1)
	print("🎮 Game Manager v2 initializing...")
	
	_initialize_asset_systems()
	_initialize_gameplay_systems()
	_load_configuration()
	_build_world()
	_start_game()

## Initialize asset management systems
func _initialize_asset_systems() -> void:
	print("📦 Initializing asset systems...")
	
	asset_importer = AssetImporter.new()
	add_child(asset_importer)
	
	fbx_converter = FBXConverter.new()
	add_child(fbx_converter)
	
	material_manager = MaterialManager.new()
	add_child(material_manager)
	
	print("✅ Asset systems ready")

## Initialize gameplay systems
func _initialize_gameplay_systems() -> void:
	print("🎮 Initializing gameplay systems...")
	
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
	
	print("✅ Gameplay systems ready")

## Load configuration based on hardware
func _load_configuration() -> void:
	var available_ram = OS.get_static_memory_usage() / (1024.0 * 1024.0 * 1024.0)
	var processor_count = OS.get_processor_count()
	
	# Auto-detect quality preset
	if available_ram < 4.5 or processor_count < 2:
		quality_preset = "very_low"
		max_zombies = 5
		difficulty_multiplier = 0.7
	elif available_ram < 8 or processor_count < 4:
		quality_preset = "low"
		max_zombies = 10
		difficulty_multiplier = 0.85
	elif available_ram < 16:
		quality_preset = "medium"
		max_zombies = 15
		difficulty_multiplier = 1.0
	else:
		quality_preset = "high"
		max_zombies = 20
		difficulty_multiplier = 1.2
	
	_apply_quality_settings()
	print("🎮 Quality: %s | RAM: %.1f GB | Cores: %d | Max Zombies: %d" % [quality_preset, available_ram, processor_count, max_zombies])

## Apply graphics settings
func _apply_quality_settings() -> void:
	match quality_preset:
		"very_low":
			get_tree().root.get_window().size = Vector2i(800, 600)
			RenderingServer.rendering_method_set_quality_levels(1)
		"low":
			get_tree().root.get_window().size = Vector2i(1024, 768)
			RenderingServer.rendering_method_set_quality_levels(2)
		"medium":
			get_tree().root.get_window().size = Vector2i(1280, 720)
			RenderingServer.rendering_method_set_quality_levels(3)
		"high":
			get_tree().root.get_window().size = Vector2i(1920, 1080)
			RenderingServer.rendering_method_set_quality_levels(4)

## Build game world
func _build_world() -> void:
	print("🌍 Building world...")
	
	world_builder = WorldBuilder.new()
	add_child(world_builder)
	
	# Get or create player
	var player_scene_path = "res://scenes/Player.tscn"
	if ResourceLoader.exists(player_scene_path):
		var player_scene = load(player_scene_path)
		player = player_scene.instantiate()
		add_child(player)
		print("✅ Player spawned")
	else:
		print("⚠️ Player scene not found")
	
	# Spawn initial zombies
	_spawn_zombies(5)

## Spawn zombies
func _spawn_zombies(count: int) -> void:
	randomize()
	
	for i in range(min(count, max_zombies)):
		var pos = Vector3(
			randf_range(-50, 50),
			1,
			randf_range(-50, 50)
		)
		
		var zombie_scene_path = "res://scenes/Enemies.tscn"
		if ResourceLoader.exists(zombie_scene_path):
			var enemies_scene = load(zombie_scene_path)
			var enemies = enemies_scene.instantiate()
			add_child(enemies)
			enemies.position = pos
			zombies.append(enemies)
	
	print("✅ Spawned %d zombies" % count)

## Start game
func _start_game() -> void:
	game_state = "playing"
	game_started.emit()
	print("🎮 Game started!")

## Pause game
func pause_game() -> void:
	if game_state == "playing":
		game_state = "paused"
		get_tree().paused = true
		game_paused.emit()
		print("⏸️ Game paused")

## Resume game
func resume_game() -> void:
	if game_state == "paused":
		game_state = "playing"
		get_tree().paused = false
		game_resumed.emit()
		print("▶️ Game resumed")

## End game
func end_game(victory: bool = false) -> void:
	game_state = "game_over"
	get_tree().paused = true
	game_over.emit()
	print("💀 Game Over! Victory: %s" % victory)

func _process(delta):
	if game_state != "playing":
		return
	
	# Update game time
	game_time += delta * game_speed
	time_played += delta
	
	# Advance season every 60 minutes of game time
	var day = int(game_time / 60.0)
	if day != current_day:
		current_day = day
		_advance_season()
	
	# Spawn more zombies over time (progressive difficulty)
	if zombies.size() < max_zombies and randi() % 100 < 5:
		_spawn_zombies(1)
	
	# Update HUD
	if hud_manager:
		hud_manager.update_time(game_time)

## Advance to next season
func _advance_season() -> void:
	var seasons = ["spring", "summer", "autumn", "winter"]
	var season_index = seasons.find(current_season)
	current_season = seasons[(season_index + 1) % seasons.size()]
	
	print("🌍 New season: %s (Day %d)" % [current_season.capitalize(), current_day])
	
	if weather_system:
		weather_system.set_season(current_season)

## Report enemy killed
func report_enemy_killed() -> void:
	enemies_killed += 1
	print("💀 Enemies killed: %d" % enemies_killed)

## Report item collected
func report_item_collected(item_name: String) -> void:
	items_collected += 1
	print("📦 Items collected: %d (%s)" % [items_collected, item_name])

## Get game info
func get_game_info() -> Dictionary:
	return {
		"state": game_state,
		"time": game_time,
		"day": current_day,
		"season": current_season,
		"quality": quality_preset,
		"enemies_killed": enemies_killed,
		"items_collected": items_collected,
		"time_played": time_played,
		"difficulty": difficulty_multiplier
	}

## Get player info
func get_player_info() -> Dictionary:
	if player:
		return player.get_player_info()
	return {}

## Quit game
func quit_game() -> void:
	print("👋 Quitting game...")
	get_tree().quit()
