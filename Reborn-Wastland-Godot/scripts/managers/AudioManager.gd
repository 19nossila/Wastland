extends Node
class_name AudioManager

## Audio Manager - Manages game audio, music, and sound effects with asset integration

signal audio_loaded(audio_key: String)
signal music_changed(track_name: String)
signal volume_changed(volume_type: String, volume: float)

var background_music_player: AudioStreamPlayer
var sfx_players: Dictionary = {}
var ambient_sounds: Dictionary = {}
var current_biome: String = "urban"
var current_music: String = ""

# Asset manager reference
var asset_manager: AssetManager
var config_manager: ConfigurationManager

# Audio library
var sound_effects: Dictionary = {}
var music_tracks: Dictionary = {}
var ambient_audio: Dictionary = {}

func _ready():
	"""Initialize audio manager"""
	add_to_group("audio_manager")
	asset_manager = get_tree().get_first_node_in_group("asset_manager")
	config_manager = get_tree().get_first_node_in_group("config_manager")
	_create_audio_players()
	_load_audio_library()
	_setup_audio_bus()
	print("Audio manager initialized")

func _create_audio_players():
	"""Create audio stream players"""
	# Background music player
	background_music_player = AudioStreamPlayer.new()
	background_music_player.name = "MusicPlayer"
	background_music_player.bus = "Music"
	add_child(background_music_player)
	
	# SFX players (create pool of them)
	var pool_size = config_manager.audio_config.get("audio_pool_size", 32) if config_manager else 32
	for i in range(pool_size):
		var sfx_player = AudioStreamPlayer3D.new()
		sfx_player.name = "SFXPlayer_%d" % i
		sfx_player.bus = "SFX"
		sfx_player.attenuation_model = AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		sfx_player.max_db = 0
		add_child(sfx_player)
		sfx_players["sfx_%d" % i] = sfx_player

func _setup_audio_bus():
	"""Setup audio bus configuration"""
	# Create buses if they don't exist
	var master = AudioServer.get_bus_index("Master")
	if master == -1:
		AudioServer.add_bus(0)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Master")
	
	# Audio settings from config
	if config_manager:
		var master_vol = config_manager.get_master_volume()
		var music_vol = config_manager.get_music_volume()
		var sfx_vol = config_manager.get_sfx_volume()
		
		set_master_volume(master_vol)
		set_music_volume(music_vol)
		set_sfx_volume(sfx_vol)

func _load_audio_library():
	"""Load or define audio library"""
	# In a full implementation, this would load actual audio files
	# For now, we'll use placeholder names
	
	# Sound effects
	sound_effects = {
		"footstep": "res://assets/sounds/sfx/footstep.wav",
		"gunshot_9mm": "res://assets/sounds/sfx/gunshot_9mm.wav",
		"gunshot_rifle": "res://assets/sounds/sfx/gunshot_rifle.wav",
		"zombie_groan": "res://assets/sounds/sfx/zombie_groan.wav",
		"zombie_growl": "res://assets/sounds/sfx/zombie_growl.wav",
		"zombie_shriek": "res://assets/sounds/sfx/zombie_shriek.wav",
		"item_pickup": "res://assets/sounds/sfx/item_pickup.wav",
		"item_drop": "res://assets/sounds/sfx/item_drop.wav",
		"inventory_open": "res://assets/sounds/sfx/menu_open.wav",
		"inventory_close": "res://assets/sounds/sfx/menu_close.wav",
		"crafting_complete": "res://assets/sounds/sfx/craft_complete.wav",
		"building_place": "res://assets/sounds/sfx/building_place.wav",
		"building_destroy": "res://assets/sounds/sfx/building_destroy.wav",
		"mutation_activate": "res://assets/sounds/sfx/mutation.wav",
		"damage_taken": "res://assets/sounds/sfx/damage.wav",
		"heal": "res://assets/sounds/sfx/heal.wav",
		"food_eat": "res://assets/sounds/sfx/eat.wav",
		"drink": "res://assets/sounds/sfx/drink.wav"
	}
	
	# Music tracks
	music_tracks = {
		"urban_ambient": "res://assets/music/urban_ambient.ogg",
		"forest_ambient": "res://assets/music/forest_ambient.ogg",
		"desert_ambient": "res://assets/music/desert_ambient.ogg",
		"mountain_ambient": "res://assets/music/mountain_ambient.ogg",
		"wasteland_ambient": "res://assets/music/wasteland_ambient.ogg",
		"boss_battle": "res://assets/music/boss_battle.ogg",
		"menu": "res://assets/music/menu.ogg",
		"tension": "res://assets/music/tension.ogg"
	}
	
	# Ambient audio
	ambient_audio = {
		"rain": "res://assets/sounds/ambient/rain.wav",
		"wind": "res://assets/sounds/ambient/wind.wav",
		"thunder": "res://assets/sounds/ambient/thunder.wav",
		"forest_birds": "res://assets/sounds/ambient/forest_birds.wav",
		"desert_wind": "res://assets/sounds/ambient/desert_wind.wav",
		"city_distant": "res://assets/sounds/ambient/city_distant.wav"
	}

