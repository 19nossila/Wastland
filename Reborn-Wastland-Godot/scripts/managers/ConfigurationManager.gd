extends Node
class_name ConfigurationManager

## Configuration Manager - Handles all game configuration and settings

var game_config: Dictionary = {}
var audio_config: Dictionary = {}
var graphics_config: Dictionary = {}
var gameplay_config: Dictionary = {}
var debug_config: Dictionary = {}

var config_file_path: String = "user://wastland_config.json"

func _ready():
	"""Initialize configuration"""
	add_to_group("config_manager")
	_load_default_configs()
	_load_user_config()
	print("Configuration manager initialized")

func _load_default_configs():
	"""Load default configurations"""
	
	# Game config
	game_config = {
		"game_version": "0.8",
		"game_name": "Wastland Reborn",
		"language": "en",
		"difficulty": "normal",  # easy, normal, hard, impossible
		"auto_save_enabled": true,
		"auto_save_interval": 300,  # 5 minutes
		"max_save_slots": 10
	}
	
	# Audio config
	audio_config = {
		"master_volume": 1.0,  # 0.0 to 1.0
		"music_volume": 0.7,
		"sfx_volume": 0.8,
		"ambient_volume": 0.6,
		"voice_volume": 0.9,
		"enable_3d_audio": true,
		"enable_audio_attenuation": true,
		"audio_pool_size": 32,
		"audio_fade_duration": 1.0
	}
	
	# Graphics config
	graphics_config = {
		"resolution": Vector2i(1920, 1080),
		"fullscreen": false,
		"vsync_enabled": true,
		"target_fps": 60,
		"shadow_quality": "high",  # low, medium, high, ultra
		"shadow_distance": 50.0,
		"particle_quality": "high",  # low, medium, high
		"particle_max_count": 5000,
		"effect_quality": "high",
		"ambient_occlusion": true,
		"bloom_enabled": true,
		"motion_blur": false,
		"fov": 75.0
	}
	
	# Gameplay config
	gameplay_config = {
		"difficulty_multiplier": 1.0,
		"zombie_spawn_rate": 1.0,
		"loot_multiplier": 1.0,
		"xp_multiplier": 1.0,
		"reputation_multiplier": 1.0,
		"mutation_resistance_base": 0.0,
		"friendly_fire": false,
		"permadeath_enabled": false,
		"ironman_mode": false,
		"tutorial_enabled": true,
		"show_crosshair": true,
		"show_damage_numbers": true,
		"auto_pickup_enabled": true,
		"auto_pickup_radius": 2.0
	}
	
	# Debug config
	debug_config = {
		"debug_mode": false,
		"show_fps_counter": false,
		"show_console": false,
		"show_hitboxes": false,
		"show_ai_vision": false,
		"show_performance_stats": false,
		"log_level": "info",  # debug, info, warning, error
		"enable_network_debug": false,
		"spawn_test_zombies": false,
		"spawn_test_npcs": false,
		"give_all_items": false,
		"unlimited_resources": false
	}

func _load_user_config():
	"""Load user configuration from file"""
	if ResourceLoader.exists(config_file_path):
		var json = JSON.new()
		var content = FileAccess.get_file_as_string(config_file_path)
		
		if json.parse(content) == OK:
			var data = json.get_data()
			
			if "audio" in data:
				audio_config.merge(data["audio"])
			if "graphics" in data:
				graphics_config.merge(data["graphics"])
			if "gameplay" in data:
				gameplay_config.merge(data["gameplay"])
			if "debug" in data:
				debug_config.merge(data["debug"])
			
			print("User configuration loaded")

func save_config():
	"""Save current configuration to file"""
	var config_data = {
		"game": game_config,
		"audio": audio_config,
		"graphics": graphics_config,
		"gameplay": gameplay_config,
		"debug": debug_config
	}
	
	var json_string = JSON.stringify(config_data)
	var file = FileAccess.open(config_file_path, FileAccess.WRITE)
	
	if file:
		file.store_string(json_string)
		print("Configuration saved to %s" % config_file_path)
	else:
		print("Failed to save configuration")

# Audio getters/setters
func get_master_volume() -> float:
	return audio_config.get("master_volume", 1.0)

func set_master_volume(volume: float):
	audio_config["master_volume"] = clamp(volume, 0.0, 1.0)
	_apply_audio_settings()

