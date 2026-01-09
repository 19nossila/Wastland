extends Node
## SoundEffectsSystem - Complete sound effects integration

class_name SoundEffectsSystem

var asset_base_path := "res://assets/Survival 3D/"

# Sound effect categories
var sound_effects: Dictionary = {
	"ui": {},
	"combat": {},
	"environment": {},
	"enemies": {},
	"items": {},
	"ambient": {}
}

var audio_players: Dictionary = {}
var active_sounds: Array = []

func _ready() -> void:
	print("🔊 SoundEffectsSystem initializing...")
	_load_all_sounds()
	_setup_audio_buses()

## Load all available sounds from assets
func _load_all_sounds() -> void:
	print("📦 Loading sound effects...")
	
	# UI Sounds
	sound_effects["ui"] = {
		"click_1": "Icon Sprites/Additional Asset Sprites/UI_Pack2/Bonus/click1.ogg",
		"click_2": "Icon Sprites/Additional Asset Sprites/UI_Pack2/Bonus/click2.ogg",
		"rollover_1": "Icon Sprites/Additional Asset Sprites/UI_Pack2/Bonus/rollover1.ogg",
		"rollover_2": "Icon Sprites/Additional Asset Sprites/UI_Pack2/Bonus/rollover2.ogg",
		"switch_2": "Icon Sprites/Additional Asset Sprites/UI_Pack2/Bonus/switch2.ogg",
		"switch_3": "Icon Sprites/Additional Asset Sprites/UI_Pack2/Bonus/switch3.ogg",
	}
	
	# Combat Sounds
	sound_effects["combat"] = {
		"sword_hit": "Sounds/swordHitSound.wav",
		"zombie_attack": "Sounds/zombieAttackSound.mp3",
		"wolf_attack": "Sounds/wolfAttackSoundd.mp3",
		"bear_attack": "Sounds/bearAttackSound.mp3",
	}
	
	# Environment Sounds
	sound_effects["environment"] = {
		"woodcutting": "Sounds/woodcutting.wav",
		"fireplace_loop": "Sounds/Fireplace Loop 4.wav",
		"background_forest": "Sounds/backgroundforest.mp3",
		"main_menu": "Sounds/SurrealForest_MainMenuSound.mp3",
	}
	
	# Enemy Sounds
	sound_effects["enemies"] = {
		"zombie_death": "Sounds/zombieAttackSound.mp3",
		"rabbit_death": "Sounds/RabbitDeath.mp3",
		"bear_death": "Sounds/bearDeath.wav",
		"bear_death_alt": "Sounds/bear_Death.mp3",
		"wolf_death": "Sounds/WolfDeathSound1.mp3",
	}
	
	# Item Sounds
	sound_effects["items"] = {
		"iron_pickup": "Sounds/ironSound.wav",
		"stone_pickup": "Sounds/stoneSound.wav",
	}
	
	# Ambient Sounds
	sound_effects["ambient"] = {
		"forest_ambient": "Sounds/backgroundforest.mp3",
		"main_theme": "Sounds/SurrealForest_MainMenuSound.mp3",
	}
	
	print("✅ Loaded %d sound categories with %d effects total" % [
		sound_effects.size(),
		_count_total_sounds()
	])

## Count total sounds
func _count_total_sounds() -> int:
	var total = 0
	for category in sound_effects.values():
		total += category.size()
	return total

## Setup audio buses
func _setup_audio_buses() -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	if master_bus == -1:
		print("Creating Master bus...")
		AudioServer.add_bus(-1)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Master")
	
	# Create SFX bus
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus(-1)
		var sfx_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(sfx_bus, "SFX")
		AudioServer.set_bus_send(sfx_bus, "Master")
	
	# Create Music bus
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus(-1)
		var music_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(music_bus, "Music")
		AudioServer.set_bus_send(music_bus, "Master")
	
	# Create Ambient bus
	if AudioServer.get_bus_index("Ambient") == -1:
		AudioServer.add_bus(-1)
		var ambient_bus = AudioServer.bus_count - 1
		AudioServer.set_bus_name(ambient_bus, "Ambient")
		AudioServer.set_bus_send(ambient_bus, "Master")