func play_sound(sound_name: String, position: Vector3 = Vector3.ZERO, volume_db: float = 0.0) -> bool:
	"""Play a sound effect with asset loading"""
	if sound_name not in sound_effects:
		print("Sound not found: " + sound_name)
		return false
	
	# Find available SFX player
	for sfx_key in sfx_players:
		var player = sfx_players[sfx_key]
		if not player.playing:
			player.global_position = position
			
			# Load audio from asset manager
			if asset_manager:
				var audio_stream = asset_manager.get_audio_stream("audio_" + sound_name.to_lower())
				if audio_stream:
					player.stream = audio_stream
					player.volume_db = volume_db + (get_sfx_volume() * 10 - 10)
					player.play()
					return true
			
			# Fallback: try direct load
			var stream = load(sound_effects[sound_name])
			if stream:
				player.stream = stream
				player.volume_db = volume_db + (get_sfx_volume() * 10 - 10)
				player.play()
				return true
	
	return false

func play_music(track_name: String, fade_in: bool = false) -> bool:
	"""Play background music with asset loading"""
	if track_name not in music_tracks:
		print("Music track not found: " + track_name)
		return false
	
	# Load from asset manager
	var audio_stream = null
	if asset_manager:
		audio_stream = asset_manager.get_audio_stream("audio_music_" + track_name.to_lower())
	
	# Fallback to direct load
	if not audio_stream:
		audio_stream = load(music_tracks[track_name])
	
	if not audio_stream:
		print("Could not load music: " + track_name)
		return false
	
	background_music_player.stream = audio_stream
	current_music = track_name
	
	if fade_in:
		background_music_player.volume_db = -80
		var tween = create_tween()
		tween.tween_property(background_music_player, "volume_db", get_music_volume() * 10 - 10, 2.0)
	else:
		background_music_player.volume_db = get_music_volume() * 10 - 10
	
	background_music_player.play()
	music_changed.emit(track_name)
	return true

func stop_music(fade_out: bool = false):
	"""Stop background music"""
	if fade_out:
		var tween = create_tween()
		tween.tween_property(background_music_player, "volume_db", -80, 2.0)
		await tween.finished
		background_music_player.stop()
	else:
		background_music_player.stop()

func play_ambient(sound_name: String, volume_db: float = -20.0, loop: bool = true) -> bool:
	"""Play ambient sound"""
	if sound_name not in ambient_audio:
		print("Ambient sound not found: " + sound_name)
		return false
	
	if sound_name not in ambient_sounds:
		var ambient_player = AudioStreamPlayer.new()
		ambient_player.name = "Ambient_%s" % sound_name
		ambient_player.bus = "Ambient"
		add_child(ambient_player)
		ambient_sounds[sound_name] = ambient_player
	
	var player = ambient_sounds[sound_name]
	player.volume_db = volume_db
	# In production: player.stream = load(ambient_audio[sound_name])
	player.play()
	return true

func stop_ambient(sound_name: String):
	"""Stop ambient sound"""
	if sound_name in ambient_sounds:
		ambient_sounds[sound_name].stop()

func set_master_volume(volume: float):
	"""Set master volume (0.0 to 1.0)"""
	var clamped = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), clamped == 0)
	volume_changed.emit("master", clamped)
	if config_manager:
		config_manager.set_master_volume(clamped)

func set_music_volume(volume: float):
	"""Set music volume (0.0 to 1.0)"""
	var clamped = clamp(volume, 0.0, 1.0)
	if background_music_player.playing:
		background_music_player.volume_db = clamped * 10 - 10
	volume_changed.emit("music", clamped)
	if config_manager:
		config_manager.set_music_volume(clamped)

func set_sfx_volume(volume: float):
	"""Set sound effect volume (0.0 to 1.0)"""
	var clamped = clamp(volume, 0.0, 1.0)
	volume_changed.emit("sfx", clamped)
	if config_manager:
		config_manager.set_sfx_volume(clamped)

func get_master_volume() -> float:
	"""Get master volume"""
	return config_manager.get_master_volume() if config_manager else 1.0

func get_music_volume() -> float:
	"""Get music volume"""
	return config_manager.get_music_volume() if config_manager else 0.7

func get_sfx_volume() -> float:
	"""Get SFX volume"""
	return config_manager.get_sfx_volume() if config_manager else 0.8

func change_biome_music(biome_name: String):
	"""Change music based on biome"""
	current_biome = biome_name
	var music_key = biome_name + "_ambient"
	
	if music_key in music_tracks:
		stop_music(fade_out=true)
		await get_tree().create_timer(0.5).timeout
		play_music(music_key, fade_in=true)

func play_zombie_sound(zombie_type: String, position: Vector3):
	"""Play zombie vocalizations"""
	match zombie_type:
		"drifter":
			play_sound("zombie_groan", position, -10)
		"runner":
			play_sound("zombie_growl", position, -5)
		"mutant":
			play_sound("zombie_shriek", position, 0)
		_:
			play_sound("zombie_groan", position, -10)

func play_weapon_sound(weapon_type: String, position: Vector3):
	"""Play weapon firing sound"""
	match weapon_type:
		"pistol":
			play_sound("gunshot_9mm", position, 5)
		"rifle":
			play_sound("gunshot_rifle", position, 10)
		_:
			play_sound("gunshot_9mm", position, 5)

func play_ui_sound(ui_action: String):
	"""Play UI interaction sound"""
	match ui_action:
		"inventory_open":
			play_sound("inventory_open")
		"inventory_close":
			play_sound("inventory_close")
		"crafting_complete":
			play_sound("crafting_complete")
		"item_pickup":
			play_sound("item_pickup")
		"item_drop":
			play_sound("item_drop")
		_:
			play_sound("item_pickup")

func get_available_sounds() -> Array:
	"""Get list of all available sounds"""
	return sound_effects.keys()

func get_available_music() -> Array:
	"""Get list of all available music tracks"""
	return music_tracks.keys()

func get_available_ambient() -> Array:
	"""Get list of all available ambient sounds"""
	return ambient_audio.keys()
