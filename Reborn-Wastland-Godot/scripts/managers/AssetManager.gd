extends Node
class_name AssetManager

## Asset Manager - Handles loading, caching, and resource management

signal asset_loaded(asset_path: String, asset: Resource)
signal asset_unloaded(asset_path: String)
signal all_assets_loaded()

var asset_cache: Dictionary = {}
var asset_paths: Dictionary = {}
var loading_queue: Array = []
var assets_loaded: int = 0
var total_assets: int = 0

func _ready():
	"""Initialize asset manager"""
	add_to_group("asset_manager")
	_setup_asset_paths()
	print("Asset manager initialized")

func _setup_asset_paths():
	"""Setup default asset paths"""
	asset_paths = {
		# Audio assets
		"audio_ambient_forest": "res://assets/audio/ambient/forest.ogg",
		"audio_ambient_desert": "res://assets/audio/ambient/desert.ogg",
		"audio_ambient_mountain": "res://assets/audio/ambient/mountain.ogg",
		"audio_ambient_urban": "res://assets/audio/ambient/urban.ogg",
		"audio_ambient_wasteland": "res://assets/audio/ambient/wasteland.ogg",
		
		"audio_music_main": "res://assets/audio/music/main_theme.ogg",
		"audio_music_combat": "res://assets/audio/music/combat_theme.ogg",
		"audio_music_exploration": "res://assets/audio/music/exploration_theme.ogg",
		"audio_music_boss": "res://assets/audio/music/boss_theme.ogg",
		
		"audio_alert_horde": "res://assets/audio/sfx/alert_horde.ogg",
		"audio_alert_anomaly": "res://assets/audio/sfx/alert_anomaly.ogg",
		"audio_alert_resource": "res://assets/audio/sfx/alert_resource.ogg",
		"audio_alert_faction": "res://assets/audio/sfx/alert_faction.ogg",
		"audio_weather_warning": "res://assets/audio/sfx/weather_warning.ogg",
		
		"audio_step_concrete": "res://assets/audio/sfx/step_concrete.ogg",
		"audio_step_dirt": "res://assets/audio/sfx/step_dirt.ogg",
		"audio_step_metal": "res://assets/audio/sfx/step_metal.ogg",
		
		"audio_weapon_laser": "res://assets/audio/sfx/weapon_laser.ogg",
		"audio_weapon_rifle": "res://assets/audio/sfx/weapon_rifle.ogg",
		"audio_weapon_melee": "res://assets/audio/sfx/weapon_melee.ogg",
		
		# Effect assets (as scene references)
		"effect_hit_blue": "res://assets/effects/hit_blue.tscn",
		"effect_hit_red": "res://assets/effects/hit_red.tscn",
		"effect_blood": "res://assets/effects/blood.tscn",
		"effect_mutation": "res://assets/effects/mutation.tscn",
		"effect_heal": "res://assets/effects/heal.tscn",
		"effect_damage": "res://assets/effects/damage.tscn",
		"effect_fire": "res://assets/effects/fire.tscn",
		"effect_electric": "res://assets/effects/electric.tscn",
		"effect_frost": "res://assets/effects/frost.tscn",
		"effect_poison": "res://assets/effects/poison.tscn",
		"effect_explosion": "res://assets/effects/explosion.tscn",
		"effect_smoke": "res://assets/effects/smoke.tscn",
		"effect_dust": "res://assets/effects/dust.tscn",
		
		# UI assets
		"ui_panel_dark": "res://assets/ui/panel_dark.tres",
		"ui_panel_light": "res://assets/ui/panel_light.tres",
		"ui_button_normal": "res://assets/ui/button_normal.tres",
		"ui_button_hover": "res://assets/ui/button_hover.tres",
		"ui_font_default": "res://assets/fonts/default.tres",
		"ui_font_large": "res://assets/fonts/large.tres",
		
		# 3D models
		"model_player": "res://assets/models/player.tscn",
		"model_zombie": "res://assets/models/zombie.tscn",
		"model_drone": "res://assets/models/drone.tscn",
		"model_weapon": "res://assets/models/weapon.tscn",
		
		# Textures
		"texture_ground_urban": "res://assets/textures/ground_urban.png",
		"texture_ground_forest": "res://assets/textures/ground_forest.png",
		"texture_ground_desert": "res://assets/textures/ground_desert.png",
		"texture_ground_mountain": "res://assets/textures/ground_mountain.png",
		"texture_ground_wasteland": "res://assets/textures/ground_wasteland.png",
	}
	
	total_assets = asset_paths.size()

func preload_all_assets():
	"""Preload all assets"""
	print("Starting preload of %d assets..." % total_assets)
	
	for asset_key in asset_paths:
		loading_queue.append(asset_key)
	
	_load_next_asset()

func preload_asset(asset_key: String) -> bool:
	"""Preload specific asset"""
	if asset_key not in asset_paths:
		print("Asset not found: %s" % asset_key)
		return false
	
	if asset_key in asset_cache:
		return true
	
	return _load_asset(asset_key)