## Play sound effect
func play_sound(category: String, effect_name: String, volume_db: float = 0.0, pitch: float = 1.0, spatial: bool = false, position: Vector3 = Vector3.ZERO) -> AudioStreamPlayer:
	if category not in sound_effects:
		print("❌ Category not found: %s" % category)
		return null
	
	if effect_name not in sound_effects[category]:
		print("❌ Sound not found: %s/%s" % [category, effect_name])
		return null
	
	var sound_path = asset_base_path + sound_effects[category][effect_name]
	
	if not ResourceLoader.exists(sound_path):
		print("⚠️ Sound file not found: %s" % sound_path)
		return null
	
	# Create audio player
	var player: AudioStreamPlayer
	if spatial:
		player = AudioStreamPlayer3D.new()
		player.position = position
		player.max_distance = 50.0
	else:
		player = AudioStreamPlayer.new()
	
	# Load audio
	var audio_stream = load(sound_path)
	if not audio_stream:
		print("❌ Failed to load: %s" % sound_path)
		return null
	
	player.stream = audio_stream
	player.bus = category.capitalize()
	player.volume_db = volume_db
	player.pitch_scale = pitch
	
	# Add to scene
	add_child(player)
	player.play()
	
	# Cleanup after playing
	player.finished.connect(func(): player.queue_free())
	
	active_sounds.append(player)
	print("🔊 Playing: %s/%s" % [category, effect_name])
	
	return player

## Play UI sound
func play_ui_sound(sound_name: String, volume_db: float = 0.0) -> AudioStreamPlayer:
	return play_sound("ui", sound_name, volume_db)

## Play combat sound
func play_combat_sound(sound_name: String, position: Vector3 = Vector3.ZERO) -> AudioStreamPlayer:
	return play_sound("combat", sound_name, 5.0, randf_range(0.9, 1.1), true, position)

## Play environment sound
func play_environment_sound(sound_name: String, volume_db: float = -5.0, looping: bool = false) -> AudioStreamPlayer:
	var player = play_sound("environment", sound_name, volume_db, 1.0, false)
	if looping and player:
		player.bus = "Ambient"
	return player

## Play enemy death sound
func play_enemy_death_sound(enemy_type: String, position: Vector3) -> AudioStreamPlayer:
	var sound_map = {
		"zombie": "zombie_death",
		"rabbit": "rabbit_death",
		"bear": "bear_death",
		"wolf": "wolf_death"
	}
	
	var sound_name = sound_map.get(enemy_type, "zombie_death")
	return play_sound("enemies", sound_name, 10.0, 1.0, true, position)

## Play item pickup sound
func play_item_sound(item_type: String, position: Vector3 = Vector3.ZERO) -> AudioStreamPlayer:
	var sound_map = {
		"iron": "iron_pickup",
		"stone": "stone_pickup",
		"wood": "stone_pickup",  # Fallback
	}
	
	var sound_name = sound_map.get(item_type, "stone_pickup")
	return play_sound("items", sound_name, 0.0, 1.0, true, position)

## Play background music
func play_background_music(music_name: String = "background_forest", volume_db: float = -10.0) -> AudioStreamPlayer:
	# Stop any existing music
	if "background_music" in audio_players:
		audio_players["background_music"].stop()
	
	var player = play_sound("ambient", music_name, volume_db, 1.0, false)
	if player:
		audio_players["background_music"] = player
	return player

## Stop all sounds in category
func stop_category(category: String) -> void:
	for player in active_sounds:
		if player.bus == category.capitalize():
			player.stop()

## Stop all sounds
func stop_all() -> void:
	for player in active_sounds:
		player.stop()

## Pause all sounds
func pause_all() -> void:
	get_tree().paused = true

## Resume all sounds
func resume_all() -> void:
	get_tree().paused = false

## Set bus volume
func set_bus_volume(bus_name: String, volume_db: float) -> void:
	var bus = AudioServer.get_bus_index(bus_name)
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, volume_db)

## Get list of sounds in category
func get_sounds_in_category(category: String) -> Array:
	if category in sound_effects:
		return sound_effects[category].keys()
	return []

## Get all categories
func get_all_categories() -> Array:
	return sound_effects.keys()

## Preload all sounds for faster playback
func preload_sounds() -> void:
	print("⏳ Preloading all sound effects...")
	var preloaded = 0
	
	for category in sound_effects:
		for sound_name in sound_effects[category]:
			var sound_path = asset_base_path + sound_effects[category][sound_name]
			if ResourceLoader.exists(sound_path):
				var _ = load(sound_path)
				preloaded += 1
	
	print("✅ Preloaded %d sound effects" % preloaded)
