extends Node3D
class_name BiomeManager

## Biome Manager - Manages different world biomes with unique properties

var biomes: Dictionary = {}
var current_biome: String = "urban"
var biome_nodes: Array = []

class BiomeData:
	var name: String
	var zombie_types: Array
	var weather_pool: Array
	var loot_multiplier: float
	var difficulty: float
	var ambient_color: Color
	var fog_density: float
	
	func _init(name: String):
		self.name = name
		self.zombie_types = []
		self.weather_pool = []
		self.loot_multiplier = 1.0
		self.difficulty = 1.0
		self.ambient_color = Color.WHITE
		self.fog_density = 0.01

func _ready():
	"""Initialize biome manager"""
	_create_biomes()
	_setup_biomes_in_world()
	print("Biome manager initialized with %d biomes" % biomes.size())

func _create_biomes():
	"""Create all game biomes"""
	
	# Urban Biome
	var urban = BiomeData.new("urban")
	urban.zombie_types = ["drifter", "runner", "sprinter"]
	urban.weather_pool = ["toxic_storm", "clear", "fog"]
	urban.loot_multiplier = 1.0
	urban.difficulty = 1.0
	urban.ambient_color = Color(0.6, 0.6, 0.6)
	biomes["urban"] = urban
	
	# Forest Biome
	var forest = BiomeData.new("forest")
	forest.zombie_types = ["mutant", "camouflaged", "runner"]
	forest.weather_pool = ["lightning", "fog", "clear"]
	forest.loot_multiplier = 1.3
	forest.difficulty = 1.3
	forest.ambient_color = Color(0.4, 0.6, 0.4)
	forest.fog_density = 0.02
	biomes["forest"] = forest
	
	# Desert Biome
	var desert = BiomeData.new("desert")
	desert.zombie_types = ["drifter", "spitter", "runner"]
	desert.weather_pool = ["heat_wave", "toxic_storm", "clear"]
	desert.loot_multiplier = 0.8
	desert.difficulty = 1.2
	desert.ambient_color = Color(0.8, 0.7, 0.5)
	biomes["desert"] = desert
	
	# Mountain Biome
	var mountain = BiomeData.new("mountain")
	mountain.zombie_types = ["frozen", "armored", "mutant"]
	mountain.weather_pool = ["blizzard", "lightning", "clear"]
	mountain.loot_multiplier = 1.5
	mountain.difficulty = 1.6
	mountain.ambient_color = Color(0.7, 0.7, 0.8)
	biomes["mountain"] = mountain
	
	# Wasteland Biome
	var wasteland = BiomeData.new("wasteland")
	wasteland.zombie_types = ["drifter", "runner", "mutant", "camouflaged"]
	wasteland.weather_pool = ["toxic_storm", "clear", "lightning"]
	wasteland.loot_multiplier = 0.9
	wasteland.difficulty = 1.1
	wasteland.ambient_color = Color(0.5, 0.4, 0.3)
	biomes["wasteland"] = wasteland

func _setup_biomes_in_world():
	"""Setup biome zones in world"""
	# This would be called after terrain generation
	# For now, just initialize them
	for biome_name in biomes:
		var biome_zone = Node3D.new()
		biome_zone.name = biome_name
		add_child(biome_zone)
		biome_nodes.append(biome_zone)

func get_biome(biome_name: String) -> BiomeData:
	"""Get biome data"""
	return biomes.get(biome_name, null)

func get_all_biomes() -> Array:
	"""Get all biome names"""
	return biomes.keys()

func get_biome_zombies(biome_name: String) -> Array:
	"""Get zombie types for biome"""
	if biome_name in biomes:
		return biomes[biome_name].zombie_types
	return []

func get_biome_weather_pool(biome_name: String) -> Array:
	"""Get weather pool for biome"""
	if biome_name in biomes:
		return biomes[biome_name].weather_pool
	return []

func get_biome_difficulty(biome_name: String) -> float:
	"""Get difficulty multiplier for biome"""
	if biome_name in biomes:
		return biomes[biome_name].difficulty
	return 1.0

func get_loot_multiplier(biome_name: String) -> float:
	"""Get loot multiplier for biome"""
	if biome_name in biomes:
		return biomes[biome_name].loot_multiplier
	return 1.0

func get_biome_ambient_color(biome_name: String) -> Color:
	"""Get ambient color for biome"""
	if biome_name in biomes:
		return biomes[biome_name].ambient_color
	return Color.WHITE

func change_biome(biome_name: String) -> bool:
	"""Change to different biome"""
	if biome_name not in biomes:
		return false
	
	current_biome = biome_name
	print("Changed biome to: " + biome_name)
	return true

func get_current_biome() -> String:
	"""Get current biome"""
	return current_biome

func get_biome_description(biome_name: String) -> String:
	"""Get human-readable description of biome"""
	match biome_name:
		"urban":
			return "Abandoned city ruins with danger around every corner."
		"forest":
			return "Dense forest with mutated creatures and limited visibility."
		"desert":
			return "Scorching wasteland with extreme heat and zombie hordes."
		"mountain":
			return "High altitude peaks with harsh weather and armored creatures."
		"wasteland":
			return "Barren industrial zone with mixed threats and resources."
		_:
			return "Unknown biome"