func _load_next_asset():
	"""Load next asset in queue"""
	if loading_queue.size() == 0:
		print("All assets preloaded: %d/%d" % [assets_loaded, total_assets])
		all_assets_loaded.emit()
		return
	
	var asset_key = loading_queue.pop_front()
	_load_asset(asset_key)
	
	# Load next frame
	await get_tree().process_frame
	_load_next_asset()

func _load_asset(asset_key: String) -> bool:
	"""Load specific asset"""
	if asset_key not in asset_paths:
		return false
	
	var asset_path = asset_paths[asset_key]
	
	# Check if already cached
	if asset_key in asset_cache:
		return true
	
	# Try to load
	var resource = null
	
	try:
		if asset_path.ends_with(".ogg") or asset_path.ends_with(".mp3") or asset_path.ends_with(".wav"):
			resource = load(asset_path)
		elif asset_path.ends_with(".tscn"):
			resource = load(asset_path)
		elif asset_path.ends_with(".tres"):
			resource = load(asset_path)
		elif asset_path.ends_with(".png") or asset_path.ends_with(".jpg"):
			resource = load(asset_path)
		else:
			resource = load(asset_path)
		
		if resource:
			asset_cache[asset_key] = resource
			assets_loaded += 1
			asset_loaded.emit(asset_path, resource)
			return true
	except:
		print("Failed to load asset: %s (%s)" % [asset_key, asset_path])
	
	return false

func get_asset(asset_key: String) -> Resource:
	"""Get cached asset"""
	if asset_key not in asset_cache:
		if not _load_asset(asset_key):
			print("Unable to get asset: %s" % asset_key)
			return null
	
	return asset_cache.get(asset_key, null)

func get_audio_stream(audio_key: String) -> AudioStream:
	"""Get audio stream by key"""
	var asset = get_asset(audio_key)
	if asset and asset is AudioStream:
		return asset
	return null

func get_scene(scene_key: String) -> PackedScene:
	"""Get scene by key"""
	var asset = get_asset(scene_key)
	if asset and asset is PackedScene:
		return asset
	return null

func get_texture(texture_key: String) -> Texture2D:
	"""Get texture by key"""
	var asset = get_asset(texture_key)
	if asset and asset is Texture2D:
		return asset
	return null

func release_asset(asset_key: String):
	"""Release cached asset"""
	if asset_key in asset_cache:
		asset_cache.erase(asset_key)
		asset_unloaded.emit(asset_key)

func release_all_assets():
	"""Release all cached assets"""
	asset_cache.clear()
	print("All assets released")

func get_cache_size() -> int:
	"""Get number of cached assets"""
	return asset_cache.size()

func get_memory_usage() -> String:
	"""Estimate memory usage of cached assets"""
	var total_size = 0
	
	for asset_key in asset_cache:
		var resource = asset_cache[asset_key]
		if resource is AudioStream:
			# Rough estimate: audio size
			total_size += 1024 * 50  # ~50KB per audio
		elif resource is Texture2D:
			# Rough estimate: texture memory
			var texture = resource as Texture2D
			total_size += (texture.get_width() * texture.get_height() * 4)
	
	var size_mb = total_size / (1024.0 * 1024.0)
	return "%.2f MB" % size_mb

func register_custom_asset(asset_key: String, asset_path: String):
	"""Register custom asset path"""
	asset_paths[asset_key] = asset_path
	total_assets = asset_paths.size()

func get_asset_statistics() -> Dictionary:
	"""Get asset loading statistics"""
	return {
		"total_assets": total_assets,
		"loaded_assets": assets_loaded,
		"cached_assets": asset_cache.size(),
		"load_percentage": (assets_loaded / float(total_assets)) * 100.0 if total_assets > 0 else 0.0,
		"memory_usage": get_memory_usage(),
		"queue_size": loading_queue.size()
	}

func validate_assets() -> Dictionary:
	"""Validate all configured assets exist"""
	var results = {
		"valid": 0,
		"missing": [],
		"invalid": []
	}
	
	for asset_key in asset_paths:
		var asset_path = asset_paths[asset_key]
		
		if ResourceLoader.exists(asset_path):
			results["valid"] += 1
		else:
			results["missing"].append({
				"key": asset_key,
				"path": asset_path
			})
	
	return results

func create_missing_placeholder_assets():
	"""Create placeholder assets for missing files (for testing)"""
	print("Creating placeholder assets for testing...")
	
	# This is called when assets are missing, to prevent errors during development
	# In production, actual assets would be present
	
	# Create dummy audio streams
	var dummy_audio = AudioStreamWAV.new()
	dummy_audio.format = AudioStreamWAV.FORMAT_8_BIT
	dummy_audio.mix_rate = 44100
	dummy_audio.stereo = false
	
	# Create dummy textures
	var dummy_texture = Image.new()
	dummy_texture.create(64, 64, false, Image.FORMAT_RGB8)
	
	print("Placeholder assets ready for development")