func get_music_volume() -> float:
	return audio_config.get("music_volume", 0.7) * get_master_volume()

func set_music_volume(volume: float):
	audio_config["music_volume"] = clamp(volume, 0.0, 1.0)
	_apply_audio_settings()

func get_sfx_volume() -> float:
	return audio_config.get("sfx_volume", 0.8) * get_master_volume()

func set_sfx_volume(volume: float):
	audio_config["sfx_volume"] = clamp(volume, 0.0, 1.0)
	_apply_audio_settings()

# Graphics getters/setters
func get_resolution() -> Vector2i:
	return graphics_config.get("resolution", Vector2i(1920, 1080))

func set_resolution(resolution: Vector2i):
	graphics_config["resolution"] = resolution
	_apply_graphics_settings()

func is_fullscreen() -> bool:
	return graphics_config.get("fullscreen", false)

func set_fullscreen(enabled: bool):
	graphics_config["fullscreen"] = enabled
	_apply_graphics_settings()

# Gameplay getters
func get_difficulty_multiplier() -> float:
	return gameplay_config.get("difficulty_multiplier", 1.0)

func get_zombie_spawn_rate() -> float:
	return gameplay_config.get("zombie_spawn_rate", 1.0)

func get_loot_multiplier() -> float:
	return gameplay_config.get("loot_multiplier", 1.0)

func is_permadeath_enabled() -> bool:
	return gameplay_config.get("permadeath_enabled", false)

func is_ironman_enabled() -> bool:
	return gameplay_config.get("ironman_mode", false)

# Debug getters
func is_debug_mode() -> bool:
	return debug_config.get("debug_mode", false)

func should_show_fps() -> bool:
	return debug_config.get("show_fps_counter", false)

func should_show_hitboxes() -> bool:
	return debug_config.get("show_hitboxes", false) and is_debug_mode()

func get_log_level() -> String:
	return debug_config.get("log_level", "info")

func _apply_audio_settings():
	"""Apply audio settings to the engine"""
	# This would be called by AudioManager to apply settings
	pass

func _apply_graphics_settings():
	"""Apply graphics settings to the engine"""
	var resolution = get_resolution()
	var window = get_window()
	
	window.size = resolution
	window.mode = DisplayServer.WINDOW_MODE_FULLSCREEN if is_fullscreen() else DisplayServer.WINDOW_MODE_WINDOWED

func get_all_config() -> Dictionary:
	"""Get all configuration"""
	return {
		"game": game_config,
		"audio": audio_config,
		"graphics": graphics_config,
		"gameplay": gameplay_config,
		"debug": debug_config
	}

func reset_to_defaults():
	"""Reset all configuration to defaults"""
	_load_default_configs()
	save_config()
	print("Configuration reset to defaults")

func get_difficulty_description() -> String:
	"""Get human-readable difficulty description"""
	var difficulty = game_config.get("difficulty", "normal")
	
	match difficulty:
		"easy":
			return "Easy - Fewer zombies, more resources"
		"normal":
			return "Normal - Balanced gameplay"
		"hard":
			return "Hard - More threats, less resources"
		"impossible":
			return "Impossible - Extreme survival challenge"
		_:
			return "Unknown difficulty"

func validate_config() -> Dictionary:
	"""Validate configuration values"""
	var issues = []
	
	if audio_config["master_volume"] < 0.0 or audio_config["master_volume"] > 1.0:
		issues.append("Invalid master volume")
	
	if graphics_config["target_fps"] < 30 or graphics_config["target_fps"] > 240:
		issues.append("Invalid target FPS")
	
	if gameplay_config["difficulty_multiplier"] < 0.5 or gameplay_config["difficulty_multiplier"] > 3.0:
		issues.append("Invalid difficulty multiplier")
	
	return {
		"valid": issues.size() == 0,
		"issues": issues
	}

func print_config_summary():
	"""Print configuration summary to console"""
	print("\n=== WASTLAND CONFIGURATION ===")
	print("Game: %s v%s" % [game_config["game_name"], game_config["game_version"]])
	print("Difficulty: %s" % game_config["difficulty"])
	print("Resolution: %s" % get_resolution())
	print("Master Volume: %.0f%%" % (get_master_volume() * 100))
	print("Debug Mode: %s" % is_debug_mode())
	print("===============================\n")
